local helper = require("curstr.lib.testlib.helper")
local curstr = helper.require("curstr")

describe("directory/path source", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can open default", function()
    helper.test_data:create_dir("path")
    helper.test_data:create_dir("path/opened")
    helper.set_lines([[./path/../path/opened]])

    curstr.execute("directory/path")

    assert.current_dir("path/opened")
  end)
end)
