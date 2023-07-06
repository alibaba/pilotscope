# from: https://raw.githubusercontent.com/cmu-db/ottertune/master/server/analysis/ddpg/ddpg.py

import pickle
import torch
torch.set_num_threads(1)
import numpy as np
import torch.nn as nn
import torch.optim as optimizer
from torch.autograd import Variable

from ddpg.prm import PrioritizedReplayMemory

class Actor(nn.Module):

    def __init__(self, n_states, n_actions, hidden_sizes, use_default):
        super(Actor, self).__init__()
        if use_default:
            self.layers = nn.Sequential(
                nn.Linear(n_states, 128),
                nn.LeakyReLU(negative_slope=0.2),
                nn.BatchNorm1d(hidden_sizes[0]),
                nn.Linear(128, 128),
                nn.Tanh(),
                nn.Dropout(0.3),
                nn.Linear(128, 128),
                nn.Tanh(),
                nn.Linear(128, 64),
                nn.Linear(64, n_actions)
            )
        else:
            self.layers = nn.Sequential(
                nn.Linear(n_states, hidden_sizes[0]),
                nn.LeakyReLU(negative_slope=0.2),
                nn.BatchNorm1d(hidden_sizes[0]),
                nn.Linear(hidden_sizes[0], hidden_sizes[1]),
                nn.Tanh(),
                nn.Dropout(0.3),
                nn.BatchNorm1d(hidden_sizes[1]),
                nn.Linear(hidden_sizes[1], hidden_sizes[2]),
                nn.Tanh(),
                nn.Dropout(0.3),
                nn.BatchNorm1d(hidden_sizes[2]),
                nn.Linear(hidden_sizes[2], n_actions)
            )
        # This act layer maps the output to (0, 1)
        self.act = nn.Sigmoid()
        self._init_weights()

    def _init_weights(self):

        for m in self.layers:
            if isinstance(m, nn.Linear):
                m.weight.data.normal_(0.0, 1e-2)
                m.bias.data.uniform_(-0.1, 0.1)

    def forward(self, states):  # pylint: disable=arguments-differ

        actions = self.act(self.layers(states))
        return actions


class Critic(nn.Module):

    def __init__(self, n_states, n_actions, hidden_sizes, use_default):
        super(Critic, self).__init__()
        self.act = nn.Tanh()
        if use_default:
            self.state_input = nn.Linear(n_states, 128)
            self.action_input = nn.Linear(n_actions, 128)
            self.layers = nn.Sequential(
                nn.Linear(256, 256),
                nn.LeakyReLU(negative_slope=0.2),
                nn.BatchNorm1d(256),
                nn.Linear(256, 256),
                nn.Linear(256, 64),
                nn.Tanh(),
                nn.Dropout(0.3),
                nn.BatchNorm1d(64),
                nn.Linear(64, 1)
            )
        else:
            self.state_input = nn.Linear(n_states, hidden_sizes[0])
            self.action_input = nn.Linear(n_actions, hidden_sizes[0])
            self.layers = nn.Sequential(
                nn.Linear(hidden_sizes[0] * 2, hidden_sizes[1]),
                nn.LeakyReLU(negative_slope=0.2),
                nn.Dropout(0.3),
                nn.BatchNorm1d(hidden_sizes[1]),
                nn.Linear(hidden_sizes[1], hidden_sizes[2]),
                nn.Tanh(),
                nn.Dropout(0.3),
                nn.BatchNorm1d(hidden_sizes[2]),
                nn.Linear(hidden_sizes[2], 1)
            )
        self._init_weights()

    def _init_weights(self):
        self.state_input.weight.data.normal_(0.0, 1e-2)
        self.state_input.bias.data.uniform_(-0.1, 0.1)

        self.action_input.weight.data.normal_(0.0, 1e-2)
        self.action_input.bias.data.uniform_(-0.1, 0.1)

        for m in self.layers:
            if isinstance(m, nn.Linear):
                m.weight.data.normal_(0.0, 1e-2)
                m.bias.data.uniform_(-0.1, 0.1)

    def forward(self, states, actions):  # pylint: disable=arguments-differ
        states = self.act(self.state_input(states))
        actions = self.act(self.action_input(actions))

        _input = torch.cat([states, actions], dim=1)
        value = self.layers(_input)
        return value

class OUProcess(object):
    def __init__(self, n_actions, theta=0.15, mu=0, sigma=0.1, ):

        self.n_actions = n_actions
        self.theta = theta
        self.mu = mu
        self.sigma = sigma
        self.current_value = np.ones(self.n_actions) * self.mu

    def reset(self, sigma=0, theta=0):
        self.current_value = np.ones(self.n_actions) * self.mu
        if sigma != 0:
            self.sigma = sigma
        if theta != 0:
            self.theta = theta

    def noise(self):
        x = self.current_value
        dx = self.theta * (self.mu - x) + self.sigma * np.random.randn(len(x))
        self.current_value = x + dx
        return self.current_value


