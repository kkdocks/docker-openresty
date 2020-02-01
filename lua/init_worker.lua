---
--- * -----------------------------------------------------------------------
--- *      nekoimi <i@sakuraio.com>
--- *                             ------
--- *  Copyright (c) https://nekoimi.com All rights reserved.
--- * -----------------------------------------------------------------------
---

local ip_blacklist = require('ipblacklist')

local function cron_refresh_blacklist()
    ---
    --- 定时从redis中获取ip黑名单列表刷新到共享内存
    ---

    if ngx.worker.count() > 0 then
        if 0 == ngx.worker.id() then
            local ok, err = ngx.timer.every(
                    global_config:get("blacklist.refresh_at"),
                    ip_blacklist.refresh_blacklist
            )
            if not ok then
                return ngx.log(
                        ngx.ERR,
                        "failed to add cron of refresh_blacklist [ " .. err .. " ]"
                )
            end
        end
    end

end

cron_refresh_blacklist()

--resty_auto_ssl:init_worker()
