return {
  "oskarnurm/koda.nvim",
  enabled = false,
  priority = 1001,
  config = function()
    require("koda").setup({ transparent = true })
    vim.cmd.colorscheme("koda-moss")
  end,
}
