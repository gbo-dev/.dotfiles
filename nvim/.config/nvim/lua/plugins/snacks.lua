return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = false },
    dashboard = { enabled = true },
    dim = { enabled = false },
    explorer = {
      enabled = true,
      hidden = true,
    },
    indent = { enabled = true },
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    picker = {
      enabled = true,
      hidden = true,
      layout = { preset = "vertical", },
      layouts = {
        vertical = {
          layout = {
            backdrop = false,
            width = 0.65,
            min_width = 80,
            height = 0.85,
            min_height = 30,
            box = "vertical",
            border = "rounded",
            title = "{title} {live} {flags}",
            title_pos = "center",
            { win = "input",   height = 1,          border = "bottom" },
            { win = "list",    border = "none" },
            { win = "preview", title = "{preview}", height = 0.4,     border = "top" },
          },
        },
      },
      sources = {
        files = {
          hidden = true,
          ignored = true,
        },
        explorer = {
          layout = { cycle = false, }
        }
      }
    },
  },
  quickfile = { enabled = true },
  scroll = {
    enabled = false,
    duration = { step = 15, total = 15 }
  },
  statuscolumn = { enabled = false },
  styles = {
    notification = {
      wo = { wrap = true } -- Wrap notifications
    }
  },
  words = { enabled = true },
  zen = {
    toggles = {
      dim = false,
    },
  },
  keys = {
    { "<leader>z",       function() Snacks.zen() end,                                            desc = "Toggle [z]en Mode" },
    { "<leader>Z",       function() Snacks.zen.zoom() end,                                       desc = "Toggle [Z]oom" },
    { "<leader>RF",      function() Snacks.rename.rename_file() end,                             desc = "[R]ename [F]ile" },
    { "<leader>gB",      function() Snacks.gitbrowse() end,                                      desc = "[g]it [B]rowse" },
    { "<leader>gbl",     function() Snacks.git.blame_line() end,                                 desc = "[g]it [b]lame [l]ine" },
    { "<leader>un",      function() Snacks.notifier.hide() end,                                  desc = "Dismiss All Notifications" },
    { "<c-j>",           function() Snacks.terminal() end,                                       desc = "Toggle Terminal" },
    { "]]",              function() Snacks.words.jump(vim.v.count1) end,                         desc = "Next Reference",                           mode = { "n", "t" } },
    { "[[",              function() Snacks.words.jump(-vim.v.count1) end,                        desc = "Prev Reference",                           mode = { "n", "t" } },
    -- Top Pickers & Explorer
    { "<leader><space>", function() Snacks.picker.smart() end,                                   desc = "Smart Find Files" },
    { "<leader>,",       function() Snacks.picker.buffers() end,                                 desc = "Buffers" },
    { "<leader>:",       function() Snacks.picker.command_history() end,                         desc = "Command History" },
    { "<leader>n",       function() Snacks.picker.notifications() end,                           desc = "[n]otification History" },
    { "<C-b>",           function() Snacks.explorer() end,                                       desc = "File [e]xplorer" },
    -- find
    { "<leader>fb",      function() Snacks.picker.buffers() end,                                 desc = "[f]ind [b]uffers" },
    { "<leader>fc",      function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "[f]ind [c]onfig File" },
    { "<leader>ff",      function() Snacks.picker.files() end,                                   desc = "[f]ind [f]iles" },
    { "<leader>fg",      function() Snacks.picker.git_files() end,                               desc = "[f]ind [g]it files" },
    { "<leader>fp",      function() Snacks.picker.projects() end,                                desc = "[f]ind [p]rojects" },
    { "<leader>fr",      function() Snacks.picker.recent() end,                                  desc = "[f]ind [r]ecent Files" },
    -- git
    { "<leader>gb",      function() Snacks.picker.git_branches() end,                            desc = "[g]it [b]ranches" },
    { "<leader>gl",      function() Snacks.picker.git_log() end,                                 desc = "[g]it [l]og" },
    { "<leader>gL",      function() Snacks.picker.git_log_line() end,                            desc = "[g]it [L]og line" },
    { "<leader>gs",      function() Snacks.picker.git_status() end,                              desc = "[g]it [s]tatus" },
    { "<leader>gS",      function() Snacks.picker.git_stash() end,                               desc = "[g]it [S]tash" },
    { "<leader>gd",      function() Snacks.picker.git_diff() end,                                desc = "[g]it [d]iff (Hunks)" },
    { "<leader>gf",      function() Snacks.picker.git_log_file() end,                            desc = "[g]it Log [f]ile" },
    -- Grep
    { "<leader>sl",      function() Snacks.picker.lines() end,                                   desc = "[s]earch Buffer [l]ines" },
    { "<leader>sb",      function() Snacks.picker.grep_buffers() end,                            desc = "[s]earch grep Open [b]uffers" },
    { "<leader>sg",      function() Snacks.picker.grep() end,                                    desc = "[s]earch [g]rep" },
    { "<leader>sw",      function() Snacks.picker.grep_word() end,                               desc = "[s]earch Grep Visual Selection or [w]ord", mode = { "n", "x" } },
    -- search
    { '<leader>s"',      function() Snacks.picker.registers() end,                               desc = "[s]earch Registers" },
    { '<leader>s/',      function() Snacks.picker.search_history() end,                          desc = "[s]earch History" },
    { "<leader>sa",      function() Snacks.picker.autocmds() end,                                desc = "[s]earch [a]utocmds" },
    { "<leader>sC",      function() Snacks.picker.commands() end,                                desc = "[s]earch [C]ommands" },
    { "<leader>sd",      function() Snacks.picker.diagnostics() end,                             desc = "[s]earch [d]iagnostics" },
    { "<leader>sD",      function() Snacks.picker.diagnostics_buffer() end,                      desc = "[s]earch Buffer [D]iagnostics" },
    { "<leader>sh",      function() Snacks.picker.help() end,                                    desc = "[s]earch [h]elp Pages" },
    { "<leader>sH",      function() Snacks.picker.highlights() end,                              desc = "[s]earch [H]ighlights" },
    { "<leader>si",      function() Snacks.picker.icons() end,                                   desc = "[s]earch [i]cons" },
    { "<leader>sj",      function() Snacks.picker.jumps() end,                                   desc = "[s]earch [j]umps" },
    { "<leader>sk",      function() Snacks.picker.keymaps() end,                                 desc = "[s]earch [k]eymaps" },
    { "<leader>ll",      function() Snacks.picker.loclist() end,                                 desc = "[l]ocation [l]ist" },
    { "<leader>sm",      function() Snacks.picker.marks() end,                                   desc = "[s]earch [m]arks" },
    { "<leader>sM",      function() Snacks.picker.man() end,                                     desc = "[s]earch [M]an Pages" },
    { "<leader>sp",      function() Snacks.picker.lazy() end,                                    desc = "[s]earch for [p]lugin Spec" },
    { "<leader>sq",      function() Snacks.picker.qflist() end,                                  desc = "[s]earch [q]uickfix List" },
    { "<leader>sR",      function() Snacks.picker.resume() end,                                  desc = "Resume" },
    { "<leader>su",      function() Snacks.picker.undo() end,                                    desc = "[s]earch [u]ndo History" },
    { "<leader>uC",      function() Snacks.picker.colorschemes() end,                            desc = "Colorschemes" },
    -- LSP
    { "gd",              function() Snacks.picker.lsp_definitions() end,                         desc = "[g]oto [d]efinition" },
    { "gD",              function() Snacks.picker.lsp_declarations() end,                        desc = "[g]oto [D]eclaration" },
    { "gr",              function() Snacks.picker.lsp_references() end,                          nowait = true,                                     desc = "[g]oto [r]eferences" },
    { "gI",              function() Snacks.picker.lsp_implementations() end,                     desc = "[g]oto [I]mplementation" },
    { "gy",              function() Snacks.picker.lsp_type_definitions() end,                    desc = "[g]oto T[y]pe Definition" },
    { "<leader>ds",      function() Snacks.picker.lsp_symbols() end,                             desc = "[d]ocument [s]ymbol" },
    { "<leader>ws",      function() Snacks.picker.lsp_workspace_symbols() end,                   desc = "[w]orkspace [s]ymbols" },
    {
      "<leader>N",
      desc = "Neovim News",
      function()
        Snacks.win({
          file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
          width = 0.6,
          height = 0.6,
          wo = {
            spell = false,
            wrap = false,
            signcolumn = "yes",
            statuscolumn = " ",
            conceallevel = 3,
          },
        })
      end,
    }
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command

        -- Create some toggle mappings
        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.line_number():map("<leader>ul")
        Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map(
          "<leader>uc")
        Snacks.toggle.treesitter():map("<leader>uT")
        -- Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
        Snacks.toggle.inlay_hints():map("<leader>uh")
      end,
    })
  end
}
