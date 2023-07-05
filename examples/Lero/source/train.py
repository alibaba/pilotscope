import argparse
import math

from pandas import DataFrame

from Dao.PilotTrainDataManager import PilotTrainDataManager
from feature import *
from model import LeroModel, LeroModelPairWise


def _load_pointwise_plans(path):
    with open(path, "r") as f:
        return [line.strip() for line in f.readlines()]


def _load_pairwise_plans(path):
    X1, X2 = [], []
    with open(path, 'r') as f:
        for line in f.readlines():
            arr = line.split("#####")
            x1, x2 = get_training_pair(arr)
            X1 += x1
            X2 += x2
    return X1, X2


def get_training_pair(candidates):
    assert len(candidates) >= 2
    X1, X2 = [], []

    i = 0
    while i < len(candidates) - 1:
        s1 = candidates[i]
        j = i + 1
        while j < len(candidates):
            s2 = candidates[j]
            X1.append(s1)
            X2.append(s2)
            j += 1
        i += 1
    return X1, X2


def compute_rank_score(path, pretrain=False, rank_score_type=0):
    X, Y = [], []
    with open(path, 'r') as f:
        for line in f.readlines():
            arr = line.split("#####")
            if pretrain:
                arr = [(json.loads(p)[0]['Plan']['Total Cost'], p)
                       for p in arr]
            else:
                arr = [(json.loads(p)[0]['Execution Time'], p) for p in arr]
            sorted_arr = sorted(arr, key=lambda x: x[0])

            for i in range(len(sorted_arr)):
                X.append(sorted_arr[i][1])
                if rank_score_type == 0:
                    # 1. x^2
                    print("X^2")
                    Y.append(float((i + 1) ** 2))
                elif rank_score_type == 1:
                    # 2. x^4
                    print("X^4")
                    Y.append(float((i + 1) ** 4))
                elif rank_score_type == 2:
                    # 3. e^x
                    print("e^X")
                    Y.append(float(math.exp(i + 1)))
                elif rank_score_type == 3:
                    # 3. x^1
                    print("X^1")
                    Y.append(float((i + 1)))
    return X, Y


def training_pairwise(tuning_model_path, model_name, training_data_file, pretrain=False):
    X1, X2 = _load_pairwise_plans(training_data_file)

    tuning_model = tuning_model_path is not None
    lero_model = None
    if tuning_model:
        lero_model = LeroModelPairWise(None)
        lero_model.load(tuning_model_path)
        feature_generator = lero_model._feature_generator
    else:
        feature_generator = FeatureGenerator()
        feature_generator.fit(X1 + X2)

    Y1, Y2 = None, None
    if pretrain:
        Y1 = [json.loads(c)[0]['Plan']['Total Cost'] for c in X1]
        Y2 = [json.loads(c)[0]['Plan']['Total Cost'] for c in X2]
        X1, _ = feature_generator.transform(X1)
        X2, _ = feature_generator.transform(X2)
    else:
        X1, Y1 = feature_generator.transform(X1)
        X2, Y2 = feature_generator.transform(X2)
    print("Training data set size = " + str(len(X1)))

    if not tuning_model:
        assert lero_model == None
        lero_model = LeroModelPairWise(feature_generator)
    lero_model.fit(X1, X2, Y1, Y2, tuning_model)

    print("saving model...")
    lero_model.save(model_name)


def training_pairwise_pilot_score(lero_model, X1, X2):
    tuning_model = lero_model is not None and lero_model._feature_generator is not None
    if tuning_model:
        feature_generator = lero_model._feature_generator
    else:
        feature_generator = FeatureGenerator()
        feature_generator.fit(X1 + X2)
        lero_model = LeroModelPairWise(feature_generator)

    Y1, Y2 = None, None

    X1, Y1 = feature_generator.transform(X1)
    X2, Y2 = feature_generator.transform(X2)
    print("Training data set size = " + str(len(X1)))

    lero_model.fit(X1, X2, Y1, Y2, tuning_model)

    return lero_model


