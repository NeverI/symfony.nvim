from os import path

from denite.base.source import Base
from denite.util import globruntime, Nvim, UserContext, Candidates

SYMFONY_SOURCE_HIGHLIGHT_SYNTAX = [
    {'name': 'Type', 'link': 'Constant', 'pattern': r'\[.\+\]\s'},
    {'name': 'Class', 'link': 'Comment', 'pattern': r'[a-zA-Z0-9\\]\+$'},
]

class Source(Base):

    def __init__(self, vim: Nvim) -> None:
        super().__init__(vim)

        self.kind = 'word'
        self.name = 'symfony/service'
        self.matchers = [ 'matcher/regexp' ]

    def highlight(self) -> None:
        for syntax in SYMFONY_SOURCE_HIGHLIGHT_SYNTAX:
            self.vim.command(
                'syntax match {0}_{1} /{2}/ contained containedin={0}'.format(
                    self.syntax_name, syntax['name'], syntax['pattern']))
            self.vim.command(
                'highlight default link {}_{} {}'.format(
                    self.syntax_name, syntax['name'], syntax['link']))

    def gather_candidates(self, context: UserContext) -> Candidates:
        services = self.vim.call('symfony#getServices')

        candidates = []
        descriptionLength = 0
        for key in services:
            candidate = self._convert(services[key])
            candidates.append(candidate)

            descriptionLength = max(descriptionLength, len(candidate['description']))

        for candidate in candidates:
            candidate['abbr'] = '[{}] {} {}'.format(
                        candidate['description'].rjust(descriptionLength, ' '),
                        candidate['word'],
                        candidate['class']
                    )

        return candidates

    def _convert(self, service):
        return {
                'word': service['name'],
                'class': service['class'] or service['aliasSource'],
                'description': self._getDescription(service)
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
