import torch
import torch.nn as nn


class Quantize:
    """
    Quantization object that keeps track of full-precision parameters
    and computes quantized parameters before the forward pass.

    Effectively combines torch.quantization.MinMaxObserver
    and torch.quantization.FakeQuantize.
    """

    name: str

    def __init__(self, name, quant_min, quant_max, symmetric):
        super().__init__()

        # name of parameter
        self.name = name

        # quantization range and symmetry (equal resolution on both sides)
        self.quant_min = float(quant_min)
        self.quant_max = float(quant_max)
        self.symmetric = symmetric

    def compute_quantized(self, module):
        """
        Computes the quantized parameter from the stored full-precision parameter.
        """
        # get full-precision
        full = getattr(module, self.name + "_f")

        # min and max; min cannot be positive, max cannot be negative
        min_neg = full.min().clamp(max=0)
        max_pos = full.max().clamp(min=0)

        # get scale and zero-point
        if self.symmetric:
            scale = 2 * torch.max(-min_neg, max_pos) / (self.quant_max - self.quant_min)
            zero_point = torch.tensor(0.0)
        else:
            scale = (max_pos - min_neg) / (self.quant_max - self.quant_min)
            zero_point = (self.quant_min - (min_neg / scale).round()).clamp(self.quant_min, self.quant_max)

        return _quantize(full, self.quant_min, self.quant_max, scale, zero_point)

    @staticmethod
    def apply(module, name, quant_min, quant_max, symmetric):
        """
        Apply quantization to a parameter of a certain module as a pre-forward hook.
        """
        # function to call in hook
        fn = Quantize(name, quant_min, quant_max, symmetric)

        # get full-precision, remove from parameter list
        full = getattr(module, name)
        del module._parameters[name]

        # register full-precision under different name
        module.register_parameter(name + "_f", nn.Parameter(full.data))
        setattr(module, name, fn.compute_quantized(module))

        # register quantization to occur before forward pass
        module.register_forward_pre_hook(fn)

        return fn

    def remove(self, module):
        """
        Remove full-precision, keep only quantized parameter.
        """
        quantized = self.compute_quantized(module)
        delattr(module, self.name)
        del module._parameters[self.name + "_f"]
        setattr(module, self.name, nn.Parameter(quantized.data))

    def __call__(self, module, inputs):
        """
        Called by hook: re-computes the quantized parameter.
        """
        setattr(module, self.name, self.compute_quantized(module))


def quantize(module, name, quant_min, quant_max, symmetric):
    """
    Apply quantization to a certain parameter of a certain module.
    """
    Quantize.apply(module, name, quant_min, quant_max, symmetric)
    return module


class QuantizeFn(torch.autograd.Function):
    """
    Computes quantized parameters while propagating gradients
    using a straight-through estimator, without clipping too large
    gradients as in Hubara et al. 2016 ("Binarized Neural Networks").
    """

    @staticmethod
    def forward(ctx, x, quant_min, quant_max, scale, zero_point):
        # ctx.save_for_backward(x)
        x_quant = ((x / scale + zero_point).round().clamp(quant_min, quant_max) - zero_point) * scale
        return x_quant

    @staticmethod
    def backward(ctx, grad_output):
        # (x,) = ctx.saved_tensors
        grad_input = grad_output.clone()
        # check where forward |x| <= 1
        # clipped = x.abs().le(1)
        # for those outside: grad is 0
        # grad_input[~clipped] = 0
        return grad_input, None, None, None, None


_quantize = QuantizeFn.apply
