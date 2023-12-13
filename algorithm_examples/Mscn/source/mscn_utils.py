import os
import csv
import math
import time
import torch
import numpy as np
from algorithm_examples.Mscn.source.data import make_dataset, normalize_labels, get_all_column_names, get_set_encoding, get_all_table_names, get_all_operators, get_all_joins, chunks, normalize_data

from sqlglot import parse_one, exp
from sqlglot.tokens import Tokenizer
import sys
from pilotscope.DBController.PostgreSQLController import PostgreSQLController
from pilotscope.Factory.DBControllerFectory import DBControllerFactory
from pilotscope.PilotConfig import PilotConfig, PostgreSQLConfig

class QueryMetaData():
    def __init__(self, queryString, replace_alias=True) -> None:
        self.raw = queryString
        self.expression = parse_one(self.raw)
        self.tables = []
        self.table_alias = []
        self.names_to_alias = {}
        self.alias_to_names = {}
        self._parse_table()
        self.replace_alias = replace_alias
        self.sql_without_alias = self.raw
        self.expression_origin = self.expression
        if self.replace_alias:
            self._replace_table_alias()
        self.conditions = [] # Element Type: sqlglot.expressions.EQ. If need str type, use sql() method 
        self.joins = []      # Element Type: sqlglot.expressions.EQ. If need str type, use sql() method 
        self._parse_predicates()
        
    def _parse_table(self):
        for table in self.expression.find_all(exp.Table, bfs=False):
            self.tables.append(table.name)
            if table.alias:
                self.table_alias.append(table.alias)
                self.names_to_alias[table.name] = table.alias
                self.alias_to_names[table.alias] = table.name
                
    def _replace_table_alias(self):
        for k, v in self.alias_to_names.items():
            # print(k, v)
            self.sql_without_alias = self.sql_without_alias.replace(k+'.', v+'.')
        self.expression = parse_one(self.sql_without_alias)
        while self.expression.find(exp.TableAlias):
            self.expression.find(exp.TableAlias).pop()
        # print(self.expression)
    
    def _parse_predicates(self):
        for pre in self.expression.find_all(exp.Predicate, bfs=False):
            columns = list(pre.find_all(exp.Column, bfs=False))
            if len(columns)== 1:
                self.conditions.append(pre)
            elif len(columns) == 2:
                self.joins.append(pre)
            
    def __str__(self):
        return '\n'.join(["{}: {}".format(k, "[{}]".format(', '.join([s.sql() for s in v])) if (isinstance(v, list) and len(v) != 0 and hasattr(v[0], 'sql')) else v) for k, v in self.__dict__.items()])

class mscnQueryMeta(QueryMetaData):
    def __init__(self, queryString, replace_alias=True) -> None:
        super().__init__(queryString, replace_alias)
        self.conditions_tokens = []
        self._parse_conditions()
        
    def _parse_conditions(self):
        for cond in self.conditions:
            tokens = []
            column = cond.find(exp.Column)
            tokens.append(column.sql())
            op = Tokenizer().tokenize(cond.sql())[-2]
            tokens.append(op.text)
            value = cond.find(exp.Literal)
            tokens.append(value.sql())
            # if(not("." in tokens[0] or len(self.tables)==1)): # DEL it after dbg 
            #     print(self.raw)
            # assert "." in tokens[0] or len(self.tables)==1
            # if not '.' in tokens[0]:
            #     tokens[0] = self.tables[0]+"."+tokens[0]
            self.conditions_tokens.append(tokens)


