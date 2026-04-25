local url = require 'chomp.util.url'

local M = {}

local parse_headers = function(raw)
  local parse_single = function(line)
    local sep = string.find(line, ':', 1, true)
    if not sep then return nil end
    local key = string.sub(line, 1, sep - 1):lower()
    local val = vim.trim(string.sub(line, sep + 1))
    return key, val
  end

  local res = {}
  local lines = vim.split(raw, '\n', { trimempty = true })
  for i = 2, #lines do
    local header, value = parse_single(lines[i])
    if not header then break end
    res[string.lower(header)] = value
  end

  return res
end

M.head = function(_url, callback)
  vim.system({ 'curl', '-L', '-s', '-I', url.normalize(_url) }, { text = true }, function(obj)
    if obj.code ~= 0 then
      callback(nil, 'curl exited with code ' .. obj.code .. ': ' .. (obj.stderr or ''))
      return
    end
    if type(obj.stdout) ~= 'string' then callback(nil, 'no output from curl') end

    callback(parse_headers(obj.stdout), nil)
  end)
end

M.get = function(_url, callback)
  vim.system({ 'curl', '-L', '-s', '-D', '%', url.normalize(_url) }, { text = true }, function(obj)
    if obj.code ~= 0 then callback(nil, 'curl exited with code ' .. obj.code .. ': ' .. (obj.stderr or '')) end
    if type(obj.stdout) ~= 'string' then callback(nil, 'no output from curl') end
    callback({
      xml = obj.stdout,
      headers = parse_headers(obj.stderr),
    }, nil)
  end)
end

return M
