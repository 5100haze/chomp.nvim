local config = require 'chomp.config'
local state = require 'chomp.state'
local util = require 'chomp.util'

local M = {}

M.setup = function(opts)
  config.set(opts or {})
  local _config = config.current
  -- TODO: currently just load entire db into state, should make it queryable or less wasteful..
  local _state = state.load()

  local state_feeds = {}
  for f in _state.feeds do
    state_feeds[f.url] = f
  end

  local feeds_tmp = {}
  for f in _config.feeds do
    local normalized = util.url.normalize(f)
    if state_feeds[normalized] then
      table.insert(feeds_tmp, state_feeds[normalized])
    else
      table.insert(feeds_tmp, _state.new_feed(normalized))
    end
  end
  _state.feeds = feeds_tmp

  _state.dump()

  require 'chomp.api.commands'
end

return M
