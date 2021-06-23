import argparse

from pl_bolts.datasets.mnist_dataset import BinaryMNIST
import pytorch_lightning as pl
import torch
from torchvision import transforms
import yaml

from model.model import BNN


def export(config, checkpoint):

    # data
    data = BinaryMNIST(
        config["datamodule"]["dir"], train=False, download=True, transform=transforms.Compose([transforms.ToTensor()])
    )

    # model
    model = BNN.load_from_checkpoint(checkpoint_path=checkpoint)

    # export to correct dir
    save_dir = "/".join(checkpoint.split("/")[:3])

    # save parameters to txt files
    # one file per layer; one line per output
    with torch.no_grad():
        # input/hidden
        for i, layer in enumerate(model.hiddens):
            # convert from -1, 1 to 0, 1
            weights = model.binarize(layer.weight).gt(0).int().tolist()
            biases = model.binarize(layer.bias).gt(0).int().tolist()

            # write weights
            with open(f"{save_dir}/l{i}_weights.txt", "w") as f:
                for line in weights:
                    f.write("".join((str(w) for w in line)) + "\n")

            # write bias
            with open(f"{save_dir}/l{i}_biases.txt", "w") as f:
                # bias list is reversed to accomodate vhdl code
                for b in biases:
                    f.write("".join(str(b)) + "\n") 

        # output
        # convert from -1, 1 to 0, 1
        weights = model.binarize(model.out.weight).gt(0).int().tolist()
        biases = model.binarize(model.out.bias).gt(0).int().tolist()

        # write weights
        with open(f"{save_dir}/l{len(model.hiddens)}_weights.txt", "w") as f:
            for line in weights:
                f.write("".join((str(w) for w in line)) + "\n")

        # write bias
        with open(f"{save_dir}/l{len(model.hiddens)}_biases.txt", "w") as f:
            for b in biases:
                f.write("".join(str(b)) + "\n") 

    # save input image and network output
    image = data[0][0]
    output = model(image.view(1, *image.shape))
    image = image.view(-1).int().tolist()  # is already 0, 1
    output = output.view(-1).int().tolist()  # raw counts

    with open(f"{save_dir}/in_image.txt", "w") as f:
        f.write("".join((str(i) for i in image)) + "\n")
    with open(f"{save_dir}/net_output.txt", "w") as f:
        for out in output:
            f.write(f"{out}\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", type=str, default="conf/export.yaml")
    parser.add_argument("--checkpoint", type=str, required=True)
    args = parser.parse_args()

    with open(args.config, "r") as f:
        config = yaml.load(f, Loader=yaml.FullLoader)

        export(config, args.checkpoint)
