local helper = require("curstr.lib.testlib.helper")
local curstr = helper.require("curstr")

describe("vim/search", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("file_one", function()
    curstr.setup({
      sources = { ["vim/search"] = { opts = { source_pattern = "\\v\\k+", search_pattern = "\\1:\\1" } } },
    })

    helper.open_new_file(
      "entry",
      [[
hoge

hoge:hoge]]
    )

    curstr.execute("vim/search")

    assert.current_row(3)
    assert.current_line("hoge:hoge")
  end)

  it("not_found", function()
    helper.open_new_file("entry")

    curstr.execute("vim/search")

    assert.current_row(1)
  end)
end)
