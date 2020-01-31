---
--- * -----------------------------------------------------------------------
--- *      nekoimi <i@sakuraio.com>
--- *                             ------
--- *  Copyright (c) https://nekoimi.com All rights reserved.
--- * -----------------------------------------------------------------------
---
local redis_factory = require('redis')

local M = {}
M.__version = '1.0';

local blacklist_key = "nekoimi.openresty.ip.blacklist.cache"
local blacklist_ip_expire_key = "nekoimi.openresty.ip.blacklist.expire:"

function M.refresh_blacklist()
    local redis = redis_factory.connection()
    if redis then
        local blacklist = redis:smembers(blacklist_key)
        if blacklist then
            global_ip_blacklist:flush_all()
            for _, ip_address in pairs(blacklist) do
                global_ip_blacklist:set(ip_address, true)
            end
        end
    end
    redis_factory.destruct(redis)
end

function M.blacklist_remove(client_ip)
    local result = false

    local redis = redis_factory.connection()
    if redis and redis:exists(blacklist_ip_expire_key .. client_ip) == 0 then
        if redis:sismember(blacklist_key, client_ip) > 0 then
            if redis:srem(blacklist_key, client_ip) > 0 then
                result = true
            end
        end
    end
    redis_factory.destruct(redis)

    return result
end

function M.blacklist_append(client_ip)
    local redis = redis_factory.connection()
    if redis and redis:sadd(blacklist_key, client_ip) > 0 then
        redis:setex(blacklist_ip_expire_key .. client_ip, global_config:get("blacklist.expire_at"), client_ip)
    end
    redis_factory.destruct(redis)
end

function M.blacklist_clear(clear_ip)
    local redis = redis_factory.connection()
    if redis then
        redis:del(blacklist_ip_expire_key .. clear_ip)
        if redis:sismember(blacklist_key, clear_ip) > 0 then
            redis:srem(blacklist_key, clear_ip)
        end
    end
    redis_factory.destruct(redis)
end

return M