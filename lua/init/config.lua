---
--- * -----------------------------------------------------------------------
--- *      nekoimi <i@sakuraio.com>
--- *                             ------
--- *  Copyright (c) https://nekoimi.com All rights reserved.
--- * -----------------------------------------------------------------------
---

tool = require('utils')
lua_config = ngx.shared.lua_shared_repository
lua_ip_tmp = ngx.shared.lua_shared_ip_tmp_table
lua_blacklist = ngx.shared.lua_shared_ip_blacklist

local cjson = require('cjson')

local config_file_name = "config.json"
local dirname = string.match(
        string.sub(debug.getinfo(1, 'S').source, 2, -1), "^.*/"
)
local config_file = dirname .. "../" .. config_file_name

local function load_config()
    if not tool.file_exists(config_file) then
        ngx.log(ngx.ERR, "config not exists.")
        return
    end

    local config = cjson.decode(tool.file_get_contents(config_file))
    for item_name, value in pairs(config) do
        if value then
            if type(value) == "string" then
                lua_config:set(item_name, value)
            elseif type(value) == "table" then
                if item_name == "origin_allow" then
                    lua_config:set(item_name, cjson.encode(value))
                else
                    for k, v in pairs(value) do
                        lua_config:set(item_name .. "." .. k, v)
                    end
                end
            end
        end
    end
end

load_config()
