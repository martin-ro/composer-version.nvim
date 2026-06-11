local M = {}

M.config = {
  highlight = "ComposerVersion",
  enabled = true,
}

local ns = vim.api.nvim_create_namespace("composer-version")

local function read_lock(json_path)
  local lock_path = vim.fs.joinpath(vim.fs.dirname(json_path), "composer.lock")

  local file = io.open(lock_path, "r")
  if not file then
    return nil
  end

  local content = file:read("*a")
  file:close()

  local ok, lock = pcall(vim.json.decode, content)
  if not ok or type(lock) ~= "table" then
    return nil
  end

  local versions = {}
  for _, group in ipairs({ "packages", "packages-dev" }) do
    for _, package in ipairs(lock[group] or {}) do
      if type(package) == "table" and package.name and package.version then
        versions[package.name] = package.version
      end
    end
  end

  return versions
end

function M.clear(buf)
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
end

function M.refresh(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_loaded(buf) then
    return
  end

  M.clear(buf)

  if not M.config.enabled then
    return
  end

  local versions = read_lock(vim.api.nvim_buf_get_name(buf))
  if not versions then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  for i, line in ipairs(lines) do
    local name = line:match('^%s*"([^"]+)"%s*:')
    local version = name and versions[name]
    if version then
      vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
        virt_text = { { version, M.config.highlight } },
        virt_text_pos = "eol",
      })
    end
  end
end

function M.refresh_all()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.fs.basename(vim.api.nvim_buf_get_name(buf)) == "composer.json" then
      M.refresh(buf)
    end
  end
end

function M.toggle()
  M.config.enabled = not M.config.enabled
  M.refresh_all()
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

vim.api.nvim_set_hl(0, "ComposerVersion", { default = true, link = "Comment" })

return M
