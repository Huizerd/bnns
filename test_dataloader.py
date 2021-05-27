import argparse
import yaml

import matplotlib.pyplot as plt
from torch.utils.data import DataLoader
from torchvision import transforms
from torchvision.datasets import MNIST
from torchvision.utils import make_grid

from utils.utils import get_device


def test_dataloader(config):
    # dataset and dataloader
    data = MNIST(
        config["data"]["dir"], train=True, download=True, transform=transforms.ToTensor()
    )  # only train data; download and convert to tensors
    dataloader = DataLoader(
        data,
        batch_size=config["loader"]["batch"],
        shuffle=True,
        num_workers=config["loader"]["num_workers"],
        pin_memory=True,
    )  # shuffle data order each epoch; pin_memory improves performance

    # get device
    device = get_device(config["loader"]["gpu"])

    # loop over dataset
    for batch_idx, (data, label) in enumerate(dataloader):
        # move to GPU
        data, label = data.to(device), label.to(device)

        # binarize data
        data_bin = data.gt(config["data"]["thresh"]).float()  # check for greater than thresh

        # visualize
        if config["visualize"]["enabled"]:
            grid_img = make_grid(data, nrow=data.shape[0] // 4)
            grid_img_bin = make_grid(data_bin, nrow=data_bin.shape[0] // 4)
            fig, ax = plt.subplots(2, 1)
            ax[0].set_title(f"Batch {batch_idx}")
            ax[0].imshow(grid_img.permute(1, 2, 0).cpu())
            ax[1].set_title(f"Batch {batch_idx}, binarized with thresh {config['data']['thresh']}")
            ax[1].imshow(grid_img_bin.permute(1, 2, 0).cpu())
            fig.tight_layout()
            plt.show()

        # print info
        if config["visualize"]["verbose"]:
            print(f"Epoch: 000  Batch: {batch_idx:04d}/{len(dataloader)}  Loss: 0.00000", end="\r")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", type=str, default="conf/test_dataloader.yaml")
    args = parser.parse_args()

    with open(args.config, "r") as f:
        config = yaml.load(f, Loader=yaml.FullLoader)

    test_dataloader(config)
