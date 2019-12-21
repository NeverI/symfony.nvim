from symfony.symfony28 import Symfony28

class Symfony:
    def __init__(self, vim):
        self.vim = vim
        self.versions = {}

    def getParameters(self):
        return self._getSymfony().getParameters()

    def _getSymfony(self):
        version = self.vim.call('symfony#getVersion')
        if version in self.versions:
            return self.versions[version]

        if str(version) == '28':
            self.versions[version] = Symfony28(self.vim)
        else:
            raise Exception('Unknown symfony version: ' + version)

        return self.versions[version]

    def getServices(self, parameters):
        return self._getSymfony().getServices(parameters)
