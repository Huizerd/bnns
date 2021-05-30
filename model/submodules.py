import torch


"""
A very similar implemenation can be found here:
https://github.com/nikvaessen/Rethinking-Binarized-Neural-Network-Optimization/blob/master/research_seed/bytorch/binary_neural_network.py

One difference: they cancel |grads| > 1 instead of clipping them, and set |grads| < 1 == 1.
TODO: benchmark this and our approach
"""


class BinarizedActivation(torch.autograd.Function):
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
binarize = BinarizedActivation.apply


class BinarizedLinear(torch.nn.Linear):
    """
    Fully connected layer but with binarized parameters.
    """

    def forward(self, x):
        # binarize weights and biases
        weight = binarize(self.weight)
        bias = self.bias if self.bias is None else binarize(self.bias)
        # do matrix multiplication and addition
        return torch.nn.functional.linear(x, weight, bias)
