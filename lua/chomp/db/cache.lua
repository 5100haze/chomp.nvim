local config = require 'chomp.config'

local M = {}

local path = config.current.data_dir .. '/chomp' .. '/cache'

M.save_feed = function(xml) end

M.get_feed = function(url) end

return M
