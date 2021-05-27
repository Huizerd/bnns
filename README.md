# BNNs
Implementation of binary neural networks with PyTorch (and VHDL).

## Installation

Tested with Python 3.8.5, Ubuntu 20.04. Use a virtual environment:

```bash
$ python3 -m venv venv
$ source venv/bin/activate
$ pip install -U pip setuptools wheel
$ pip install -r requirements.txt
```

Code is formatted automatically upon committing using `pre-commit`. Install it:

```bash
$ pre-commit install
```

## Testing

I made `test_dataloader.py`, which visualizes MNIST and its binarization using the given threshold. See the config file in `conf/test_dataloader.yaml`.