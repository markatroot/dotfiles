require("colorizer").setup({
  filetypes = { "*" },
  user_default_options = {
    names = false,   -- don't highlight words like "red"
    css = true,      -- rgb(), hsl(), etc.
    mode = "background", -- or "foreground" / "virtualtext"
  },
})
