---
--- * -----------------------------------------------------------------------
--- *      nekoimi <i@sakuraio.com>
--- *                             ------
--- *  Copyright (c) https://nekoimi.com All rights reserved.
--- * -----------------------------------------------------------------------
---

local ip_blacklist = require('ipblacklist')

local client_ip = utils.get_client_ip()
if not client_ip then
    return
end

local exists = global_ip_blacklist:get(client_ip)
if nil ~= exists then
    local bool = ip_blacklist.blacklist_remove(client_ip)
    if not bool then
        return ngx.exit(403)
    end
end