def _load_pairwise_plans_from_pilot(pilot_dada_dao: PilotTrainDataManager):
    pass
    # X1, X2 = [], []
    # data: DataFrame = pilot_dada_dao.read_all("lero")
    # # X1=
    #
    # with open(path, 'r') as f:
    #     for line in f.readlines():
    #         arr = line.split("#####")
    #         x1, x2 = get_training_pair(arr)
    #         X1 += x1
    #         X2 += x2
    # return X1, X2


def training_with_rank_score(tuning_model_path, model_name, training_data_file, pretrain=False, rank_score_type=0):
    X, Y = compute_rank_score(training_data_file, pretrain, rank_score_type)

    tuning_model = tuning_model_path is not None
    lero_model = None
    if tuning_model:
        lero_model = LeroModel(None)
        lero_model.load(tuning_model_path)
        feature_generator = lero_model._feature_generator
    else:
        feature_generator = FeatureGenerator()
        feature_generator.fit(X)

    # replace lantency with rank score
    local_features, _ = feature_generator.transform(X)
    assert len(local_features) == len(Y)
    print("Training data set size = " + str(len(local_features)))

    if not tuning_model:
        assert lero_model == None
        lero_model = LeroModel(feature_generator)

    lero_model.fit(local_features, Y, tuning_model)

    print("saving model...")
    lero_model.save(model_name)


def training_pointwise(tuning_model_path, model_name, training_data_file):
    X = _load_pointwise_plans(training_data_file)

    tuning_model = tuning_model_path is not None
    lero_model = None
    if tuning_model:
        lero_model = LeroModel(None)
        lero_model.load(tuning_model_path)
        feature_generator = lero_model._feature_generator
    else:
        feature_generator = FeatureGenerator()
        feature_generator.fit(X)

    local_features, y = feature_generator.transform(X)
    assert len(local_features) == len(y)
    print("Training data set size = " + str(len(local_features)))

    if not tuning_model:
        assert lero_model == None
        lero_model = LeroModel(feature_generator)

    lero_model.fit(local_features, y, tuning_model)

    print("saving model...")
    lero_model.save(model_name)


if __name__ == "__main__":
    parser = argparse.ArgumentParser("Model training helper")
    parser.add_argument("--training_data",
                        metavar="PATH",
                        help="Load the queries")
    parser.add_argument("--training_type", type=int)
    parser.add_argument("--model_name", type=str)
    parser.add_argument("--pretrain_model_name", type=str)
    parser.add_argument("--rank_score_training_type", type=int)

    args = parser.parse_args()

    training_type = 0
    if args.training_type is not None:
        training_type = args.training_type
    print("training_type:", training_type)

    training_data = None
    if args.training_data is not None:
        training_data = args.training_data
    print("training_data:", training_data)

    model_name = None
    if args.model_name is not None:
        model_name = args.model_name
    print("model_name:", model_name)

    pretrain_model_name = None
    if args.pretrain_model_name is not None:
        pretrain_model_name = args.pretrain_model_name
    print("pretrain_model_name:", pretrain_model_name)

    rank_score_training_type = 0
    if args.rank_score_training_type is not None:
        rank_score_training_type = args.rank_score_training_type
    print("rank_score_training_type:", rank_score_training_type)

    if training_type == 0:
        print("training_pointwise")
        training_pointwise(pretrain_model_name, model_name, training_data)
    elif training_type == 1:
        print("training_pairwise")
        training_pairwise(pretrain_model_name, model_name,
                          training_data, False)
    elif training_type == 2:
        print("training_with_rank_score")
        training_with_rank_score(
            pretrain_model_name, model_name, training_data, False, rank_score_training_type)
    elif training_type == 3:
        print("pre-training_pairwise")
        training_pairwise(pretrain_model_name, model_name,
                          training_data, True)
    elif training_type == 4:
        print("pre-training_with_rank_score")
        training_with_rank_score(
            pretrain_model_name, model_name, training_data, True, rank_score_training_type)
    else:
        raise Exception()
