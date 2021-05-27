import torch


def get_device(device_idx):
    cuda = torch.cuda.is_available()
    device = torch.device(f"cuda:{device_idx}" if cuda else "cpu")
    return device
