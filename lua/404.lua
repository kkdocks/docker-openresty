---
--- * -----------------------------------------------------------------------
--- *      nekoimi <i@sakuraio.com>
--- *                             ------
--- *  Copyright (c) https://nekoimi.com All rights reserved.
--- * -----------------------------------------------------------------------
---

--[[
    
--]]

local ok, err
local ip_blacklist = require('ipblacklist')

local function ip_tmp_incr_cache_key(client_ip)
    return 'nekoimi.openresty.tmp.ip.incr.' .. client_ip
end

if ngx.HTTP_NOT_FOUND == ngx.status then
    local client_ip = utils.get_client_ip()
    if client_ip then
        local key = ip_tmp_incr_cache_key(client_ip)
        local curr_incr_num
        curr_incr_num, err = global_ip_count:get(key)
        if nil == curr_incr_num then
            ok, err = global_ip_count:set(key, 1, global_config:get("ip404count.expire_at"))
            if not ok then
                ngx.log(ngx.ERR,
                        "[404.lua] line: " ..
                                debug.getinfo(1).currentline ..
                                "failed to init set tmp ip incr ( " .. client_ip .. " ) , err : " ..
                                err
                )
            end
        else
            if curr_incr_num < global_config:get("ip404count.trigger_forbidden_count") then
                ok, err = global_ip_count:incr(key, 1)
                if err ~= nil then
                    ngx.log(ngx.ERR,
                            "[404.lua] line: " ..
                                    debug.getinfo(1).currentline ..
                                    "failed to set tmp ip incr ( " .. client_ip .. " ) , err : " ..
                                    err
                    )
                end
            else
                --- append redis & blacklist
                ip_blacklist.blacklist_append(client_ip)
                global_ip_blacklist:set(client_ip, true)
                return ngx.exit(403);
            end
        end
    end
end

--- default 404

ngx.header.content_type = "text/html; charset=UTF-8";
ngx.status = 404
return ngx.say(utils.file_get_contents(
    global_config:get("error_page.404")
));
