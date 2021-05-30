import argparse

import matplotlib.pyplot as plt
from pl_bolts.datasets.mnist_dataset import MNIST
from torch.utils.data import DataLoader
from torchvision import transforms
from torchvision.utils import make_grid
import yaml

from utils.utils import get_device


def vis_data(config):
    # dataset
    # - only train data
    # - download and convert to tensors
    data = MNIST(config["datamodule"]["dir"], train=True, download=True, transform=transforms.ToTensor())

    # dataloader
    # - shuffle data order each epoch
    # - pin_memory improves performance
    dataloader = DataLoader(
        data,
        batch_size=config["datamodule"]["batch"],
        shuffle=True,
        num_workers=config["datamodule"]["num_workers"],
        pin_memory=True,
    )

    # get device
    device = get_device(config["misc"]["gpu"])

    # loop over dataset
    for batch_idx, (data, label) in enumerate(dataloader):
        # move to GPU
        data, label = data.to(device), label.to(device)

        # binarize data
        data_bin = data.gt(config["misc"]["thresh"]).float()  # check for greater than thresh

        # visualize
        grid_img = make_grid(data, nrow=data.shape[0] // 4)
        grid_img_bin = make_grid(data_bin, nrow=data_bin.shape[0] // 4)
        fig, ax = plt.subplots(2, 1)
        ax[0].set_title(f"Batch {batch_idx}")
        ax[0].imshow(grid_img.permute(1, 2, 0).cpu())
        ax[1].set_title(f"Batch {batch_idx}, binarized with thresh {config['misc']['thresh']}")
        ax[1].imshow(grid_img_bin.permute(1, 2, 0).cpu())
        fig.tight_layout()
        plt.show()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", type=str, default="conf/vis_data.yaml")
    args = parser.parse_args()

    with open(args.config, "r") as f:
        config = yaml.load(f, Loader=yaml.FullLoader)

    vis_data(config)
