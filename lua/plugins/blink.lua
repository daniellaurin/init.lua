return {
  "saghen/blink.cmp",
  dependencies = {
    "ribru17/blink-cmp-spell",
    "Kaiser-Yang/blink-cmp-dictionary",
  },
  opts = function(_, opts)
    local function has_words_before()
      local line, col = (unpack or table.unpack)(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end

    opts.sources = opts.sources or {}
    opts.sources.default = { "lsp", "path", "snippets", "buffer", "dictionary", "spell" }
    opts.sources.providers = opts.sources.providers or {}

    -- Buffer source
    opts.sources.providers.buffer = {
      name = "buffer",
      module = "blink.cmp.sources.buffer",
      min_keyword_length = 3,
      max_items = 5,
      opts = {
        get_bufnrs = function()
          return vim.tbl_filter(function(buf)
            return vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == ""
          end, vim.api.nvim_list_bufs())
        end,
      },
    }

    -- Spell source
    opts.sources.providers.spell = {
      name = "Spell",
      module = "blink-cmp-spell",
      min_keyword_length = 3,
      max_items = 5,
      opts = {
        max_entries = 5,
        use_cmp_spell_sorting = true,
        enable_in_context = function()
          if not vim.opt_local.spell:get() then
            return false
          end
          if vim.tbl_contains({ "markdown", "gitcommit", "text" }, vim.bo.filetype) then
            return true
          end
          local curpos = vim.api.nvim_win_get_cursor(0)
          local ok, captures =
            pcall(vim.treesitter.get_captures_at_pos, 0, math.max(0, curpos[1] - 1), math.max(0, curpos[2] - 1))
          if not ok or not captures then
            return false
          end
          for _, cap in ipairs(captures) do
            if cap.capture == "spell" then
              return true
            elseif cap.capture == "nospell" then
              return false
            end
          end
          return false
        end,
      },
    }

    -- Dictionary source
    opts.sources.providers.dictionary = {
      module = "blink-cmp-dictionary",
      name = "Dict",
      min_keyword_length = 3,
      max_items = 5,
      opts = {
        dictionary_files = { "/usr/share/dict/words" },
      },
    }

    -- Completion behavior
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

    -- Keymaps
    opts.keymap = {
      preset = "none",

      ["<Tab>"] = {
        function(cmp)
          if cmp.is_visible() and has_words_before() then
            return cmp.select_and_accept()
          elseif cmp.snippet_active() then
            return cmp.snippet_forward()
          end
        end,
        "fallback",
      },

      ["<S-Tab>"] = {
        function(cmp)
          if cmp.is_visible() and has_words_before() then
            return cmp.select_prev()
          elseif cmp.snippet_active() then
            return cmp.snippet_backward()
          end
        end,
        "fallback",
      },

      ["<Up>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },
      ["<C-n>"] = { "select_next", "fallback" },

      ["<CR>"] = { "accept", "fallback" },
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-e>"] = { "hide", "fallback" },
      ["<C-u>"] = { "scroll_documentation_up", "fallback" },
      ["<C-d>"] = { "scroll_documentation_down", "fallback" },
    }

    return opts
  end,
}
