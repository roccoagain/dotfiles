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
      "neovim/nvim-lspconfig",
      config = function()
        vim.lsp.enable("clangd")
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
