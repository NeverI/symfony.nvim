from denite.base.kind import Base
from denite.util import Nvim, UserContext

class Kind(Base):
    def __init__(self, vim: Nvim) -> None:
        super().__init__(vim)

        self.name = 'symfony'
        self.default_action = 'open'

    def action_open(self, context: UserContext) -> None:
        for target in context['targets']:
            self.vim.call(self._getOpenFunction(target), self._getWord(target), 'inplace')

    def _getOpenFunction(self, target):
        if 'action__type' not in target:
            raise Exception('Invalid target, missing action__type')

        if target['action__type'] is 'service':
            return 'symfony#goto#service'
        elif target['action__type'] is 'entity':
            return 'symfony#goto#class'
        elif target['action__type'] is 'parameter':
            return 'symfony#goto#parameter'

        raise Exception('Unknown action type: ' + target['action__type'])

    def _getWord(self, target):
        if target['action__type'] is 'entity':
            return target['word'].replace('\\\\', "\\")

        return target['word']

    def action_split(self, context: UserContext) -> None:
        for target in context['targets']:
            self.vim.call(self._getOpenFunction(target), self._getWord(target), 'split')

    def action_vsplit(self, context: UserContext) -> None:
        for target in context['targets']:
            self.vim.call(self._getOpenFunction(target), self._getWord(target), 'vsplit')

    def action_tabopen(self, context: UserContext) -> None:
        for target in context['targets']:
            self.vim.call(self._getOpenFunction(target), self._getWord(target), 'tab')
