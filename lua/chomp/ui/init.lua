local M = {}

local spawn_float = function(opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 0.4)
  local height = opts.height or math.floor(vim.o.lines * 0.8)

  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local win_opts = {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = opts.border or 'none',
    zindex = 45,
  }

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, win_opts)

  local wconfig = {
    number = false,
    relativenumber = false,
    wrap = false,
    spell = false,
    foldenable = false,
    signcolumn = 'no',
    colorcolumn = '',
    cursorline = true,
  }

  local bconfig = {
    modifiable = false,
    swapfile = false,
    textwidth = 0,
    buftype = 'nofile',
    bufhidden = 'wipe',
    buflisted = false,
    filetype = 'chomp',
  }

  for key, value in pairs(wconfig) do
    vim.api.nvim_set_option_value(key, value, { win = win, scope = 'local' })
  end

  for key, value in pairs(bconfig) do
    vim.api.nvim_set_option_value(key, value, { buf = buf, scope = 'local' })
  end

  return { buf = buf, win = win }
end

M.open = function()
  local float = spawn_float {}
  vim.keymap.set('n', 'q', function() vim.api.nvim_win_close(float.win, true) end, { buffer = float.buf })
  --local namespace = vim.api.nvim_create_namespace("ns")
end

-- nvim_create_namespace()

-- drawing:
-- nvim_buf_clear_namespace()
-- nvim_buf_set_option() (set modifiable to true for just the update)
-- nvim_buf_set_lines()

return M
