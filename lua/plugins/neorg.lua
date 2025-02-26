return {
  {
    "vhyrro/luarocks.nvim",
    priority = 1000, -- We'd like this plugin to load first out of the rest
    config = true, -- This automatically runs `require("luarocks-nvim").setup()`
  },
  {
    "nvim-neorg/neorg",
    dependencies = { "luarocks.nvim", "nvim-treesitter/nvim-treesitter" },
    -- put any other flags you wanted to pass to lazy here!
    lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
    version = "*", -- Pin Neorg to the latest stable release
    config = function()
      require("neorg").setup({
        load = {
          ["core.summary"] = { -- Generates index pages
            config = {
              strategy = "default",
            },
          },
          ["core.defaults"] = {}, -- Loads default behaviour
          ["core.concealer"] = {
            config = {
              icon_preset = "diamond",
              folds = true,
            },
          }, -- Adds pretty icons to your documents
          ["core.dirman"] = { -- Manages Neorg workspaces
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
          ["core.esupports.metagen"] = { config = { update_date = false } }, --do not update date until https://github.com/nvim-neorg/neorg/issues/1579
        },
      })
    end,
  },
}
