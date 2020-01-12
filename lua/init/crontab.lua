---
--- * -----------------------------------------------------------------------
--- *      nekoimi <i@sakuraio.com>
--- *                             ------
--- *  Copyright (c) https://nekoimi.com All rights reserved.
--- * -----------------------------------------------------------------------
---

local ip_blacklist = require('ipblacklist')

local ok, err;
---
--- 定时从redis中获取ip黑名单列表刷新到共享内存
---
--- 刷新共享内存中的黑名单列表
local function refresh_blacklist()
    ip_blacklist.refresh_blacklist()
end

local worker_num = ngx.worker.count();
if worker_num then
    local curr_worker_id = ngx.worker.id();
    if 0 == curr_worker_id then
        ok, err = ngx.timer.every(lua_config:get("blacklist.refresh_at"), refresh_blacklist)
        if not ok then
            return ngx.log(ngx.ERR, 'failed to add crontab of refresh_blacklist [ ' .. err .. ' ]')
        end
    end
end