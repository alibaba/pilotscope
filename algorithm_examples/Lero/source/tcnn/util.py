import numpy as np
import torch

def get_tree_graph(root, find_left_child, find_right_child):
    
    nodes = []
    
    def dfs(x, idx=1):

        if find_left_child(x) is None and find_right_child(x) is None:
            nodes.append([idx, 0, 0])
            return idx

        def get_rightmost(tree):
            if isinstance(tree, tuple):
                return get_rightmost(tree[2])
            return tree
        
        left = dfs(find_left_child(x), idx=idx+1)
        
        max_idx_in_left = get_rightmost(left)
        right = dfs(find_right_child(x), idx=max_idx_in_left + 1)

        l_idx = left[0] if isinstance(left, tuple) else left
        r_idx = right[0] if isinstance(right, tuple) else right
        nodes.append([idx, l_idx, r_idx])
        return (idx, left, right)

    dfs(root)
    nodes.sort()
    return np.array(nodes).flatten().reshape(-1, 1)

def preorder_tree_walk(root, vectorize_node, find_left_child, find_right_child):
    
    lst = []

    def dfs(x):
        lst.append(vectorize_node(x))
        if find_left_child(x) is None and find_right_child(x) is None:
            return
        dfs(find_left_child(x))
        dfs(find_right_child(x))

    dfs(root)
    
    lst = [np.zeros(lst[0].shape)] + lst
    return np.array(lst)

def pading(data):
    assert len(data) >= 1
    assert len(data[0].shape) == 2

    for item in data:
        assert item.dtype != np.dtype("object")
    
    second_shape = data[0].shape[1]
    for item in data[1:]:
        assert item.shape[1] == second_shape

    max_first_dim = max(arr.shape[0] for arr in data)

    vectors = []
    for item in data:
        padded = np.zeros((max_first_dim, second_shape))
        padded[0 : item.shape[0]] = item
        vectors.append(padded)

    return np.array(vectors)

def prepare_trees(trees, transformer, find_left_child, find_right_child, cuda=False, device=None):
    flat_trees = [preorder_tree_walk(x, transformer, find_left_child, find_right_child) for x in trees]
    flat_trees = pading(flat_trees)
    flat_trees = torch.Tensor(flat_trees)

    flat_trees = flat_trees.transpose(1, 2)
    if cuda:
        flat_trees = flat_trees.cuda(device)
    indexes = [get_tree_graph(x, find_left_child, find_right_child) for x in trees]
    indexes = pading(indexes)
    indexes = torch.Tensor(indexes).long()
    if cuda:
        indexes = indexes.cuda(device)

    return (flat_trees, indexes)
                    

