return {
  -- Disable default <tab> and <s-tab> behavior in LuaSnip
  {
    "L3MON4D3/LuaSnip",
    keys = function()
      return {}
    end,
  },
  -- Setup supertab in cmp and integrate 'look' source
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-emoji",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "f3fora/cmp-spell",
    },
    opts = function(_, opts)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local luasnip = require("luasnip")
      local cmp = require("cmp")

      -- Initialize mapping if it doesn't exist
      opts.mapping = opts.mapping or {}

      -- Integrate 'look' source configuration here
      opts.sources = opts.sources or {}

      local sources_to_add = {
        {
          name = "spell",
          option = {
            keep_all_entries = false,
            enable_in_context = function()
              return true
            end,
            preselect_correct_word = true,
          },
        },
        {
          name = "dictionary",
          keyword_length = 2,
        },
      }

      -- Add existing sources
      for _, source in ipairs(sources_to_add) do
        table.insert(opts.sources, source)
      end

      -- Add other sources if they don't already exist
      local source_names = {}
      for _, source in ipairs(opts.sources) do
        source_names[source.name] = true
      end

      for _, name in ipairs({ "spell", "nvim_lsp", "nvim_lua", "luasnip", "buffer", "path", "neorg" }) do
        if not source_names[name] then
          table.insert(opts.sources, { name = name })
        end
      end

      -- Add additional capabilities supported by nvim-cmp
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local lspconfig = require("lspconfig")

      -- Enable some language servers with the additional completion capabilities offered by nvim-cmp
      local servers = { "clangd" }
      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup({
          capabilities = capabilities,
        })
      end

      -- Configure spellsuggest for cmp-spell
      vim.opt.spell = true
      vim.opt.spelllang = { "en_us" }

      -- Now safely extend the mapping
      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      })
    end,
  },
}
