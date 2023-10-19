from algorithm_examples.Mscn.source.mscn_utils import *
from algorithm_examples.Mscn.source.mscn_model import MscnModel

def print_qerror(preds_unnorm, labels_unnorm):
    qerror = []
    for i in range(len(preds_unnorm)):
        if preds_unnorm[i] > float(labels_unnorm[i]):
            qerror.append(preds_unnorm[i] / float(labels_unnorm[i]))
        else:
            qerror.append(float(labels_unnorm[i]) / float(preds_unnorm[i]))

    print("Median: {}".format(np.median(qerror)))
    print("90th percentile: {}".format(np.percentile(qerror, 90)))
    print("95th percentile: {}".format(np.percentile(qerror, 95)))
    print("99th percentile: {}".format(np.percentile(qerror, 99)))
    print("Max: {}".format(np.max(qerror)))
    print("Mean: {}".format(np.mean(qerror)))


def train_and_predict(train_query_path, train_token_path, test_path, schema_path, model_path, num_train):
    # Load training queries, labels and schema
    tokens, labels = load_tokens(train_query_path, train_token_path)
    db_control : PostgreSQLController = DBControllerFactory.get_db_controller(PostgreSQLConfig())
    schema = load_schema(db_control)
    model = MscnModel()
    tables, joins, predicates = tokens
    tokens = (tables[:num_train], joins[:num_train], predicates[:num_train])
    labels = labels[:num_train]
    print("Training Num: ", num_train)
    model.fit(tokens, labels, schema)
    model.save(model_path)
    
    # model test
    model.load(model_path)
    # Load test data
    queries, labels = load_queries(test_path)
    queries, labels =  queries[:100], labels[:100]
    print("Number of test samples: {}".format(len(labels)))
    _, preds_test_unnorm, t_total = model.predict(queries)
    print("Prediction time per test sample: {} ms".format(t_total / len(labels) * 1000))
    
    # Print metrics
    print("\nQ-Error: ")
    print_qerror(preds_test_unnorm, labels)


if __name__ == "__main__":
    train_path = "/PilotScopeCore/algorithm_examples/mscn/training_data.sql"
    token_path = "/PilotScopeCore/algorithm_examples/mscn/stats_train_tokens.csv"
    test_path = "/PilotScopeCore/algorithm_examples/mscn/training_data.sql"
    model_path = "./models/stats/"
    num_train = 1000
    train_and_predict(train_path, token_path, test_path, None, model_path, num_train)
