-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
-- require("cmp").setup({})
require("mason-lspconfig").setup({
  ensure_installed = { "clangd" },
})

vim.opt.guifont = "Fira Code Semibold:h12"
vim.g.neovide_fullscreen = false
vim.g.neovide_cursor_vfx_mode = "railgun"

local modified = false
vim.api.nvim_create_autocmd({ "UIEnter", "ColorScheme" }, {
  callback = function()
    local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
    if normal.bg then
      io.write(string.format("\027]11;#%06x\027\\", normal.bg))
      modified = true
    end
  end,
})

vim.api.nvim_create_autocmd("UILeave", {
  callback = function()
    if modified then
      io.write("\027]111\027\\")
    end
  end,
})
