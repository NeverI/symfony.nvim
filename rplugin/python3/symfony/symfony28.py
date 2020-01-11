from symfony.console import Console
from symfony.sf28.parseServices import ServiceParser
from symfony.sf28.parseParameters import ParameterParser
from symfony.sf28.parseEntities import EntityParser

class Symfony28:
    def __init__(self, vim):
        self.vim = vim
        self.camelCase = self.vim.vars['symfonyNvimCamelCaseServiceNames']

    def getParameters(self, onFinish):
        console = Console([self.vim.call('symfony#getConsolePath'),
            'debug:container', '--env=dev', '--parameters', '--format=md'],
            self._parseParams(onFinish)
        )
        console.start()

    def _parseParams(self, onFinish):
        def parser(result):
            parameters = ParameterParser().parse(result['output'])
            if not len(parameters):
                raise Exception('Symfony console exited without parameters')

            self.vim.async_call(onFinish, parameters)

        return parser

    def getServices(self, parameters, onFinish):
        console = Console([self.vim.call('symfony#getConsolePath'),
            'debug:container', '--env=dev', '--show-private', '--format=md'],
            self._parseServices(parameters, onFinish)
        )
        console.start()

    def _parseServices(self, parameters, onFinish):
        def parser(result):
            services = ServiceParser().parse(result['output'], parameters, self.camelCase)

            if not len(services):
                raise Exception('Symfony console exited without services')

            self.vim.async_call(onFinish, services)

        return parser

    def getEntities(self, onFinish):
        console = Console([self.vim.call('symfony#getConsolePath'),
            'doctrine:mapping:info', '--env=dev'],
            self._parseEntities(onFinish)
        )
        console.start()

    def _parseEntities(self, onFinish):
        def parser(result):
            entities = EntityParser().parse(result['output'])
            self.vim.async_call(onFinish, entities)

        return parser
