import argparse

import pytorch_lightning as pl
import yaml

from data.datamodule import BinaryMNISTDataModule
from model.model import BNN


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
    model = BNN(**config["model"], batch_size=config["datamodule"]["batch"])

    # logging? TensorBoard or MLflow?
    logger = None

    # train!
    trainer = pl.Trainer(**config["trainer"], logger=logger)
    trainer.tune(model, datamodule=dm)
    trainer.fit(model, datamodule=dm)

    # save model?


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", type=str, default="conf/train.yaml")
    args = parser.parse_args()

    with open(args.config, "r") as f:
        config = yaml.load(f, Loader=yaml.FullLoader)

    train(config)
