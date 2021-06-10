from utils.utils import model_weights_as_vector
from model.model import BNN
import numpy as np

checkpoint = "logs/base/version_0/checkpoints/epoch=99-step=37499.ckpt"
model = BNN.load_from_checkpoint(checkpoint_path=checkpoint)

for key in model.state_dict():
    key_parts = key.split('.')
    if len(key_parts) == 3:
        filename = f'{key_parts[0] + key_parts[1]}.txt'
    elif len(key_parts) == 2:
        filename = f'{key_parts[0]}.txt'
    with open(filename, 'a') as f:
        for n in range(model.state_dict()[key].size()[0]):        
            values = model.state_dict()[key][n].gt(0.0).int().detach().numpy()
            if np.ndim(values) == 0:
                values = [values]
            print(len(values))
            for val in values:
                f.write(str(val))
            if key_parts[-1] != 'bias':
                f.write('\n')

        