class Feature():
    # The feature is related with vector_dicts, column_min_max_vals, label_min_max_val and samples (optional)
    
    # vector_dicts: a tuple with (table2vec, column2vec, op2vec, join2vec), which XXX2vec is a dict with XXX_name(key) and its one-hot code(value)
    # column_min_max_vals: a dict with table_name.column_name(key) and a tuple(value), which the tuple is (min val of the column, max val of the column)
    # label_min_max_val: a tuple with (min val of labels, max val of labels)
    # vector_dicts and label_min_max_val is from training data, and column_min_max_vals is from schema.
    
    # num_materialized_samples: a value, which is the number of samples for each table, only if with_samples is true, go into effect.
    # samples_dir: the directory of samples w.r.t each table, only if with_samples is true, go into effect.
    # with_samples: bool, default is false. If true, the model is with samples, else, the model is without samples.
    
    # feature_dim: a tuple with (sample_feats, predicate_feats, join_feats)
    def __init__(self) -> None:
        # init parameters
        self.table2vec = None
        self.column2vec = None
        self.op2vec = None
        self.join2vec = None
        self.column_min_max_vals = None
        self.label_min_val = None
        self.label_max_val = None
        
        # if need samples
        # self.num_materialized_samples = None
        # self.samples_dir = None
        # self.with_samples = None
        
        self.feature_dim = None
            
    # tokens = (tables, joins, predicates)
    def fit(self, tokens, labels, schema):
        tables, joins, predicates = tokens
        # Get column name dict
        column_names = get_all_column_names(predicates)
        self.column2vec, _ = get_set_encoding(column_names)

        # Get table name dict
        table_names = get_all_table_names(tables)
        self.table2vec, _ = get_set_encoding(table_names)

        # Get operator name dict
        operators = get_all_operators(predicates)
        self.op2vec, _ = get_set_encoding(operators)

        # Get join name dict
        join_set = get_all_joins(joins)
        self.join2vec, _ = get_set_encoding(join_set)
        
        # Get featrue size
        sample_feats = len(self.table2vec) 
        # if self.with_samples:
        #     sample_feats += self.num_materialized_samples
        predicate_feats = len(self.column2vec) + len(self.op2vec) + 1
        join_feats = len(self.join2vec)
        self.feature_dim = (sample_feats, predicate_feats, join_feats)

        # Get min and max values for each column
        self.column_min_max_vals = {}
        for table_name, table_dict in schema.items():
            # print(table_dict)
            for col_name, col_dict in table_dict["columns"].items():
                col_fullname = ".".join([table_name, col_name])
                # print(col_dict)
                self.column_min_max_vals[col_fullname] = [col_dict["min"], col_dict["max"]]

        # Get feature encoding and proper normalization
        # samples_enc = encode_samples(tables, samples, table2vec)
        samples_enc = encode_tables(tables, self.table2vec)
        predicates_enc, joins_enc = encode_conditions(predicates, joins, self.column_min_max_vals, self.column2vec, self.op2vec, self.join2vec)
        label_norm, self.label_min_val, self.label_max_val = normalize_labels(labels)
        max_num_predicates = max([len(p) for p in predicates_enc])
        max_num_joins = max([len(j) for j in predicates_enc])
        train_dataset = make_dataset(samples_enc, predicates_enc, joins_enc, label_norm, max_num_joins, max_num_predicates)
        return train_dataset
        
    def transform(self, queries):
        tables, joins, predicates = parse_queries(queries)
        # Get feature encoding and proper normalization
        # samples_enc = encode_samples(tables, samples, table2vec)
        labels = [math.exp(self.label_min_val)] * len(queries)
        samples_enc = encode_tables(tables, self.table2vec)
        predicates_enc, joins_enc = encode_conditions(predicates, joins, self.column_min_max_vals, self.column2vec, self.op2vec, self.join2vec)      
        label_norm, _, _ = normalize_labels(labels, self.label_min_val, self.label_max_val)
        max_num_joins = max([len(j) for j in joins_enc])
        max_num_predicates = max([len(p) for p in predicates_enc])
        transformed_dataset = make_dataset(samples_enc, predicates_enc, joins_enc, label_norm, max_num_joins, max_num_predicates)
        return transformed_dataset
    
    def unnormalize_torch(self, vals):
        vals = (vals * (self.label_max_val - self.label_min_val)) + self.label_min_val
        return torch.exp(vals)

    def unnormalize_labels(self, labels_norm):
        # print(labels_norm)
        labels_norm = np.array([x[0] for x in labels_norm], dtype=np.float32)
        labels = (labels_norm * (self.label_max_val - self.label_min_val)) + self.label_min_val
        return np.array(np.round(np.exp(labels)), dtype=np.int64)


# DeepDB style: query_no, query_str, true_card    
def load_queries(file_name):
    queries = []
    labels = []
    print("Load queries: ", file_name)
    with open(file_name) as f:
        lines = f.readlines()
        for i, row in enumerate(lines):
            row = row.split("||")
            if int(row[1]) >0:
                queries.append(row[0])
                labels.append(int(row[1]))
    print("Load {} queries done!".format(len(labels)))
    return queries, labels

def load_schema(db_control: PostgreSQLController):
    PG_NUMERIC_TYPES = set(['SMALLINT', 'INTEGER', 'BIGINT', 'DECIMAL', 'NUMERIC', 'REAL', 'DOUBLE PRECISION', 
        'SMALLSERIAL', 'SERIAL', 'BIGSERIAL'])
    PG_TIMESTEMP_TYPES = set(['TIMESTAMP'])
    def get_table_info(table_name):
        res = dict()
        res['rows'] = db_control.get_table_row_count(table_name)
        cols = db_control.get_table_columns(table_name)
        res['columns'] = dict()
        for col in cols:
            col_info = dict()
            col_info["dtype"] = str(db_control._get_sqla_table(table_name).c[col].type)
            col_info["ndv"] = db_control.get_number_of_distinct_value(table_name, col)
            if col_info["dtype"] in PG_NUMERIC_TYPES or col_info["dtype"] in PG_TIMESTEMP_TYPES:
                col_info["max"] = db_control.get_column_max(table_name, col)
                col_info["min"] = db_control.get_column_min(table_name, col)
            res['columns'][col] = col_info
        return res
    table_2_info={}
    for table in db_control.get_all_table_names():
        table_2_info[table]=get_table_info(table)
    return table_2_info

