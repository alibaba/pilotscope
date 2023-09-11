import torch
from torch.nn import Module, Conv1d

class ConvTree(Module):
    def __init__(self, in_channels, out_channels):
        super().__init__()

        self.conv_core = Conv1d(in_channels, out_channels, stride=3, kernel_size=3)
        self._in_channels = in_channels
        self._out_channels = out_channels

    def forward(self, flatened_tree_and_indexes):
        trees, indexes = flatened_tree_and_indexes
        indexes_tmp = indexes.expand(-1, -1, self._in_channels).transpose(1, 2)
        results = self.conv_core(torch.gather(trees, 2, indexes_tmp))
        zeros = torch.zeros((trees.shape[0], self._out_channels), device=results.device).unsqueeze(2)
        results = torch.cat((zeros, results), dim=2)
        return (results, indexes)


class ActivationTreeWrap(Module):
    def __init__(self, function):
        super().__init__()
        self.function = function

    def forward(self, x):
        return (self.function(x[0]), x[1])

class LayerNormTree(Module):
    EPS = 0.000001
    def forward(self, flatened_tree_and_indexes):
        data, indexes = flatened_tree_and_indexes
        mean = torch.mean(data, dim=(1, 2)).unsqueeze(1).unsqueeze(1)
        std = torch.std(data, dim=(1, 2)).unsqueeze(1).unsqueeze(1)
        normd = (data - mean) / (std + self.EPS)
        return (normd, indexes)
    
class DynamicPoolingTree(Module):
    def forward(self, x):
        return torch.max(x[0], dim=2).values
    
