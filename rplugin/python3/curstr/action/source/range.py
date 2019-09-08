from typing import List  # noqa

from curstr.action.group import ActionGroup, Range

from .base import Source as Base


class Source(Base):
    def create(self) -> ActionGroup:
        return Range(self._vim, self._info.first_line, self._info.last_line)
