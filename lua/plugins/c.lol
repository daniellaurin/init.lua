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
      "neovim/nvim-lspconfig", -- Collection of configurations for built-in LSP client
      "hrsh7th/nvim-cmp", -- Autocompletion plugin
      "hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
      "saadparwaiz1/cmp_luasnip", -- Snippets source for nvim-cmp
      "L3MON4D3/LuaSnip", -- Snippets plugin
      --LSP settings
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "octaltree/cmp-look", -- Use the look command to use dictionary
    },
    ---@class opts cmp.ConfigSchema
    opts = function(_, opts)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      -- luasnip setup
      local luasnip = require("luasnip")

      -- nvim-cmp setup
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
          sources = {
            { name = "neorg" },
          },
        },
      })

      -- Integrate 'look' source configuration here
      opts.sources = {
        {
          name = "look",
          keyword_length = 2,
          option = {
            convert_case = true,
            loud = true,
            --dict = '/usr/share/dict/words'
          },
        },

        { name = "nvim_lsp" },
        { name = "nvim_lua" },
        { name = "luasnip" }, -- For luasnip users.
        { name = "buffer" },
        { name = "path" },
        { name = "neorg" },
      }

      -- Add additional capabilities supported by nvim-cmp
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local lspconfig = require("lspconfig")

      -- Enable some language servers with the additional completion capabilities offered by nvim-cmp
      local servers = { "clangd" } --you can add languages here
      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup({
          -- on_attach = my_custom_on_attach,
          capabilities = capabilities,
        })
      end

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
