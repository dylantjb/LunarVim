local M = {}

M.config = function()
  vim.g.maplocalleader = ","
  vim.g.tex_flavor = "latex"
  vim.g.vimtex_fold_manual = 1
  vim.g.vim_latexmk_continous = 1
  vim.g.vimtex_view_skim_sync = 1
  vim.g.vimtex_view_method = "skim"
  vim.g.vimtex_compiler_progname='nvr'
end

return M
