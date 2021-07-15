import torch
import torch.nn as nn


class Binarize:
    """
    Binarization object that keeps track of full-precision parameters
    and computes binarized parameters before the forward pass.
    """

    name: str

    def __init__(self, name):
        # name of parameter
        self.name = name

    def compute_binarized(self, module):
        """
        Computes the binarized parameter from the stored full-precision parameter.
        """
        full = getattr(module, self.name + "_f")
        return _binarize(full)

    @staticmethod
    def apply(module, name):
        """
        Apply binarization to a parameter of a certain module as a pre-forward hook.
        """
        # function to call in hook
        fn = Binarize(name)

        # get full-precision, remove from parameter list
        full = getattr(module, name)
        del module._parameters[name]

        # register full-precision under different name
        module.register_parameter(name + "_f", nn.Parameter(full.data))
        setattr(module, name, fn.compute_binarized(module))

        # register binarization to occur before forward pass
        module.register_forward_pre_hook(fn)

        return fn

    def remove(self, module):
        """
        Remove full-precision, keep only binarized parameter.
        """
        binarized = self.compute_binarized(module)
        delattr(module, self.name)
        del module._parameters[self.name + "_f"]
        setattr(module, self.name, nn.Parameter(binarized.data))

    def __call__(self, module, inputs):
        """
        Called by hook: re-computes the binarized parameter.
        """
        setattr(module, self.name, self.compute_binarized(module))


def binarize(module, name):
    """
    Apply binarization to a certain parameter of a certain module.
    """
    Binarize.apply(module, name)
    return module


class BinarizeFn(torch.autograd.Function):
    """
    Binarization function: return sign in forward pass,
    clip too large gradients in backward pass.

    From Hubara et al. 2016 ("Binarized Neural Networks"),
    also implemented here: https://github.com/nikvaessen/Rethinking-Binarized-Neural-Network-Optimization/blob/master/research_seed/bytorch/binary_neural_network.py
    More info on custom gradients: https://pytorch.org/docs/stable/notes/extending.html
    """

    @staticmethod
    def forward(ctx, x):
        ctx.save_for_backward(x)
        return x.sign()  # note: returns 0 for 0

    @staticmethod
    def backward(ctx, grad_output):
        (x,) = ctx.saved_tensors
        grad_input = grad_output.clone()
        # check where forward |x| <= 1
        clipped = x.abs().le(1)
        # for those outside: grad is 0
        grad_input[~clipped] = 0
        return grad_input


_binarize = BinarizeFn.apply
