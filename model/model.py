import pytorch_lightning as pl
import torch
import torch.nn as nn
import torchmetrics

import model.binarize as B
from model.submodules import BinarizedLinear, dont_binarize, binarize_cancel, binarize_htanh


class BNN(pl.LightningModule):
    """
    Binarized neural network, following Hubara et al. 2016
    ("Binarized Neural Networks").
    """

    def __init__(self, hidden_sizes, optimizer, lr, batch_size, binarize_fn):
        super().__init__()

        # save passed hyperparams
        self.save_hyperparameters()

        # simple architecture
        # no batchnorm, so I think we need biases instead

        # input + hidden
        self.hiddens = torch.nn.ModuleList()
        self.hiddens.append(BinarizedLinear(784, hidden_sizes[0], binarize_fn=binarize_fn))
        for in_size, out_size in zip(hidden_sizes[:1], hidden_sizes[1:]):
            self.hiddens.append(BinarizedLinear(in_size, out_size, binarize_fn=binarize_fn))
        # output
        self.out = BinarizedLinear(hidden_sizes[-1], 10, binarize_fn=binarize_fn)

        # classification loss/metric and optimizer
        # cross-entryopy = log_softmax + negative log-likelihood
        self.loss_fn = torch.nn.CrossEntropyLoss()
        self.accuracy = torchmetrics.Accuracy()
        self.optim = optimizer

        # binarization fn
        self.binarize = eval(binarize_fn)

        # these can be set by auto_scale_batch and auto_lr_find
        self.lr = lr
        self.batch_size = batch_size

    def forward(self, x):
        # input x
        # - is assumed binary
        # - has shape (batch, 1, 28, 28)
        # - if we don't have drop_last == True for dataloader, batch can differ
        batch, _, _, _ = x.shape
        x = x.view(batch, 784)

        # go through hidden layers
        for hidden in self.hiddens:
            x = self.binarize(hidden(x))
            # x = torch.relu(hidden(x))  # if you want relu in combination with full precision
        x = self.out(x)  # we don't binarize the final activation

        return x

    def training_step(self, batch, batch_idx):
        return self._shared_step(batch, batch_idx, "train")

    def validation_step(self, batch, batch_idx):
        return self._shared_step(batch, batch_idx, "val")

    def test_step(self, batch, batch_idx):
        return self._shared_step(batch, batch_idx, "test")

    def _shared_step(self, batch, batch_idx, prefix):
        data, labels = batch
        # call forward
        logits = self(data)

        # get loss and accuracy
        loss = self.loss_fn(logits, labels)
        # needs softmax until https://github.com/PyTorchLightning/metrics/issues/60 is fixed
        accuracy = self.accuracy(torch.nn.functional.softmax(logits, 1), labels)

        # log
        self.log(f"{prefix} loss", loss)
        self.log(f"{prefix} accuracy", accuracy)

        return loss

    def configure_optimizers(self):
        optimizer = eval(self.optim)(self.parameters(), self.lr)
        return optimizer

    # custom optimizer step: clamp parameters after updating them
    def optimizer_step(self, *args, **kwargs):
        # do the original optimizer step first
        super().optimizer_step(*args, **kwargs)

        # clamp parameters, don't record grads
        with torch.no_grad():
            for param in self.parameters():
                param.clamp_(-1, 1)

    # called after each epoch
    def training_epoch_end(self, *args, **kwargs):
        # go over all parameters
        for name, param in self.named_parameters():
            # log parameter histogram
            self.logger.experiment.add_histogram(name, param, self.current_epoch)

        # do the original training_epoch_end
        return super().training_epoch_end(*args, **kwargs)


class HookBNN(pl.LightningModule):
    """
    Same as BNN, but binarization as hook.
    """

    def __init__(self, hidden_sizes, optimizer, lr, batch_size, binarize_fn):
        super().__init__()

        # save passed hyperparams
        self.save_hyperparameters()

        # simple architecture
        # no batchnorm, so I think we need biases instead

        # input + hidden
        self.hiddens = torch.nn.ModuleList()
        self.hiddens.append(nn.Linear(784, hidden_sizes[0]))
        for in_size, out_size in zip(hidden_sizes[:1], hidden_sizes[1:]):
            self.hiddens.append(nn.Linear(in_size, out_size))
        # output
        self.out = nn.Linear(hidden_sizes[-1], 10)

        # classification loss/metric and optimizer
        # cross-entryopy = log_softmax + negative log-likelihood
        self.loss_fn = torch.nn.CrossEntropyLoss()
        self.accuracy = torchmetrics.Accuracy()
        self.optim = optimizer

        # binarize parameters with hooks
        for child in self.modules():
            for param in ["weight", "bias"]:
                if isinstance(child, nn.Linear):
                    B.binarize(child, param)

        # binarize activations
        self.binarize = eval(binarize_fn)

        # these can be set by auto_scale_batch and auto_lr_find
        self.lr = lr
        self.batch_size = batch_size

    def forward(self, x):
        # input x
        # - is assumed binary
        # - has shape (batch, 1, 28, 28)
        # - if we don't have drop_last == True for dataloader, batch can differ
        batch, _, _, _ = x.shape
        x = x.view(batch, 784)

        # go through hidden layers
        for hidden in self.hiddens:
            x = self.binarize(hidden(x))
            # x = torch.relu(hidden(x))  # if you want relu in combination with full precision
        x = self.out(x)  # we don't binarize the final activation

        return x

    def training_step(self, batch, batch_idx):
        return self._shared_step(batch, batch_idx, "train")

    def validation_step(self, batch, batch_idx):
        return self._shared_step(batch, batch_idx, "val")

    def test_step(self, batch, batch_idx):
        return self._shared_step(batch, batch_idx, "test")

    def _shared_step(self, batch, batch_idx, prefix):
        data, labels = batch
        # call forward
        logits = self(data)

        # get loss and accuracy
        loss = self.loss_fn(logits, labels)
        # needs softmax until https://github.com/PyTorchLightning/metrics/issues/60 is fixed
        accuracy = self.accuracy(torch.nn.functional.softmax(logits, 1), labels)

        # log
        self.log(f"{prefix} loss", loss)
        self.log(f"{prefix} accuracy", accuracy)

        return loss

    def configure_optimizers(self):
        optimizer = eval(self.optim)(self.parameters(), self.lr)
        return optimizer

    # custom optimizer step: clamp parameters after updating them
    def optimizer_step(self, *args, **kwargs):
        # do the original optimizer step first
        super().optimizer_step(*args, **kwargs)

        # clamp parameters, don't record grads
        with torch.no_grad():
            for param in self.parameters():
                param.clamp_(-1, 1)

    # called after each epoch
    def training_epoch_end(self, *args, **kwargs):
        # go over all parameters
        for name, param in self.named_parameters():
            # log parameter histogram
            self.logger.experiment.add_histogram(name, param, self.current_epoch)

        # do the original training_epoch_end
        return super().training_epoch_end(*args, **kwargs)
