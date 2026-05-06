return {
  {
    "vhyrro/luarocks.nvim",
    priority = 1000,
    config = true,
  },
  {
    "nvim-neorg/neorg",
    dependencies = {
      "vhyrro/luarocks.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- In 2026, adding the parsers as direct dependencies lets Lazy/Neovim
      -- automatically load them into the runtimepath
      "nvim-neorg/tree-sitter-norg",
      "nvim-neorg/tree-sitter-norg-meta",
    },
    lazy = false,
    version = false, -- <--- FIX: Forces Neorg to use the newest treesitter-compatible commits
    config = function()
      require("neorg").setup({
        load = {
          ["core.summary"] = {
            config = { strategy = "default" },
          },
          ["core.defaults"] = {},
          ["core.concealer"] = {
            config = {
              icon_preset = "diamond",
              folds = true,
            },
          },
          ["core.dirman"] = {
            config = {
              workspaces = {
                work = "~/notes/work",
                home = "~/notes/home",
                school = "~/notes/school",
              },
              default_workspace = "school",
              autodetect = true,
              autodir = true,
            },
          },
          ["core.esupports.metagen"] = { config = { update_date = false } },
        },
      })
    end,
  },
}
