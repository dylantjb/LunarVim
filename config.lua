--     __                          _    ___
--    / /   __  ______  ____ _____| |  / (_)___ ___
--   / /   / / / / __ \/ __ `/ ___/ | / / / __ `__ \
--  / /___/ /_/ / / / / /_/ / /   | |/ / / / / / / /
-- /_____/\__,_/_/ /_/\__,_/_/    |___/_/_/ /_/ /_/


vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  pattern = { "*.scala", "*.sbt", "*.sc" },
  callback = function() require('user.metals').start() end,
})

vim.opt.timeoutlen = 500
vim.opt.relativenumber = true
lvim.colorscheme = "onedarker"
lvim.transparent_window = true

vim.diagnostic.config({ virtual_text = false })
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "clangd" })
require("lvim.lsp.null-ls.formatters").setup {
  { exe = "black",     filetypes = { "python" } },
  { exe = "isort",     filetypes = { "python" } },
  { exe = "djlint",    filetypes = { "htmldjango" } },
  { exe = "prettierd", filetypes = { "javascript" } },
  { exe = "scalafmt",  filetypes = { "scala" } },
}
require("lvim.lsp.null-ls.linters").setup {
  { exe = "pylint",   filetypes = { "python" } },
  { exe = "djlint",   filetypes = { "htmldjango" } },
  { exe = "eslint_d", filetypes = { "javascript" } },
  { exe = "cppcheck", filetypes = { "cpp", "c" } },
}

lvim.builtin.dap.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.filters.dotfiles = true
lvim.builtin.nvimtree.setup.renderer.icons.show.git = true
lvim.keymappings = {
  { key = { "l", "<CR>", "o" }, action = "edit",      mode = "n" },
  { key = "h",                  action = "close_node" },
  { key = ";",                  action = "split" },
  { key = "v",                  action = "vsplit" },
  { key = "C",                  action = "cd" },
}
lvim.builtin.indentlines.options.show_current_context = true
lvim.builtin.treesitter.ensure_installed = {
  "bash", "c", "cmake", "cpp", "gitignore", "html", "java",
  "javascript", "latex", "lua", "markdown", "python", "scala"
}

lvim.builtin.which_key.setup.window = { padding = { 0, 0, 0, 0 } }
lvim.builtin.which_key.setup.layout = {
  spacing = 3,
  align = "left",
  height = { min = 1, max = 10 }
}
lvim.builtin.alpha.dashboard.section.footer = nil
lvim.builtin.alpha.dashboard.section.header.val = {
  "   ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆          ",
  "    ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦       ",
  "          ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻j⢿⣿⣧⣄     ",
  "           ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄    ",
  "          ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀   ",
  "   ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄  ",
  "  ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄   ",
  " ⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄  ",
  " ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇ ⠛⠻⢷⣄ ",
  "     ⠻⣿⣿⣿⣿⣶  ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟⣤⣾⡿⠃     ",
}

local mason_path = vim.fn.glob(vim.fn.stdpath "data" .. "/mason/")
local status_ok, dap = pcall(require, "dap")
if not status_ok then return end

dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = mason_path .. "bin/codelldb",
    args = { "--port", "${port}" },
  },
}
dap.configurations.cpp = {
  {
    name = "Launch file",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = true,
  },
}
dap.configurations.c = dap.configurations.cpp
dap.configurations.scala = {
  {
    type = "scala",
    request = "launch",
    name = "Run or Test Target",
    metals = { runType = "runOrTestFile" },
  },
  {
    type = "scala",
    request = "launch",
    name = "Test Target",
    metals = { runType = "testTarget" },
  },
}

pcall(function() require("dap-python").setup(mason_path .. "packages/debugpy/venv/bin/python") end)
pcall(function() require("dap-python").test_runner = "pytest" end)

lvim.plugins = {
  {
    "sindrets/diffview.nvim",
    event = "BufRead",
  },
  {
    "tpope/vim-fugitive",
    cmd = {
      "G",
      "Git",
      "Gdiffsplit",
      "Gread",
      "Gwrite",
      "Ggrep",
      "GMove",
      "GDelete",
      "GBrowse",
      "GRemove",
      "GRename",
      "Glgrep",
      "Gedit"
    },
    ft = { "fugitive" }
  },
  "nvim-neotest/neotest",
  "scalameta/nvim-metals",
  "mfussenegger/nvim-dap-python",
  {
    "zbirenbaum/copilot.lua",
    config = function()
      vim.defer_fn(function()
        require("copilot").setup {}
      end, 100)
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    after = { "copilot.lua" },
    config = function()
      require("copilot_cmp").setup {
        formatters = {
          insert_text = require("copilot_cmp.format").remove_existing,
        }
      }
    end
  },
  {
    "Pocco81/auto-save.nvim",
    config = function()
      require("user.autosave").config()
    end,
  },
  {
    "nvim-pack/nvim-spectre",
    event = "BufRead",
    config = function()
      require("user.spectre").config()
    end
  },
  {
    "folke/persistence.nvim",
    event = "VimEnter",
    config = function()
      require("persistence").setup {
        dir = vim.fn.expand(vim.fn.stdpath "config" .. "/session/"),
        options = { "buffers", "curdir", "tabpages", "winsize" }
      }
    end,
  },
  {
    "tzachar/cmp-tabnine",
    config = function()
      local tabnine = require "cmp_tabnine.config"
      tabnine:setup {
        max_lines = 1000,
        max_num_results = 20,
        sort = true,
      }
    end,
    build = "./install.sh",
    dependencies = "hrsh7th/nvim-cmp"
  },
  {
    "karb94/neoscroll.nvim",
    event = "BufRead",
    config = function()
      require("neoscroll").setup {
        mappings = { "<C-u>", "<C-d>", "<C-f>", "<C-b>", "zt", "zz", "zb" },
        hide_cursor = true,
        stop_eof = true,
        use_local_scrolloff = false,
        respect_scrolloff = false,
        cursor_scrolls_alone = false,
        easing_function = nil,
      }
    end
  },
}
