local db = require 'chomp.db'
local http = require 'chomp.util.http'
local url = require 'chomp.util.url'
local parser = require 'chomp.parser'

local M = {}

local state = {}

M.set = function(s)
  state = vim.tbl_deep_extend('force', state, s or {})
  return state
end

M.load = function()
  state = db.load() or {}
  return state
end

M.dump = function() db.save(state) end

M.mark_read = function(feed, id)
  if state.feeds and state.feeds[feed] then table.insert(state.feeds[feed].read, id) end
end

local new_feed = function(_url, callback)
  http.get(_url, function(res, err)
    if err then
      callback(nil, err)
      return
    end

    local xml = db.cache.save_feed(res.xml)
    callback({
      parser = parser.new(xml),
      read = {},
      fresh = true,
      control = {
        etag = res.headers.etag,
        modified = res.headers['last-modified'],
      },
    }, nil)
  end)
end

M.sync_feeds = function(urls)
  local feeds_tmp = {}
  local pending = 0

  local on_done = function()
    if pending == 0 then state.feeds = feeds_tmp end
  end

  for _, u in ipairs(urls) do
    local normalized = url.normalize(u)
    if state.feeds[normalized] then
      feeds_tmp[normalized] = state.feeds[normalized]
    else
      pending = pending + 1
      new_feed(normalized, function(feed, err)
        pending = pending - 1
        if err then
          vim.notify(err, vim.log.levels.WARN)
        else
          feeds_tmp[normalized] = feed
        end
        on_done()
      end)
    end
  end

  on_done()
end

M.refresh = function(urls)
  if not urls then urls = vim.tbl_keys(state.feeds) end

  for _, u in ipairs(urls) do
    if not state.feeds[u] then
      vim.notify('improper refresh: url not tracked', vim.log.levels.ERROR)
      return
    end

    local read = state.feeds[u].read
    http.head(u, function(res, err)
      if not res then
        vim.notify(err, vim.log.levels.WARN)
        return
      end

      if (res.etag ~= state.feeds[u].control.etag) or (res['last-modified'] ~= state.feeds[u].control.modified) then
        new_feed(u, function(feed, err)
          if err then
            vim.notify(err, vim.log.levels.WARN)
            return
          end
          feed.read = read
          state.feeds[u] = feed
        end)
      end
    end)
  end
end

M.get_post = function(id) end

M.is_updated = function(_url) end

M.current = state

return M
