from denite.base.kind import Base
from denite.util import Nvim, UserContext

class Kind(Base):
    def __init__(self, vim: Nvim) -> None:
        super().__init__(vim)

        self.name = 'symfony'
        self.default_action = 'open'

    def action_open(self, context: UserContext) -> None:
        self._openTargets(context, 'inplace')

    def _openTargets(self, context, mode):
        for target in context['targets']:
            self.vim.call(self._getOpenFunction(target), target['word'], mode)

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

    def action_split(self, context: UserContext) -> None:
        self._openTargets(context, 'split')

    def action_vsplit(self, context: UserContext) -> None:
        self._openTargets(context, 'vsplit')

    def action_tabopen(self, context: UserContext) -> None:
        self._openTargets(context, 'tab')

    def action_openclass(self, context: UserContext) -> None:
        self._openTargetsClass(context, 'inplace')

    def _openTargetsClass(self, context, mode):
        for target in context['targets']:
            cls = self._getClassFromTarget(target)
            if not cls:
                continue
            self.vim.call('symfony#goto#class', cls, mode)

    def _getClassFromTarget(self, target):
        if 'action__class' in target:
            return target['action__class']
        if 'action__type ' in target and target['action__type'] is 'entity':
            return target['word']

    def action_splitclass(self, context: UserContext) -> None:
        self._openTargetsClass(context, 'split')

    def action_vsplitclass(self, context: UserContext) -> None:
        self._openTargetsClass(context, 'vsplit')

    def action_tabopenclass(self, context: UserContext) -> None:
        self._openTargetsClass(context, 'tab')
