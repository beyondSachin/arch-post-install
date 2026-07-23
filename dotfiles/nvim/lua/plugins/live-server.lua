return {
  "barrett-ruth/live-server.nvim",
  cmd = {
    "LiveServerStart",
    "LiveServerStop",
    "LiveServerToggle",
  },
  config = function()
    require("live-server").setup({
      -- optional settings
    })
  end,
}
