from symfony.console import Console
from symfony.sf28.parseServices import ServiceParser
from symfony.sf28.parseParameters import ParameterParser

class Symfony28:
    def __init__(self, vim):
        self.vim = vim
        self.console = Console(vim)

    def getParameters(self):
        result = self.console.run(['debug:container', '--env=dev', '--parameters', '--format=md'])
        parameters = ParameterParser().parse(result['output'])

        if not len(parameters):
            raise Exception('Symfony console exited without parameters')

        return parameters

    def getServices(self, parameters):
        camelCase = self.vim.vars['symfonyNvimCamelCaseServiceNames']

        result = self.console.run(['debug:container', '--env=dev', '--format=md'])
        services = ServiceParser().parse(result['output'], parameters, camelCase)

        if not len(services):
            raise Exception('Symfony console exited without services')

        return services
