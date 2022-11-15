local M = {}

M.config = function()
  local status_ok, autosave = pcall(require, "auto-save")
  if not status_ok then return end

  autosave.setup {
    condition = function(buf)
    local fn = vim.fn
    local utils = require("auto-save.utils.data")

    if fn.getbufvar(buf, "&modifiable") == 1
        and
        utils.not_in(fn.getbufvar(buf, "&filetype"), {})
        and
        utils.not_in(fn.expand("%:t"), {
          "config.lua",
        })
    then
      return true
    end
    return false
    end,
  }
end

return M
