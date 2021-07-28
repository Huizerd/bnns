import argparse

import pytorch_lightning as pl
from pytorch_lightning.loggers import TensorBoardLogger
import yaml

from data.datamodule import BinaryMNISTDataModule
from model.model import BNN, HookANN


def train(config):
    # seed
    pl.seed_everything(0)

    # datamodule = dataset + dataloader
    # - split into train and validation
    # - shuffle data order each epoch
    # - pin_memory improves performance
    dm = BinaryMNISTDataModule(
        config["datamodule"]["dir"],
        val_split=0.2,
        num_workers=config["datamodule"]["num_workers"],
        batch_size=config["datamodule"]["batch"],
        shuffle=True,
        pin_memory=True,
    )

    # model
    # model = BNN(**config["model"], batch_size=config["datamodule"]["batch"])
    model = HookANN(**config["model"], batch_size=config["datamodule"]["batch"])

    # logging with TensorBoard
    logger = TensorBoardLogger(config["logging"]["dir"], name=config["logging"]["name"])

    # train!
    trainer = pl.Trainer(**config["trainer"], logger=logger)
    trainer.tune(model, datamodule=dm)
    trainer.fit(model, datamodule=dm)

    # save model? -> happens automatically, in checkpoints folder


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", type=str, default="conf/train.yaml")
    args = parser.parse_args()

    with open(args.config, "r") as f:
        config = yaml.load(f, Loader=yaml.FullLoader)

    train(config)
