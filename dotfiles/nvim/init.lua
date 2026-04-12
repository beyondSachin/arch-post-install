-- bootstrap lazy.nvim, LazyVim and your plugins

-- In your plugins list (likely in lua/plugins/neotree.lua)
-- 1. Put this at the very top
require("config.lazy")

-- 2. Then provide your plugin configuration
return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = false,
      },
      components = {
        name = function(config, node, state)
          local cc = require("neo-tree.sources.filesystem.components")
          local result = cc.name(config, node, state)
          if node:get_depth() == 1 then
            result.text = vim.fn.fnamemodify(node.path, ":t")
          end
          return result
        end,
      },
    },
  }
}
