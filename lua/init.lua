---
--- * -----------------------------------------------------------------------
--- *      nekoimi <i@sakuraio.com>
--- *                             ------
--- *  Copyright (c) https://nekoimi.com All rights reserved.
--- * -----------------------------------------------------------------------
---

global_config = ngx.shared.lua_shared_config
global_ip_count = ngx.shared.lua_shared_ip_count
global_ip_blacklist = ngx.shared.lua_shared_ip_blacklist

--resty_auto_ssl = require("resty.auto-ssl"):new()
utils = require("utils")

local cjson = require("cjson")

local function load_config()

    local config_file_name = "config.json"
    local dirname = string.match(
        string.sub(debug.getinfo(1, 'S').source, 2, -1), "^.*/"
    )

    local config_file = dirname .. "/" .. config_file_name

    if not utils.file_exists(config_file) then
        ngx.log(ngx.ERR, "config not exists.")
        return
    end

    local config = cjson.decode(
        utils.file_get_contents(config_file)
    )

    for item_name, value in pairs(config) do
        if value then
            if type(value) == "string" then
                global_config:set(item_name, value)
            elseif type(value) == "table" then
                for k, v in pairs(value) do
                    global_config:set(item_name .. "." .. k, v)
                end
            end
        end
    end

end

local function load_resty_auto_ssl()
    resty_auto_ssl:set("allow_domain", function(domain)
        ngx.log(ngx.ERR, "init_by_lua_block: allow_domain / domain => " .. domain)
        return true
        -- return ngx.re.match(domain, "^(nekoimi.com|sakuraio.com|403forbidden.run)$", "ijo")
    end)

    resty_auto_ssl:init()
end

load_config()
-- resty auto ssl
--load_resty_auto_ssl()