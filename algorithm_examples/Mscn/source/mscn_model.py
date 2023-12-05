import os
import time
import joblib
import torch
from torch.autograd import Variable
from torch.utils.data import DataLoader

from algorithm_examples.Mscn.source.mscn_utils import Feature

import torch
import torch.nn as nn
import torch.nn.functional as F

# Define model architecture

class SetConv(nn.Module):
    def __init__(self, sample_feats, predicate_feats, join_feats, hid_units):
        super(SetConv, self).__init__()
        self.sample_mlp1 = nn.Linear(sample_feats, hid_units)
        self.sample_mlp2 = nn.Linear(hid_units, hid_units)
        self.predicate_mlp1 = nn.Linear(predicate_feats, hid_units)
        self.predicate_mlp2 = nn.Linear(hid_units, hid_units)
        self.join_mlp1 = nn.Linear(join_feats, hid_units)
        self.join_mlp2 = nn.Linear(hid_units, hid_units)
        self.out_mlp1 = nn.Linear(hid_units * 3, hid_units)
        self.out_mlp2 = nn.Linear(hid_units, 1)

    def forward(self, samples, predicates, joins, sample_mask, predicate_mask, join_mask):
        # samples has shape [batch_size x num_joins+1 x sample_feats]
        # predicates has shape [batch_size x num_predicates x predicate_feats]
        # joins has shape [batch_size x num_joins x join_feats]

        hid_sample = F.relu(self.sample_mlp1(samples))
        hid_sample = F.relu(self.sample_mlp2(hid_sample))
        hid_sample = hid_sample * sample_mask  # Mask
        hid_sample = torch.sum(hid_sample, dim=1, keepdim=False)
        sample_norm = sample_mask.sum(1, keepdim=False)
        hid_sample = hid_sample / sample_norm  # Calculate average only over non-masked parts

        hid_predicate = F.relu(self.predicate_mlp1(predicates))
        hid_predicate = F.relu(self.predicate_mlp2(hid_predicate))
        hid_predicate = hid_predicate * predicate_mask
        hid_predicate = torch.sum(hid_predicate, dim=1, keepdim=False)
        predicate_norm = predicate_mask.sum(1, keepdim=False)
        hid_predicate = hid_predicate / predicate_norm

        hid_join = F.relu(self.join_mlp1(joins))
        hid_join = F.relu(self.join_mlp2(hid_join))
        hid_join = hid_join * join_mask
        hid_join = torch.sum(hid_join, dim=1, keepdim=False)
        join_norm = join_mask.sum(1, keepdim=False)
        hid_join = hid_join / join_norm

        hid = torch.cat((hid_sample, hid_predicate, hid_join), 1)
        hid = F.relu(self.out_mlp1(hid))
        out = torch.sigmoid(self.out_mlp2(hid))
        return out

CUDA = torch.cuda.is_available()


def _nn_path(base):
    return os.path.join(base, "nn_weights")

def _feature_generator_path(base):
    return os.path.join(base, "feature_generator")

def _input_feature_dim_path(base):
    return os.path.join(base, "input_feature_dim")

def qerror_loss(preds, targets):
    qerror = []
    for i in range(len(targets)):
        if (preds[i] > targets[i]).cpu().data.numpy()[0]:
            qerror.append(preds[i] / targets[i])
        else:
            qerror.append(targets[i] / preds[i])
    return torch.mean(torch.cat(qerror))


class MscnModel():
    def __init__(self) -> None:
        self._net = None
        self._feature_generator = None
        # self._input_feature_dim is a tuple with (sample_feats, predicate_feats, join_feats, hid_units)
        self._input_feature_dim = None

    def load(self, path):
        with open(_input_feature_dim_path(path), "rb") as f:
            self._input_feature_dim = joblib.load(f)
        self._net = SetConv(*self._input_feature_dim)
        self._net.load_state_dict(torch.load_model(_nn_path(path)))
        self._net.eval()
        with open(_feature_generator_path(path), "rb") as f:
            self._feature_generator = joblib.load(f)

    def save(self, path):
        os.makedirs(path, exist_ok=True)
        torch.save_model(self._net.state_dict(), _nn_path(path))
        with open(_feature_generator_path(path), "wb") as f:
            joblib.dump(self._feature_generator, f)
        with open(_input_feature_dim_path(path), "wb") as f:
            joblib.dump(self._input_feature_dim, f)
            
    def fit(self, tokens, labels, schema, hid_units = 256, num_epochs = 100, batch_size = 2048):
        
        self._feature_generator=Feature()
        print(schema)
        train_data = self._feature_generator.fit(tokens, labels, schema)
        train_data_loader = DataLoader(train_data, batch_size=batch_size)
        
        self._input_feature_dim = (*self._feature_generator.feature_dim, hid_units)
        self._net = SetConv(*self._input_feature_dim)
        optimizer = torch.optim.Adam(self._net.parameters(), lr=0.001)
        
        if CUDA:
            self._net.cuda()
        self._net.train()
        
        start_time = time.time()
        for epoch in range(num_epochs):
            loss_total = 0.

            for batch_idx, data_batch in enumerate(train_data_loader):

                samples, predicates, joins, targets, sample_masks, predicate_masks, join_masks = data_batch

                if CUDA:
                    samples, predicates, joins, targets = samples.cuda(), predicates.cuda(), joins.cuda(), targets.cuda()
                    sample_masks, predicate_masks, join_masks = sample_masks.cuda(), predicate_masks.cuda(), join_masks.cuda()
                samples, predicates, joins, targets = Variable(samples), Variable(predicates), Variable(joins), Variable(
                    targets)
                sample_masks, predicate_masks, join_masks = Variable(sample_masks), Variable(predicate_masks), Variable(
                    join_masks)

                optimizer.zero_grad()
                outputs = self._net(samples, predicates, joins, sample_masks, predicate_masks, join_masks)
                preds = self._feature_generator.unnormalize_torch(outputs)
                targets = self._feature_generator.unnormalize_torch(targets.float())
                loss = qerror_loss(preds, targets)
                loss_total += loss.item()
                loss.backward()
                optimizer.step()
            print("Epoch {}, loss: {}".format(epoch, loss_total / len(train_data_loader)))
        print("training time:", time.time() - start_time, "batch size:", batch_size)
        
    def predict(self, queries):
        data = self._feature_generator.transform(queries)
        data_loader = DataLoader(data, batch_size=len(queries))
        preds = []
        t_total = 0.
        self._net.eval()
        for batch_idx, data_batch in enumerate(data_loader):

            samples, predicates, joins, targets, sample_masks, predicate_masks, join_masks = data_batch

            if CUDA:
                samples, predicates, joins, targets = samples.cuda(), predicates.cuda(), joins.cuda(), targets.cuda()
                sample_masks, predicate_masks, join_masks = sample_masks.cuda(), predicate_masks.cuda(), join_masks.cuda()
            samples, predicates, joins, targets = Variable(samples), Variable(predicates), Variable(joins), Variable(
                targets)
            sample_masks, predicate_masks, join_masks = Variable(sample_masks), Variable(predicate_masks), Variable(
                join_masks)

            t = time.time()
            outputs = self._net(samples, predicates, joins, sample_masks, predicate_masks, join_masks)
            t_total += time.time() - t
            for i in range(outputs.data.shape[0]):
                preds.append(outputs.data[i])
        preds_test_unnorm = self._feature_generator.unnormalize_labels(preds)
        return preds, preds_test_unnorm, t_total
        
    