class DDPG(object):

    def __init__(self, n_states, n_actions, model_name='', alr=0.001, clr=0.001,
                 gamma=0.9, batch_size=32, tau=0.002, shift=0, memory_size=100000,
                 a_hidden_sizes=[128, 128, 64], c_hidden_sizes=[128, 256, 64],
                 use_default=False):
        self.n_states = n_states
        self.n_actions = n_actions
        self.alr = alr
        self.clr = clr
        self.model_name = model_name
        self.batch_size = batch_size
        self.gamma = gamma
        self.tau = tau
        self.a_hidden_sizes = a_hidden_sizes
        self.c_hidden_sizes = c_hidden_sizes
        self.shift = shift
        self.use_default = use_default

        self._build_network()

        self.replay_memory = PrioritizedReplayMemory(capacity=memory_size)
        self.noise = OUProcess(n_actions)

    @staticmethod
    def totensor(x):
        return Variable(torch.FloatTensor(x))

    def _build_network(self):
        self.actor = Actor(self.n_states, self.n_actions, self.a_hidden_sizes, self.use_default)
        self.target_actor = Actor(self.n_states, self.n_actions, self.a_hidden_sizes,
                                  self.use_default)
        self.critic = Critic(self.n_states, self.n_actions, self.c_hidden_sizes, self.use_default)
        self.target_critic = Critic(self.n_states, self.n_actions, self.c_hidden_sizes,
                                    self.use_default)

        # Copy actor's parameters
        self._update_target(self.target_actor, self.actor, tau=1.0)

        # Copy critic's parameters
        self._update_target(self.target_critic, self.critic, tau=1.0)

        self.loss_criterion = nn.MSELoss()
        self.actor_optimizer = optimizer.Adam(lr=self.alr, params=self.actor.parameters(),
                                              weight_decay=1e-5)
        self.critic_optimizer = optimizer.Adam(lr=self.clr, params=self.critic.parameters(),
                                               weight_decay=1e-5)

    @staticmethod
    def _update_target(target, source, tau):
        for (target_param, param) in zip(target.parameters(), source.parameters()):
            target_param.data.copy_(
                target_param.data * (1 - tau) + param.data * tau
            )

    def reset(self, sigma, theta):
        self.noise.reset(sigma, theta)

    def _sample_batch(self):
        batch, idx = self.replay_memory.sample(self.batch_size)
        states = list(map(lambda x: x[0].tolist(), batch))  # pylint: disable=W0141
        actions = list(map(lambda x: x[1].tolist(), batch))  # pylint: disable=W0141
        rewards = list(map(lambda x: x[2], batch))  # pylint: disable=W0141
        next_states = list(map(lambda x: x[3].tolist(), batch))  # pylint: disable=W0141

        return idx, states, next_states, actions, rewards

    def add_sample(self, state, action, reward, next_state):
        self.critic.eval()
        self.actor.eval()
        self.target_critic.eval()
        self.target_actor.eval()
        batch_state = self.totensor([state.tolist()])
        batch_next_state = self.totensor([next_state.tolist()])
        current_value = self.critic(batch_state, self.totensor([action.tolist()]))
        target_action = self.target_actor(batch_next_state)
        target_value = self.totensor([reward]) \
            + self.target_critic(batch_next_state, target_action) * self.gamma
        error = float(torch.abs(current_value - target_value).data.numpy()[0])

        self.target_actor.train()
        self.actor.train()
        self.critic.train()
        self.target_critic.train()
        self.replay_memory.add(error, (state, action, reward, next_state))

    def update(self):
        idxs, states, next_states, actions, rewards = self._sample_batch()
        batch_states = self.totensor(states)
        batch_next_states = self.totensor(next_states)
        batch_actions = self.totensor(actions)
        batch_rewards = self.totensor(rewards)

        target_next_actions = self.target_actor(batch_next_states).detach()
        target_next_value = self.target_critic(batch_next_states, target_next_actions).detach()
        current_value = self.critic(batch_states, batch_actions)
        batch_rewards = batch_rewards[:, None]
        next_value = batch_rewards + target_next_value * self.gamma + self.shift

        # update prioritized memory
        if isinstance(self.replay_memory, PrioritizedReplayMemory):
            error = torch.abs(current_value - next_value).data.numpy()
            for i in range(self.batch_size):
                idx = idxs[i]
                self.replay_memory.update(idx, error[i][0])

        # Update Critic
        loss = self.loss_criterion(current_value, next_value)
        self.critic_optimizer.zero_grad()
        loss.backward()
        self.critic_optimizer.step()

        # Update Actor
        self.critic.eval()
        policy_loss = -self.critic(batch_states, self.actor(batch_states))
        policy_loss = policy_loss.mean()
        self.actor_optimizer.zero_grad()
        policy_loss.backward()

        self.actor_optimizer.step()
        self.critic.train()

        self._update_target(self.target_critic, self.critic, tau=self.tau)
        self._update_target(self.target_actor, self.actor, tau=self.tau)

        return loss.data, policy_loss.data

    def choose_action(self, states):
        self.actor.eval()
        act = self.actor(self.totensor([states.tolist()])).squeeze(0)
        self.actor.train()
        action = act.data.numpy()
        action += self.noise.noise()
        return action.clip(0, 1)

    def set_model(self, actor_dict, critic_dict):
        self.actor.load_state_dict(pickle.loads(actor_dict))
        self.critic.load_state_dict(pickle.loads(critic_dict))

    def get_model(self):
        return pickle.dumps(self.actor.state_dict()), pickle.dumps(self.critic.state_dict())


