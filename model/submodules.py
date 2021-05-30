import torch


class BinarizeCancel(torch.autograd.Function):
    """
    Binarized activation: returns sign in forward pass,
    gradient of 1 or 0 (cancel) in backward pass.

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


class BinarizeHardTanh(torch.autograd.Function):
    """
    Binarized activation: returns sign in forward pass,
    clamped gradient in backward pass.

    More info on custom gradients: https://pytorch.org/docs/stable/notes/extending.html
    """

    @staticmethod
    def forward(ctx, x):
        return x.sign()  # note: returns 0 for 0

    @staticmethod
    def backward(ctx, grad_output):
        grad_input = grad_output.clone()
        return torch.nn.functional.hardtanh(grad_input)  # clamp to (-1, 1)


# just for convenience
binarize_cancel = BinarizeCancel.apply
binarize_htanh = BinarizeHardTanh.apply


class BinarizedLinear(torch.nn.Linear):
    """
    Fully connected layer but with binarized parameters.
    """

    def __init__(self, *args, binarize_fn="binarize_cancel", **kwargs):
        # init parent first
        super().__init__(*args, **kwargs)
        # add binarization fn
        self.binarize = eval(binarize_fn)

    def forward(self, x):
        # binarize weights and biases
        weight = self.binarize(self.weight)
        bias = self.bias if self.bias is None else self.binarize(self.bias)
        # do matrix multiplication and addition
        return torch.nn.functional.linear(x, weight, bias)
