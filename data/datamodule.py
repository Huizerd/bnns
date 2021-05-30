from pl_bolts.datasets.mnist_dataset import BinaryMNIST
from pl_bolts.datamodules.mnist_datamodule import MNISTDataModule


class BinaryMNISTDataModule(MNISTDataModule):
    name = "binarymnist"
    dataset_cls = BinaryMNIST  # has 0.5 as threshold for making binary
