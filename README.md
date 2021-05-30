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

## Data visualization (test)

I made `vis_data.py`, which visualizes MNIST and its binarized coursin using a threshold of 0.5. See the config file in `conf/vis_data.yaml`.

## Training

Configuration can be changed in `conf/train.yaml`.

```bash
$ python train.py
```

## Evaluation

Configuration can be changed in `conf/eval.yaml`.

```bash
$ python eval.py --checkpoint logs/base/version_0/checkpoints/epoch=99-step-37499.ckpt
```

## Implementation

The [paper](https://papers.neurips.cc/paper/2016/hash/d8330f857a17c53d217014ee776bfd50-Abstract.html) by Hubara et al. is a bit ambiguous about the gradient that is to be backpropagated. On page 3 they say that they cancel the gradient when the input is too large (i.e., above 1 in magnitude) and else set it to 1, but one line later they say that this can be seen as a "hard tanh", which clips gradients to [-1, 1]. So which is it going to be? Set gradients for |x| > 1 to 0 and |x| < 1 to 1, or clamp gradients to [-1, 1]? Or is this equivalent? The [original code](https://github.com/itayhubara/BinaryNet.pytorch/blob/master/models/binarized_modules.py) doesn't help out; a [related implementation](https://github.com/nikvaessen/Rethinking-Binarized-Neural-Network-Optimization/blob/master/research_seed/bytorch/binary_neural_network.py) takes the former approach of setting too large grads to 0.

Answer: cancelling approach is clearly better!

## TODO

- Save hparams: combine with config?
- Visualize evaluation?
- Save git diff?