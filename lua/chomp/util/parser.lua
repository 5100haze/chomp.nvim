local M = {}

local atom
local rss

local feed_type = function(xml) end

M.new = function(xml)
  if feed_type(xml) == 'atom' then return setmetatable({ xml = xml }, atom) end
  if feed_type(xml) == 'rss' then return setmetatable({ xml = xml }, rss) end
end

atom = {
  __index = {
    title = function(self) end,
    last_updated = function(self) end,
    posts = function(self) end,
  },
}

rss = {
  __index = {
    title = function(self) end,
    last_updated = function(self) end,
    posts = function(self) end,
  },
}

return M
