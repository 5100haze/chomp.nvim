local Base = {}
Base.__index = Base

local Rss20 = setmetatable({}, Base)
Rss20.__index = Rss20

Rss20.title = function(self) end

Rss20.last_updated = function(self) end

Rss20.posts = function(self) end

return {
  [2.0] = Rss20,
}
