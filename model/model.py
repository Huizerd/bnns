import pytorch_lightning as pl
import torch

from model.submodules import BinarizedLinear, binarize


class BNN(pl.LightningModule):
    """
    Binarized neural network, following Hubara et al. 2016
    ("Binarized Neural Networks").
    """

    def __init__(self, optimizer, lr, batch_size):
        super().__init__()

        # simple architecture
        # no batchnorm, so I think we need biases instead
        self.fc1 = BinarizedLinear(784, 512)
        self.fc2 = BinarizedLinear(512, 512)
        self.fc3 = BinarizedLinear(512, 10)

        # classification loss and optimizer
        # cross-entryopy = log_softmax + negative log-likelihood
        self.loss_fn = torch.nn.CrossEntropyLoss()
        self.optim = optimizer

        # these can be set by auto_scale_batch and auto_lr_find
        self.lr = lr
        self.batch_size = batch_size

    def forward(self, x):
        # input x
        # - is assumed binary
        # - has shape (batch, 1, 28, 28)
        x = x.view(self.batch_size, 784)
        x = binarize(self.fc1(x))
        x = binarize(self.fc2(x))
        x = self.fc3(x)  # we don't binarize the final activation
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
        # get loss and log
        loss = self.loss_fn(logits, labels)
        self.log(f"{prefix} loss", loss)
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
