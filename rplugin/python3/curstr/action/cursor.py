
import re
from typing import Tuple

from neovim import Nvim

from curstr.echoable import Echoable
from curstr.info import SourceExecuteInfo


class Cursor(Echoable):

    def __init__(self, vim: Nvim, info: SourceExecuteInfo) -> None:
        self._vim = vim
        self._info = info

    def target_option(func):
        def wrapper(self, *args, **kwargs) -> str:
            target_string = self._info.string
            if target_string:
                return target_string
            return func(self, *args, **kwargs)

        return wrapper

    @target_option
    def get_word(self, added_iskeyword='') -> str:
        if added_iskeyword == '':
            return self._vim.call('expand', '<cword>')

        added = ','.join(added_iskeyword)
        try:
            self._vim.command('setlocal iskeyword+={}'.format(added))
            word = self._vim.call('expand', '<cword>')
        finally:
            self._vim.command('setlocal iskeyword-={}'.format(added))

        return word

    @target_option
    def get_file_path(self, added_isfname='') -> str:
        if added_isfname == '':
            return self._vim.call('expand', '<cfile>')

        added = ','.join(added_isfname)
        try:
            self._vim.command('setlocal isfname+={}'.format(added))
            file_path = self._vim.call('expand', '<cfile>')
        finally:
            self._vim.command('setlocal isfname-={}'.format(added))

        return file_path

    def get_file_path_with_position(
        self, added_isfname=''
    ) -> Tuple[str, Tuple[int, int]]:
        file_path = self.get_file_path(added_isfname)

        cword = self._vim.call('expand', '<cWORD>')
        pattern = '{}:(\\d+)(,\\d+)?'.format(file_path)
        match = re.match(pattern, cword)
        if match is None:
            return (file_path, (-1, -1))

        row = int(match.group(1))
        if match.group(2) is None:
            return (file_path, (row, 1))

        column = int(match.group(2)[1:])
        position = (row, column)
        return (file_path, position)

    def get_word_with_range(
        self, added_iskeyword=''
    ) -> Tuple[str, Tuple[int, int]]:
        current_pos = self._vim.current.window.cursor
        added = ','.join(added_iskeyword)
        try:
            self._vim.command('setlocal iskeyword+={}'.format(added))
            word_range = self._vim.call(
                'matchstrpos',
                self._vim.current.line,
                '\\v\\k*%{}c\\k+'.format(current_pos[1] + 1)
            )[1:]
        finally:
            self._vim.command('setlocal iskeyword-={}'.format(added))

        if word_range[0] == -1:
            return ('', (-1, -1))

        word = self.get_word(added_iskeyword)

        return (word, word_range)

    @target_option
    def get_line(self) -> str:
        line = self._vim.current.line
        return line
