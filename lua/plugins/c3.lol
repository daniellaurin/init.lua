return {
  -- Disable default <tab> and <s-tab> behavior in LuaSnip
  --
  {
    "L3MON4D3/LuaSnip",
    keys = function()
      return {}
    end,
  },
  -- Setup supertab in cmp
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
      "octaltree/cmp-look",
    },
    config = function(_, opts)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local luasnip = require("luasnip")
      local cmp = require("cmp")

      -- Make sure we're completely overriding any previous configuration
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        sources = {
          {
            name = "look",
            keyword_length = 2,
            option = {
              convert_case = true,
              loud = true,
            },
          },
          { name = "nvim_lsp" },
          { name = "nvim_lua" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
          { name = "neorg" },
        },
        -- Define mapping directly in the main setup
        mapping = {
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

          -- Add enter to confirm selection
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        },
        -- Add completion settings
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
      })

      -- LSP setup
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local lspconfig = require("lspconfig")
      local servers = { "clangd" }
      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup({
          capabilities = capabilities,
        })
      end
    end,
  },
}
