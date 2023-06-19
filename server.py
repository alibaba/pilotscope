# from http.server import HTTPServer, BaseHTTPRequestHandler
# from PilotScheduler import PilotScheduler
# from baihe_lib.utils import get_tree_signature, hash_md5_str
# import json
#
#
# class Resquest(BaseHTTPRequestHandler):
#
#     def __init__(self, scheduler, *args) -> None:
#         self.scheduler: PilotScheduler = scheduler
#         BaseHTTPRequestHandler.__init__(self, *args)
#
#     def handle_init_task(self, req_data):
#         task_name = req_data.decode('utf-8')
#         print("Start task: " + task_name)
#         return {"status": "success", "err_msg": ""}
#
#     def handle_plan_hash(self, req_data):
#         plan = req_data.decode('utf-8')
#         plan_signature = get_tree_signature(plan)
#         plan_hash = hash_md5_str(str(plan_signature))
#         return {"ret": plan_hash, "err_msg": ""}
#
#     def handle_task(self, req_data):
#         query = req_data.decode('utf-8')
#         est = self.scheduler.process(query)
#         print(query + " {}".format(est))
#         return {"ret": est, "err_msg": ""}
#
#     def do_POST(self):
#         content_length = int(self.headers['Content-Length'])
#         # print(self.headers)
#         req_data = self.rfile.read(content_length)
#         resp_data = ""
#         if self.path == "/start_task":
#             resp_data = self.handle_init_task(req_data)
#         elif self.path == "/plan_hash":
#             resp_data = self.handle_plan_hash(req_data)
#         else:
#             resp_data = self.handle_task(req_data)
#         self.send_response(200)
#         self.send_header('Content-type', 'application/json')
#         # self.send_header('Content-type', 'application/x-www-form-urlencoded')
#         self.end_headers()
#         self.wfile.write(json.dumps(resp_data).encode())
#
#
# def baihe_run_server(scheduler: PilotScheduler, host="localhost", port=8888):
#     def handler(*args):
#         Resquest(scheduler, *args)
#
#     server = HTTPServer((host, port), handler)
#     print("Starting server, listen at: %s:%d" % (host, port))
#     server.serve_forever()
