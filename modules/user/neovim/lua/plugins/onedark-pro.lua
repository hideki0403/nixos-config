return {
  "olimorris/onedarkpro.nvim",
  lazy = false,
  priority = 1000,
  init = function()
    vim.cmd.colorscheme("onedark")
  end,
}