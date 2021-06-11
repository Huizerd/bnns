import argparse

import pytorch_lightning as pl
from pytorch_lightning.loggers import TensorBoardLogger
import yaml

from data.datamodule import BinaryMNISTDataModule
from model.model import BNN


def evaluate(config, checkpoint):
    # seed
    pl.seed_everything(0)

    # datamodule = dataset + dataloader
    # - also contains test data
    # - pin_memory improves performance
    dm = BinaryMNISTDataModule(
        config["datamodule"]["dir"],
        num_workers=config["datamodule"]["num_workers"],
        batch_size=config["datamodule"]["batch"],
        pin_memory=True,
    )

    # model
    model = BNN.load_from_checkpoint(checkpoint_path=checkpoint)

    # log test to correct TensorBoard run
    save_dir, name, version = checkpoint.split("/")[:3]
    logger = TensorBoardLogger(save_dir, name=name, version=version)

    # evaluate!
    trainer = pl.Trainer(**config["trainer"], logger=logger)
    trainer.test(model, datamodule=dm)

    # TODO: some visualization?


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", type=str, default="conf/eval.yaml")
    parser.add_argument("--checkpoint", type=str, required=True)
    args = parser.parse_args()

    with open(args.config, "r") as f:
        config = yaml.load(f, Loader=yaml.FullLoader)

    evaluate(config, args.checkpoint)
