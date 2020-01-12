---
--- * -----------------------------------------------------------------------
--- *      nekoimi <i@sakuraio.com>
--- *                             ------
--- *  Copyright (c) https://nekoimi.com All rights reserved.
--- * -----------------------------------------------------------------------
---

local M = {}
M.__version = '1.0';

local resty_redis = require('resty.redis');
local pool_size = 10;
local pool_max_free_time = 10000; --- 10s

function M.connection()
    local redis = resty_redis:new()

    redis:set_timeout(lua_config:get("redis.timeout"));

    local ok, err;
    ok, err = redis:connect(lua_config:get("redis.host"), lua_config:get("redis.port"))
    if not ok then
        ngx.log(ngx.ERR, "[redis.lua] failed to connent redis: " .. err)
        return nil
    end

    local used
    used, err = redis:get_reused_times()
    if 0 == used then
        ok, err = redis:auth(lua_config:get("redis.pass"))
        if not ok then
            ngx.log(ngx.ERR, "[redis.lua] failed to auth redis: " .. err)
            return nil
        end
    elseif err then
        ngx.log(ngx.ERR, "[redis.lua] failed to get redis used times" .. err)
        return nil
    end

    redis:select(lua_config:get("redis.database"))

    return redis;
end

function M.destruct(redis)
    if not redis then
        return
    end
    local ok, err
    ok, err = redis:set_keepalive(pool_max_free_time, pool_size)
    if not ok then
        ngx.log(ngx.ERR, "[redis.lua] failed to set keepalive: " .. err)
        return nil
    end

    --ok, err = redis:close()
    --if not ok then
    --    ngx.log(ngx.ERR, "[redis.lua] failed to close redis connection: " .. err)
    --end
end

return M;
