from symfony.symfony28 import Symfony28

class Symfony:
    def __init__(self, vim):
        self.vim = vim
        self.versions = {}

    def getParameters(self, onFinish):
        return self._getSymfony().getParameters(onFinish)

    def _getSymfony(self):
        version = self.vim.call('symfony#getVersion')
        if version in self.versions:
            return self.versions[version]

        self.versions[version] = Symfony28(self.vim)
        return self.versions[version]

    def getServices(self, parameters, onFinish):
        return self._getSymfony().getServices(parameters, onFinish)

    def getEntities(self, onFinish):
        return self._getSymfony().getEntities(onFinish)