import ConfigSpace as CS
import ConfigSpace.hyperparameters as CSH

class DDPGOptimizer:
    def __init__(self, state, model, func, initial_design, rand_conf_chooser,
                    n_iters, logging_dir=None):
        assert state.target_metric == 'throughput'

        self.state = state
        self.model = model
        self.func = func
        self.initial_design = initial_design
        self.input_space = initial_design.cs
        self.rand_conf_chooser = rand_conf_chooser
        self.n_iters = n_iters
        self.n_epochs = 2 # same value as CDBTune

        self.logging_dir = logging_dir

    def run(self):
        prev_perf = self.state.default_perf
        assert prev_perf >= 0

        results = [ ]

        # Bootstrap with random samples
        init_configurations = self.initial_design.select_configurations()
        for i, knob_data in enumerate(init_configurations):
            print(f'Iter {i} -- RANDOM')
            ### reward, metric_data = env.simulate(knob_data)
            # metrics & perf
            perf, metric_data = self.func(knob_data)
            perf = -perf # maximize
            assert perf >= 0
            # compute reward
            reward = self.get_reward(perf, prev_perf)
            # LOG
            print(f'Iter {i} -- PERF = {perf}')
            print(f'Iter {i} -- METRICS = {metric_data}')
            print(f'Iter {i} -- REWARD = {reward}')

            if i > 0:
                self.model.add_sample(prev_metric_data, prev_knob_data, prev_reward, metric_data)

            prev_metric_data = metric_data
            prev_knob_data = knob_data.get_array() # scale to [0, 1]
            prev_reward = reward
            prev_perf = perf

        # add last random sample
        self.model.add_sample(prev_metric_data, prev_knob_data, prev_reward, metric_data)

        # Start guided search
        for i in range(len(init_configurations), self.n_iters):

            if self.rand_conf_chooser.check(i):
                print(f'Iter {i} -- RANDOM SAMPLE')
                # get random sample from config space
                knob_data = self.input_space.sample_configuration()
                knob_data_vector = knob_data.get_array()
            else:
                print(f'Iter {i} -- GUIDED')
                # get next recommendation from DDPG
                knob_data_vector = self.model.choose_action(prev_metric_data)
                knob_data = self.convert_from_vector(knob_data_vector)

            # metrics & perf
            perf, metric_data = self.func(knob_data)
            perf = -perf # maximize
            assert perf >= 0
            # compute reward
            reward = self.get_reward(perf, prev_perf)
            # LOG
            print(f'Iter {i} -- PERF = {perf}')
            print(f'Iter {i} -- METRICS = {metric_data}')
            print(f'Iter {i} -- REWARD = {reward}')

            # register point to the optimizer
            self.model.add_sample(prev_metric_data, prev_knob_data, prev_reward, metric_data)

            prev_metric_data = metric_data
            prev_knob_data = knob_data_vector
            prev_reward = reward
            prev_perf = perf

            # update DDPG model
            if len(self.model.replay_memory) >= self.model.batch_size:
                for _ in range(self.n_epochs):
                    self.model.update()
            print('AFTER UPDATE')

    def get_reward(self, perf, prev_perf):
        """ Reward calculation same as CDBTune paper -- Section 4.2 """
        def calculate_reward(delta_default, delta_prev):
            if delta_default > 0:
                reward =   ((1 + delta_default) ** 2 - 1) * np.abs(1 + delta_prev)
            else:
                reward = - ((1 - delta_default) ** 2 - 1) * np.abs(1 - delta_prev)

            # no improvement over last evaluation -- 0 reward
            if reward > 0 and delta_prev < 0:
                reward = 0

            return reward

        if perf == self.state.worse_perf:
            return 0

        # perf diff from default / prev evaluation
        delta_default = (perf - self.state.default_perf) / self.state.default_perf
        delta_prev = (perf - prev_perf) / prev_perf

        return calculate_reward(delta_default, delta_prev)

    def convert_from_vector(self, vector):
        from adapters.bias_sampling import special_value_scaler, UniformIntegerHyperparameterWithSpecialValue

        values = { }
        for hp, value in zip(self.input_space.get_hyperparameters(), vector):

            if isinstance(hp, CSH.NumericalHyperparameter):
                if isinstance(hp, UniformIntegerHyperparameterWithSpecialValue):
                    value = special_value_scaler(hp, value)
                else:
                    value = hp._transform(value)
            elif isinstance(hp, CSH.CategoricalHyperparameter):
                assert hp.num_choices == 2
                value = hp.choices[0] if value <= 0.5 else hp.choices[1]
            else:
                raise NotImplementedError()

            values[hp.name] = value

        conf = CS.Configuration(self.input_space, values=values)
        self.input_space.check_configuration(conf)
        return conf

