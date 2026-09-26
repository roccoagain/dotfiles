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

-- Indentation
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

-- Search
vim.opt.ignorecase = true

-- UI
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.clipboard = "unnamedplus"

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
      opts = {},
      keys = {
        {
          "<leader>pf",
          function()
            require("telescope.builtin").find_files()
          end,
          desc = "Find files",
        },
      },
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
        local languages = { "c", "cpp", "python", "rust" }

        require("nvim-treesitter").install(languages)

        vim.api.nvim_create_autocmd("FileType", {
          pattern = languages,
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

        vim.lsp.enable({ "clangd", "rust_analyzer", "basedpyright" })

        local formatters = { clangd = true, rust_analyzer = true }

        vim.keymap.set(
          "n",
          "<leader>cf",
          function()
            vim.lsp.buf.format({
              filter = function(client)
                return formatters[client.name]
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
