-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})

    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = false

vim.opt.number = true
vim.opt.relativenumber = true

vim.diagnostic.config({
  virtual_text = {
    spacing = 2,
    prefix = "●",
  },
  severity_sort = true,
})

require("lazy").setup({
  spec = {
    {
      "nvim-telescope/telescope.nvim",
      dependencies = {
        "nvim-lua/plenary.nvim",
      },
      config = function()
        require("telescope").setup()

        vim.keymap.set(
          "n",
          "<leader>pf",
          require("telescope.builtin").find_files,
          { desc = "Find files" }
        )
      end,
    },
    {
      "lewis6991/gitsigns.nvim",
      opts = {},
    },
    {
      "nvim-treesitter/nvim-treesitter",
      lazy = false,
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter").install({ "c", "cpp", "python", "rust" })

        vim.api.nvim_create_autocmd("FileType", {
          pattern = { "c", "cpp", "python", "rust" },
          callback = function()
            vim.treesitter.start()
          end,
        })
      end,
    },
    {
      "saghen/blink.cmp",
      version = "1.*",
      dependencies = {
        "rafamadriz/friendly-snippets",
      },
      opts = {
        keymap = {
          preset = "enter",
          ["<C-y>"] = { "select_and_accept" },
          ["<Tab>"] = { "select_and_accept", "fallback" },
        },
        completion = {
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 200,
          },
        },
        sources = {
          default = { "lsp", "path", "snippets", "buffer" },
        },
        fuzzy = {
          implementation = "prefer_rust_with_warning",
        },
      },
      opts_extend = { "sources.default" },
    },
    {
      "neovim/nvim-lspconfig",
      config = function()
        vim.lsp.config("basedpyright", {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "basic",
              },
            },
          },
        })

        vim.lsp.config("rust_analyzer", {
          settings = {
            ["rust-analyzer"] = {
              check = {
                command = "clippy",
              },
            },
          },
        })

        vim.lsp.enable("clangd")
        vim.lsp.enable("rust_analyzer")
        vim.lsp.enable("basedpyright")

        vim.keymap.set(
          "n",
          "<leader>cf",
          function()
            vim.lsp.buf.format({
              filter = function(client)
                return client.name == "clangd" or client.name == "rust_analyzer"
              end,
            })
          end,
          { desc = "Format current buffer with clang-format or rustfmt" }
        )
      end,
    },
  },

  checker = {
    enabled = true,
  },
})

local function transparent_background()
  for _, group in ipairs({
    "Normal",
    "NormalNC",
    "NormalFloat",
    "SignColumn",
    "EndOfBuffer",
    "MsgArea",
    "FloatBorder",
  }) do
    vim.cmd("highlight " .. group .. " guibg=NONE ctermbg=NONE")
  end
end

transparent_background()
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = transparent_background,
})
