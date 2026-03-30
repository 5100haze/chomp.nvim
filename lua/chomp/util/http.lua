local url = require 'chomp.util.url'

local M = {}

M.head = function(_url, callback)
  local parse_header = function(line)
    local sep = string.find(line, ':', 1, true)
    if not sep then return nil end
    local key = string.sub(line, 1, sep - 1):lower()
    local val = vim.trim(string.sub(line, sep + 1))
    return key, val
  end
  vim.system({ 'curl', '-L', '-s', '-I', util.url.normalize(url) }, { text = true }, function(obj)
    if obj.code ~= 0 then
      --notify
      return
    end
    local res = {}
    local raw = obj.stdout
    assert(type(raw) == 'string', 'nil output from curl')
    local lines = vim.split(raw, '\n', { trimempty = true })
    for i = 2, #lines do
      local header, value = parse_header(lines[i])
      if not header then return end
      res[header] = value
    end

    callback(res)
  end)
end

M.get = function(url, callback)
  vim.system({ 'curl', '-L', '-s', util.url.normalize(url) }, { text = true }, function(obj)
    if obj.code ~= 0 then return end
    local raw = obj.stdout
    assert(type(raw) == 'string', 'nil output from curl')
    callback(raw)
  end)
end

return M
