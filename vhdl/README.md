# VHDL implementation

Pseudo-code for the VHDL algorithm:

```
While not done do simultaneously: 
  Loop for every hidden layer 1 neuron:
        - Get all input values
        - Get all input weights for this neuron
        - Calculate neuron output
        - Put output in buffer
  Loop for every hidden layer 2 neuron:
        - Get all layer 1 output values
        - Get all weights for this neuron
        - Calculate neuron output
        - Put output in buffer
  Loop for every output neuron:
        - Get all layer 2 output values
        - Get all weights for this neuron
        - Calculate neuron output
        - Put output in buffer
Put all buffer values in register for layer 2
Put all buffer values in register for output layer
Output highest output value
```
