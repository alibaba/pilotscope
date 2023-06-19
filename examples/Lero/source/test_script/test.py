import argparse

from utils import *

# python test.py --query_path ../reproduce/test_query/stats.txt --output_query_latency_file stats.test
if __name__ == "__main__":
    parser = argparse.ArgumentParser("Model training helper")
    parser.add_argument("--query_path",
                        metavar="PATH",
                        help="Load the queries")
    parser.add_argument("--output_query_latency_file", metavar="PATH")

    args = parser.parse_args()
    test_queries = []
    with open(args.query_path, 'r') as f:
        for line in f.readlines():
            arr = line.strip().split("#####")
            test_queries.append((arr[0], arr[1]))
    print("Read", len(test_queries), "test queries.")

    for (fp, q) in test_queries:
        do_run_query(q, fp, ["SET enable_lero TO True"], args.output_query_latency_file, True, None, None)
