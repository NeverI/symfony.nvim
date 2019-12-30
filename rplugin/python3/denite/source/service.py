from os import path

from denite.util import globruntime, Nvim, UserContext, Candidates
from symfony.denite.source.base import Base

class Source(Base):
    def __init__(self, vim: Nvim) -> None:
        super().__init__(vim)

        self.name = 'symfony/service'

    def gather_candidates(self, context: UserContext) -> Candidates:
        services = self.vim.call('symfony#getServices')

        candidates = []
        for key in services:
            candidate = self._convert(services[key])
            candidates.append(candidate)

        return candidates

    def _convert(self, service):
        return {
                'action__type': 'service',
                'action__class': service['class'].replace('\\\\', '\\'),
                'word': service['name'],
                'abbr': '[{}] {} {}'.format(
                        self._getDescription(service).rjust(Base.typeLength, ' '),
                        service['name'],
                        service['class'].replace('\\\\', '\\') or service['aliasSource']
                    )
                }

    def _getDescription(self, service):
        desc = ' '
        if service['abstract']:
            desc += 'ab '
        if not service['public']:
            desc += 'pr '
        if not service['shared']:
            desc += 'ns '

        return (desc + 'service').strip()
