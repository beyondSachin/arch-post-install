return {
  "iamcco/markdown-preview.nvim",
  build = "cd app && npm install",
  ft = { "markdown" },
  init = function()
    vim.g.mkdp_auto_start = 0
    vim.g.mkdp_auto_close = 0 -- Keep preview open when switching buffers
    vim.g.mkdp_refresh_slow = 0
    vim.g.mkdp_browser = ""
  end,
}
