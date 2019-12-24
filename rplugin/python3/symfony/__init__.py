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
        self.buildRouteCache()

    @pynvim.command('SymfonyBuildServiceCache', sync=False)
    def buildServiceCache(self):
        parameters = self.symfony.getParameters()
        self.vim.call('symfony#_setParameters', parameters)

        services = self.symfony.getServices(parameters)
        self.vim.call('symfony#_setServices', services)

    @pynvim.command('SymfonyBuildEntityCache', sync=False)
    def buildEntityCache(self):
        entities = self.symfony.getEntities()
        self.vim.call('symfony#_setEntities', entities)

    @pynvim.command('SymfonyBuildRouteCache', sync=False)
    def buildRouteCache(self):
        return None
