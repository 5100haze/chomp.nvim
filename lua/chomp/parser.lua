local slaxdom = require 'chomp.vendor.slaxdom'
local providers = require 'chomp.providers'

local M = {}

local feed_type = function(doc)
  -- return type, version
end

M.new = function(xml)
  local doc = slaxdom:parse(xml)
  local type, version = feed_type(doc)
  return setmetatable({ doc = doc }, providers[type][version])
end

return M
