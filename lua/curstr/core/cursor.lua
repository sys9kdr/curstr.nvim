local M = {}

function M.word(_, added_iskeyword)
  if added_iskeyword == nil then
    return vim.fn.expand("<cword>")
  end

  local origin_iskeyword = vim.bo.iskeyword
  local splitted = vim.split(origin_iskeyword, ",", true)
  vim.list_extend(splitted, vim.split(added_iskeyword, "", true))
  local new_iskeyword = table.concat(splitted, ",")

  vim.bo.iskeyword = new_iskeyword
  local word = vim.fn.expand("<cword>")
  vim.bo.iskeyword = origin_iskeyword

  return word
end

function M.word_with_range(_, char_pattern)
  char_pattern = char_pattern or "\\k"
  local pos = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()
  local pattern = ("\\v[%s]*%%%sc[%s]+"):format(char_pattern, pos[2] + 1, char_pattern)
  local word, start_byte = unpack(vim.fn.matchstrpos(line, pattern))
  if start_byte == -1 then
    return "", nil
  end
  local after_part = vim.fn.strpart(line, start_byte)
  local s = #line - #after_part
  local e = s + #word
  local word_range = { s, e }
  return word, word_range
end

function M.file_path(_, added_isfname)
  if added_isfname == nil then
    return vim.fn.expand("<cfile>")
  end

  local origin_isfname = vim.o.isfname
  local splitted = vim.split(origin_isfname, ",", true)
  vim.list_extend(splitted, vim.split(added_isfname, "", true))
  local new_isfname = table.concat(splitted, ",")

  vim.o.isfname = new_isfname
  local path = vim.fn.expand("<cfile>")
  vim.o.isfname = origin_isfname

  return path
end

function M.file_path_with_position(_, added_isfname)
  local file_path = M.file_path(added_isfname)
  local cword = vim.fn.expand("<cWORD>")
  local pattern = ("\\v%s:\\zs(\\d+)(,\\d+)?"):format(file_path)
  local ok, regex = pcall(vim.regex, pattern)
  if not ok then
    return file_path, nil
  end
  local s, e = regex:match_str(cword)
  if s == nil then
    return file_path, nil
  end
  local matched = cword:sub(s + 1, e)
  local row, col = unpack(vim.split(matched, ",", true))
  return file_path, { tonumber(row), tonumber(col or 1) }
end

function M.line_with_range()
  local line = vim.api.nvim_get_current_line()
  return line, { 1, #line }
end

return M