# parse queries into tokens with mscn style
def parse_queries(queries):
        joins = []
        predicates = []
        tables = []
        for sql in queries:
            meta_data = mscnQueryMeta(sql)
            join = [join.sql() for join in meta_data.joins]
            predicate = meta_data.conditions_tokens
            joins.append(join if len(join) != 0 else [""])
            predicates.append(predicate if len(predicate) != 0 else [""])
            tables.append(meta_data.tables)
        return tables, joins, predicates
    
# load tokens from token_file(MSCN style) or query_file(DeepDB style)
# if token_file does not exist, load query_file, parse queries into tokens and dump tokens into token_file
def load_tokens(query_file, token_file):
        if os.path.exists(token_file):
            print("Load tokens from: ", token_file)
            tables, joins, predicates, labels = [], [], [], []
            with open(token_file, 'rU') as f:
                data_raw = list(list(rec) for rec in csv.reader(f, delimiter='#'))
                for row in data_raw:
                    tables.append(row[0].split(','))
                    joins.append(row[1].split(','))
                    predicates.append(row[2].split(','))
                    if int(row[3]) < 1:
                        print("Queries must have non-zero cardinalities")
                        exit(1)
                    labels.append(row[3])
            predicates = [list(chunks(d, 3)) for d in predicates]
        else:
            print("Load queries from: ", query_file)
            queries, labels = load_queries(query_file)
            print("Parsing queries ...")
            start = time.time()
            tables, joins, predicates = parse_queries(queries)
            total = time.time()-start
            print("Parsing time per query: {:.2f} ms and all: {:.2f} s".format(total / len(queries) * 1000, total))
            print("Dump tokens to: ", token_file)
            with open(token_file, 'w', newline='') as f:
                w = csv.writer(f, delimiter='#')
                for i in range(len(labels)):
                    table = ",".join(tables[i])
                    join = ",".join(joins[i])
                    preds = [p for pred in predicates[i] for p in pred]
                    pred = ",".join(preds)
                    row = (table, join, pred, labels[i])
                    w.writerow(row)
        print("Loaded tokens")
        tokens = (tables, joins, predicates)
        return tokens, labels

# Convert sql queries with MSCN style to queries with DeepDB style
# MSCN style: query_tables, query_joins, query_filters, true_card
# DeepDB style: query_no, query_str, true_card
def convertQueries(source_file, target_file):
    csv_rows = []
    with open(source_file, 'rU') as f:
        data_raw = list(list(rec) for rec in csv.reader(f, delimiter='#'))
        for i, row in enumerate(data_raw):
            table = row[0].split(',')
            join = row[1].split(',')
            predicate = row[2].split(',')
            label = row[3]
            
            if join[0] == "":
                join = []
            if predicate[0] == "":
                predicate = []
            predicate = ["".join(predicate[i:i+3]) for i in range(0,len(predicate),3)]
            wheres = join + predicate
            query_str = "SELECT COUNT(*) FROM " + ", ".join(table)
            if wheres:
                query_str += (" WHERE " + " AND ".join(wheres))
            # try:
            #     parse_one(query_str)
            #     # print("SUCCESS: ", query_str)
            # except errors.ParseError as e:
            #     print("ERROR: ", query_str)
            #     print(e.errors)
            
            csv_rows.append({'query_no': i,
                         'query': query_str,
                         'cardinality_true': label})
    print("Loaded queries")

    with open(target_file, 'w', newline='') as f:
        w = csv.DictWriter(f, csv_rows[0].keys())
        for i, row in enumerate(csv_rows):
            if i == 0:
                w.writeheader()
            w.writerow(row)


def encode_tables(tables, table2vec):
    tables_enc = []
    for i, query in enumerate(tables):
        tables_enc.append(list())
        for j, table in enumerate(query):
            tables_vec = []
            # Append table one-hot vector
            tables_vec.append(table2vec[table])
            tables_enc[i].append(tables_vec)
    return tables_enc


def encode_conditions(predicates, joins, column_min_max_vals, column2vec, op2vec, join2vec):
    predicates_enc = []
    joins_enc = []
    for i, query in enumerate(predicates):
        predicates_enc.append(list())
        joins_enc.append(list())
        for predicate in query:
            if len(predicate) == 3:
                # Proper predicate
                column = predicate[0]
                operator = predicate[1]
                val = predicate[2]
                norm_val = normalize_data(val, column, column_min_max_vals)

                pred_vec = []
                pred_vec.append(column2vec[column])
                pred_vec.append(op2vec[operator])
                pred_vec.append(norm_val)
                pred_vec = np.hstack(pred_vec)
            else:
                pred_vec = np.zeros((len(column2vec) + len(op2vec) + 1))

            predicates_enc[i].append(pred_vec)

        for predicate in joins[i]:
            # Join instruction
            if predicate not in join2vec.keys():
                l = predicate.split(' = ')
                l.reverse()
                predicate = ' = '.join(l)
            if predicate in join2vec.keys(): # NOT SURE: TO IGNORE UNKNOWN JOIN
                join_vec = join2vec[predicate]   
                joins_enc[i].append(join_vec)
    return predicates_enc, joins_enc