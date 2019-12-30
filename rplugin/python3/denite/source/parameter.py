from os import path

from denite.util import globruntime, Nvim, UserContext, Candidates
from symfony.denite.source.base import Base

class Source(Base):
    def __init__(self, vim: Nvim) -> None:
        super().__init__(vim)

        self.name = 'symfony/parameter'

    def gather_candidates(self, context: UserContext) -> Candidates:
        parameters = self.vim.call('symfony#getParameters')

        candidates = []
        for key in parameters:
            candidate = self._convert(key, parameters[key])
            candidates.append(candidate)

        return candidates

    def _convert(self, parameter, value):
        return {
                'action__type': 'parameter',
                'word': parameter,
                'abbr': '[{}] {} {}'.format(
                        'param'.rjust(Base.typeLength, ' '),
                        parameter,
                        value
                    )
                }
