local xml = require 'chomp.util.xml'

local Base = {}
Base.__index = Base

---@class Atom10
---@field _title string
---@field _updated string
---@field _els table[]
---@field _entries_from integer
local Atom10 = setmetatable({}, Base)
Atom10.__index = Atom10

---@type table<string, string> atom name => post field name
local POST_FIELDS = {
  title = 'title',
  link = 'url',
  id = 'guid',
  summary = 'summary',
  published = 'published_at',
  updated = 'updated_at',
}

local find_feed_el = function(doc)
  for _, k in ipairs(doc.kids) do
    if k.name == 'feed' then return k end
  end
end

---@param doc table
---@return Atom10
Atom10.new = function(doc)
  local self = setmetatable({ _doc = doc }, Atom10)

  local feedel = find_feed_el(doc)
  if not feedel then error 'no <feed> element' end

  local channel_els = feedel.el
  local i = 1
  while channel_els[i] and channel_els[i].name ~= 'entry' do
    i = i + 1
  end

  local meta = xml.extract({ 'title', 'updated' }, { table.unpack(channel_els, 1, i - 1) })
  self._title = meta.title
  self._updated = meta.updated
  self._entries_from = i
  self._els = channel_els

  return self
end

---@return string?
Atom10.get_title = function(self) return self._title end

---@return string?
Atom10.get_updated = function(self) return self._updated end

---@return fun(): Post?
Atom10.posts = function(self)
  local want = vim.tbl_keys(POST_FIELDS)
  local i = self._entries_from - 1
  local els = self._els

  return function()
    i = i + 1
    while els[i] and els[i].name ~= 'entry' do
      i = i + 1
    end
    if not els[i] then return nil end
    local raw = xml.extract(want, els[i].el)
    return xml.map_fields(raw, POST_FIELDS)
  end
end

return {
  ['1.0'] = Atom10,
}
