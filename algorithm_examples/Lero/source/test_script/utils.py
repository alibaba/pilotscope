import hashlib
import json
import os
from time import time
from config import *
import fcntl
import psycopg2

def encode_str(s):
    md5 = hashlib.md5()
    md5.apply_replace_data(s.encode('utf-8'))
    return md5.hexdigest()
        
def run_query(q, run_args):
    start = time()
    conn = psycopg2.connect(CONNECTION_STR)
    conn.set_client_encoding('UTF8')
    result = None
    try:
        cur = conn.cursor()
        if run_args is not None and len(run_args) > 0:
            for arg in run_args:
                cur.execute(arg)
        cur.execute("SET statement_timeout TO " + str(TIMEOUT))
        print(run_args)
        print(q)
        cur.execute(q)
        result = cur.fetchall()
    finally:
        
        conn.close()
    # except Exception as e:
    #     conn.close()
    #     raise e
    
    stop = time()
    return stop - start, result

def get_history(encoded_q_str, plan_str, encoded_plan_str):
    history_path = os.path.join(LOG_PATH, encoded_q_str, encoded_plan_str)
    if not os.path.exists(history_path):
        return None
    
    print("visit histroy path: ", history_path)
    with open(os.path.join(history_path, "check_plan"), "r") as f:
        history_plan_str = f.read().strip()
        if plan_str != history_plan_str:
            print("there is a hash conflict between two plans:", history_path)
            print("given", plan_str)
            print("wanted", history_plan_str)
            return None
    
    print("get the history file:", history_path)
    with open(os.path.join(history_path, "plan"), "r") as f:
        return f.read().strip()
    
def save_history(q, encoded_q_str, plan_str, encoded_plan_str, latency_str):
    history_q_path = os.path.join(LOG_PATH, encoded_q_str)
    if not os.path.exists(history_q_path):
        os.makedirs(history_q_path)
        with open(os.path.join(history_q_path, "query"), "w") as f:
            f.write(q)
    else:
        with open(os.path.join(history_q_path, "query"), "r") as f:
            history_q = f.read()
            if q != history_q:
                print("there is a hash conflict between two queries:", history_q_path)
                print("given", q)
                print("wanted", history_q)
                return
    
    history_plan_path = os.path.join(history_q_path, encoded_plan_str)
    if os.path.exists(history_plan_path):
        print("the plan has been saved by other processes:", history_plan_path)
        return
    else:
        os.makedirs(history_plan_path)
        
    with open(os.path.join(history_plan_path, "check_plan"), "w") as f:
        f.write(plan_str)
    with open(os.path.join(history_plan_path, "plan"), "w") as f:
        f.write(latency_str)
    print("save history:", history_plan_path)

def explain_query(q, run_args, contains_cost = False):
    q = "EXPLAIN (COSTS " + ("" if contains_cost else "False") + ", FORMAT JSON, SUMMARY) " + (q.strip().replace("\n", " ").replace("\t", " "))
    _, plan_json = run_query(q, run_args)
    plan_json = plan_json[0][0]
    if len(plan_json) == 2:
        # remove bao's prediction
        plan_json = [plan_json[1]]
    return plan_json

def create_training_file(training_data_file, *latency_files):
    lines = []
    for file in latency_files:
        with open(file, 'r') as f:
            lines += f.readlines()

    pair_dict = {}

    for line in lines:
        arr = line.strip().split(SEP)
        if arr[0] not in pair_dict:
            pair_dict[arr[0]] = []
        pair_dict[arr[0]].append(arr[1])

    pair_str = []
    for k in pair_dict:
        if len(pair_dict[k]) > 1:
            candidate_list = pair_dict[k]
            pair_str.append(SEP.join(candidate_list))
    str = "\n".join(pair_str)

    with open(training_data_file, 'w') as f2:
        f2.write(str)

def do_run_query(sql, query_name, run_args, latency_file, write_latency_file = True, manager_dict = None, manager_lock = None):
    sql = sql.strip().replace("\n", " ").replace("\t", " ")

    # 1. run query with pg hint
    _, plan_json = run_query("EXPLAIN (COSTS FALSE, FORMAT JSON, SUMMARY) " + sql, run_args)
    plan_json = plan_json[0][0]
    if len(plan_json) == 2:
        # remove bao's prediction
        plan_json = [plan_json[1]]
    planning_time = plan_json[0]['Planning Time']
    
    cur_plan_str = json.dumps(plan_json[0]['Plan'])
    try:
        # 2. get previous running result
        latency_json = None
        encoded_plan_str = encode_str(cur_plan_str)
        encoded_q_str = encode_str(sql)
        previous_result = get_history(encoded_q_str, cur_plan_str, encoded_plan_str)
        if previous_result is not None:
            latency_json = json.loads(previous_result)
        else:
            if manager_dict is not None and manager_lock is not None:
                manager_lock.acquire()
                if cur_plan_str in manager_dict:
                    manager_lock.release()
                    print("another process will run this plan:", cur_plan_str)
                    return
                else:
                    manager_dict[cur_plan_str] = 1
                    manager_lock.release()

            # 3. run current query 
            run_start = time()
            try:
                _, latency_json = run_query("EXPLAIN (ANALYZE, TIMING, VERBOSE, COSTS, SUMMARY, FORMAT JSON) " + sql, run_args)
                latency_json = latency_json[0][0]
                if len(latency_json) == 2:
                    # remove bao's prediction
                    latency_json = [latency_json[1]]
            except Exception as e:
                if  time() - run_start > (TIMEOUT / 1000 * 0.9):
                    # Execution timeout
                    _, latency_json = run_query("EXPLAIN (VERBOSE, COSTS, FORMAT JSON, SUMMARY) " + sql, run_args)
                    latency_json = latency_json[0][0]
                    if len(latency_json) == 2:
                        # remove bao's prediction
                        latency_json = [latency_json[1]]
                    latency_json[0]["Execution Time"] = TIMEOUT
                else:
                    raise e

            latency_str = json.dumps(latency_json)
            save_history(sql, encoded_q_str, cur_plan_str, encoded_plan_str, latency_str)

        # 4. save latency
        latency_json[0]['Planning Time'] = planning_time
        if write_latency_file:
            with open(latency_file, "a+") as f:
                fcntl.flock(f, fcntl.LOCK_EX)
                f.write(query_name + SEP + json.dumps(latency_json) + "\n")
                fcntl.flock(f, fcntl.LOCK_UN)

        exec_time = latency_json[0]["Execution Time"]
        print(time(), query_name, exec_time, flush=True)
    except Exception as e:
        with open(latency_file + "_error", "a+") as f:
            fcntl.flock(f, fcntl.LOCK_EX)
            f.write(query_name + "\n")
            f.write(str(e).strip() + "\n")
            fcntl.flock(f, fcntl.LOCK_UN)