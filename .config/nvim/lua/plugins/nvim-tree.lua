-- File tree navigation 
return {
  "nvim-tree/nvim-tree.lua",
  enabled = true,
  dependencies = { "nvim-tree/nvim-web-devicons"},
  tag = "stable",
  config = function()
    require("nvim-tree").setup({
      sort_by = "case_sensitive",
      view = {
	side = "right",
	width = 30,
	mappings = {
	  list = {
	    { key = "u", action = "dir_up" },
	  },
	},
      },
      renderer = {
	group_empty = true,
      },
      filters = {
	dotfiles = true,
      },
      update_focused_file = {
	enable = true,
	update_root = true,
      },
    })
  end
}
