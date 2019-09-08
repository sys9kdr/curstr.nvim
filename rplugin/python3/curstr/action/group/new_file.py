import pathlib

from .file import File


class NewFile(File):
    def __init__(self, vim, path) -> None:
        open(path, "w").close()
        super().__init__(vim, path)

    def name(self):
        return pathlib.Path(__file__).stem
