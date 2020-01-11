import threading
import subprocess

class Console(threading.Thread):
    def __init__(self, command, onFinish):
        self.command = command
        self.onFinish = onFinish
        threading.Thread.__init__(self)

    def run(self):
        process = subprocess.Popen(self.command,
                shell=False,
                stdout=subprocess.PIPE,
                universal_newlines=True)

        stdout = process.communicate()

        self.onFinish({
            'exitCode': process.returncode,
            'output': str(stdout).split('\\n')
            })
