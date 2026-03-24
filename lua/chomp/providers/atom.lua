local Base = {}
Base.__index = Base

local Atom10 = setmetatable({}, Base)
Atom10.__index = Atom10

Atom10.title = function(self) end

Atom10.last_updated = function(self) end

Atom10.posts = function(self) end

return {
  [1.0] = Atom10,
}
