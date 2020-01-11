from os import path

from denite.base.source import Base as Parent
from denite.util import globruntime, Nvim
from symfony.denite.kind.symfony import Kind

class Base(Parent):

    typeLength = 13

    hightlightGroups = [
        {'name': 'Type', 'link': 'Constant', 'pattern': r'\[.\+\]\s'},
        {'name': 'Value', 'link': 'Comment', 'pattern': r'\s\S\+$'},
    ]

    def __init__(self, vim: Nvim) -> None:
        super().__init__(vim)

        self.kind = Kind(vim)
        self.matchers = [ 'matcher/regexp' ]

    def highlight(self) -> None:
        for syntax in self.hightlightGroups:
            self.vim.command(
                'syntax match {0}_{1} excludenl /{2}/ contained containedin={0}'.format(
                    self.syntax_name, syntax['name'], syntax['pattern']))
            self.vim.command(
                'highlight default link {}_{} {}'.format(
                    self.syntax_name, syntax['name'], syntax['link']))
