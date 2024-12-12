return {
  {
    "echasnovski/mini.move",
    enabled = true,
    config = function()
      require('mini.move').setup {
	-- Module mappings. Use `''` (empty string) to disable one.
	mappings = {
	  -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
	  left = '<M-Left>',
	  right = '<M-Right>',
	  down = '<M-Down>',
	  up = '<M-Up>',

	  -- Move current line in Normal mode
	  line_left = '<M-Left>',
	  line_right = '<M-Right>',
	  line_down = '<M-Down>',
	  line_up = '<M-Up>',
	},

	-- Options which control moving behavior
	options = {
	  -- Automatically reindent selection during linewise vertical move
	  reindent_linewise = true,
	},
      }
    end
  },
}
