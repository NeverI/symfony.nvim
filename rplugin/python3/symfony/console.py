import subprocess

class Console:
    def __init__(self, vim):
        self.vim = vim

    def run(self, arguments):
        command = [self.vim.call('symfony#getConsolePath')]

        process = subprocess.Popen(command + arguments, stdout=subprocess.PIPE, universal_newlines=True)

        stdout = process.communicate()
        return {
            'exitCode': process.returncode,
            'output': str(stdout).split('\\n')
            }
