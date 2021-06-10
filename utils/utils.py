import torch
import numpy as np

def get_device(device_idx):
    cuda = torch.cuda.is_available()
    device = torch.device(f"cuda:{device_idx}" if cuda else "cpu")
    return device


def model_weights_as_vector(model):
    weights_vector = []

    for curr_weights in model.state_dict().values():
        # Calling detach() to remove the computational graph from the layer. 
        # numpy() is called for converting the tensor into a NumPy array.
        if curr_weights.device != 'cpu':
            curr_weights = curr_weights.to(device='cpu')
        curr_weights = curr_weights.detach().numpy()
        vector = np.reshape(curr_weights, newshape=(curr_weights.size))
        weights_vector.extend(vector)
    return np.array(weights_vector)
    
