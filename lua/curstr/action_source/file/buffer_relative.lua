local M = {}

function M.create(self)
  local path, position = self.cursor:file_path_with_position()
  local abs_path = self.pathlib.join(vim.fn.expand("%:p:h"), path)
  if not self.filelib.readable(abs_path) then
    return nil
  end
  return self:to_group("file", { path = abs_path, position = position })
end

M.description = [[uses a relative file path with current buffer]]

return M
