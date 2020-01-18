---
--- * -----------------------------------------------------------------------
--- *      nekoimi <i@sakuraio.com>
--- *                             ------
--- *  Copyright (c) https://nekoimi.com All rights reserved.
--- * -----------------------------------------------------------------------
---

local ip_blacklist = require('ipblacklist')

local client_ip = tool.getClientIp()
if not client_ip then
    return
end

local exists = lua_blacklist:get(client_ip)
if nil ~= exists then
    local bool = ip_blacklist.blacklist_remove(client_ip)
    if not bool then
        return ngx.exit(403)
    end
end

----- origin allow
--if ngx.req.get_method() == "OPTIONS" then
--    return ngx.exit(204)
--end
