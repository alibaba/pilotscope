import paramiko

import logging

logging.getLogger("paramiko.transport").setLevel(logging.WARNING)


class SSHConnector:
    def __init__(self, host, user, pwd, port=22):
        self.host = host
        self.user = user
        self.pwd = pwd
        self.port = port
        self.client = None
        self.sftp = None

    def connect(self):
        self.client = paramiko.SSHClient()
        self.client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self.client.connect(self.host, self.port, self.user, self.pwd)
        self.sftp = self.client.open_sftp()

    def open_file(self, remote_path, mode="r"):
        return self.sftp.open(remote_path, mode)

    def write_file(self, remote_path, content):
        with self.open_file(remote_path, "w") as f:
            f.write(content)

    def remote_exec_cmd(self, cmd):
        _, std_out, std_err = self.client.exec_command(cmd)
        return std_out.readlines(), std_err.readlines()

    def close(self):
        self.client.close()
        self.sftp.close()
