return {
  -- Configure blink.cmp with optimized dictionary support
  {
    "saghen/blink.cmp",
    dependencies = {
      "ribru17/blink-cmp-spell", -- Spell source for blink.cmp
      {
        "Kaiser-Yang/blink-cmp-dictionary",
        dependencies = { "nvim-lua/plenary.nvim" },
      },
    },
    opts = function(_, opts)
      -- Enable spell checking
      vim.opt.spell = true
      vim.opt.spelllang = { "en_us" }

      -- Configure sources to include both spell and dictionary
      opts.sources = opts.sources or {}
      opts.sources.default = { "lsp", "path", "snippets", "buffer", "dictionary", "spell" }

      -- Configure providers
      opts.sources.providers = opts.sources.providers or {}

      -- Buffer source configuration
      opts.sources.providers.buffer = {
        name = "buffer",
        module = "blink.cmp.sources.buffer",
        min_keyword_length = 1,
        max_items = 5, -- Reduced from 15
        opts = {
          get_bufnrs = function()
            return vim.api.nvim_list_bufs()
          end,
        },
      }

      -- Spell source configuration
      opts.sources.providers.spell = {
        name = "Spell",
        module = "blink-cmp-spell",
        min_keyword_length = 1,
        max_items = 5, -- Limited spell suggestions
        opts = {
          enable_in_context = function()
            local curpos = vim.api.nvim_win_get_cursor(0)
            local captures = vim.treesitter.get_captures_at_pos(0, curpos[1] - 1, curpos[2] - 1)
            local in_spell_capture = false
            for _, cap in ipairs(captures) do
              if cap.capture == "spell" then
                in_spell_capture = true
              elseif cap.capture == "nospell" then
                return false
              end
            end
            return in_spell_capture
          end,
        },
      }

      opts.sources.providers.dictionary = {
        module = "blink-cmp-dictionary",
        name = "Dict",
        min_keyword_length = 1,
        max_items = 5,
        opts = {
          dictionary_files = nil, -- Set to nil when using rg directly
          get_command = "rg",
          get_command_args = function(prefix, _)
            return {
              "--color=never",
              "--no-line-number",
              "--no-messages",
              "--no-filename",
              "--smart-case",
              "--max-count=5", -- Limit results at source
              "--",
              "^" .. prefix, -- Match start of line
              "/usr/share/dict/words",
            }
          end,
        },
      }

      -- Configure fuzzy sorting
      opts.fuzzy = opts.fuzzy or {}
      opts.fuzzy.sorts = {
        function(a, b)
          local sort = require("blink.cmp.fuzzy.sort")
          if a.source_id == "spell" and b.source_id == "spell" then
            return sort.label(a, b)
          end
        end,
        "score",
        "kind",
        "label",
      }

      -- Configure completion behavior
      opts.completion = opts.completion or {}
      opts.completion.trigger = opts.completion.trigger or {}
      opts.completion.trigger.show_on_insert_on_trigger_character = true

      opts.completion.menu = opts.completion.menu or {}
      opts.completion.menu.auto_show = true

      opts.completion.documentation = opts.completion.documentation or {}
      opts.completion.documentation.auto_show = true
      opts.completion.documentation.auto_show_delay_ms = 200

      opts.completion.ghost_text = opts.completion.ghost_text or {}
      opts.completion.ghost_text.enabled = true

      -- Custom keymaps for cycling through all options
      opts.keymap = {
        preset = "none",

        ["<Tab>"] = {
          function(cmp)
            if cmp.is_visible() then
              return cmp.select_next()
            else
              return cmp.show()
            end
          end,
          "snippet_forward",
          "fallback",
        },

        ["<S-Tab>"] = {
          function(cmp)
            if cmp.is_visible() then
              return cmp.select_prev()
            else
              return cmp.show()
            end
          end,
          "snippet_backward",
          "fallback",
        },

        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<C-Space>"] = { "show", "fallback" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<C-u>"] = { "scroll_documentation_up", "fallback" },
        ["<C-d>"] = { "scroll_documentation_down", "fallback" },
      }

      return opts
    end,
  },

  {
    "L3MON4D3/LuaSnip",
    keys = function()
      return {}
    end,
  },

  -- Configure LSP servers including Java
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {},
        jdtls = {},
      },
    },
  },
}
