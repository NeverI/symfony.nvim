from os import path

from denite.util import globruntime, Nvim, UserContext, Candidates
from symfony.denite.source.base import Base

class Source(Base):
    def __init__(self, vim: Nvim) -> None:
        super().__init__(vim)

        self.name = 'symfony/entity'

    def gather_candidates(self, context: UserContext) -> Candidates:
        entities = self.vim.call('symfony#getEntities')

        candidates = []
        for entity in entities:
            candidate = self._convert(entity)
            candidates.append(candidate)

        return candidates

    def _convert(self, entity):
        return {
                'word': entity,
                'abbr': '[{}] {} {}'.format(
                        'entity'.rjust(Base.typeLength, ' '),
                        entity.split('\\')[-1],
                        entity
                    )
                }
