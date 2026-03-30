local slaxdom = require 'chomp.vendor.slaxdom'
local providers = require 'chomp.providers'

local M = {}

local feed_type = function(doc)
  local topel = doc.kids[3]
  if topel.name == 'feed' then return 'atom', '1.0' end
  if topel.name == 'rss' then return 'rss', topel.attr.version end
end

M.new = function(xml)
  local doc = slaxdom:parse(xml)
  local kind, version = feed_type(doc)
  if kind and version then return providers[kind][version].new(doc) end
end

return M
