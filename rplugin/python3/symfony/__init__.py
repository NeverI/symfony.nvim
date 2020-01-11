import pynvim
from symfony.symfony import Symfony

@pynvim.plugin
class SymfonyPlugin(object):

    def __init__(self, vim):
        self.vim = vim
        self.symfony = Symfony(vim)

    @pynvim.command('SymfonyBuildAllCache', sync=False)
    def buildAllCache(self):
        self.buildServiceCache()
        self.buildEntityCache()

    @pynvim.command('SymfonyBuildServiceCache', sync=False)
    def buildServiceCache(self):
        self.symfony.getParameters(self._setParametersAndGetServices)

    def _setParametersAndGetServices(self, parameters):
        self.vim.call('symfony#_setParameters', parameters)
        self.symfony.getServices(parameters, self._setServices)

    def _setServices(self, services):
        self.vim.call('symfony#_setServices', services)

    @pynvim.command('SymfonyBuildEntityCache', sync=False)
    def buildEntityCache(self):
        self.symfony.getEntities(self._setEntities)

    def _setEntities(self, entities):
        self.vim.call('symfony#_setEntities', entities)
