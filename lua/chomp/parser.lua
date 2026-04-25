local slaxdom = require 'chomp.vendor.slaxdom'
local providers = require 'chomp.providers'

local M = {}

local feed_type = function(doc)
  for i = 1, 10 do
    local el = doc.kids[i]
    if el.name == 'feed' then return 'atom', '1.0' end
    if el.name == 'rss' then return 'rss', el.attr.version end
  end
end

M.new = function(xml)
  local doc = slaxdom:parse(xml)
  local kind, version = feed_type(doc)
  if kind and version then return providers[kind][version].new(doc) end
end

return M
