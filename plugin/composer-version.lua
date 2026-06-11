if vim.g.loaded_composer_version then
  return
end
vim.g.loaded_composer_version = true

local group = vim.api.nvim_create_augroup("ComposerVersion", { clear = true })

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
  group = group,
  pattern = "composer.json",
  callback = function(args)
    require("composer-version").refresh(args.buf)
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  group = group,
  pattern = "composer.lock",
  callback = function()
    require("composer-version").refresh_all()
  end,
})

vim.api.nvim_create_user_command("ComposerVersion", function(args)
  local composer_version = require("composer-version")
  if args.args == "toggle" then
    composer_version.toggle()
  else
    composer_version.refresh_all()
  end
end, {
  nargs = "?",
  complete = function()
    return { "refresh", "toggle" }
  end,
})
