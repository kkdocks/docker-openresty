---
--- * -----------------------------------------------------------------------
--- *      nekoimi <i@sakuraio.com>
--- *                             ------
--- *  Copyright (c) https://nekoimi.com All rights reserved.
--- * -----------------------------------------------------------------------
---

if ngx.var.http_origin then
    local cjson = require('cjson')
    local origin_allow = cjson.decode(lua_config:get("origin_allow"))

    if not tool.in_array("*", origin_allow) then
        if not tool.in_array(ngx.var.http_origin, origin_allow) then
            ngx.header.content_type = "application/json; charset=UTF-8";
            ngx.status = 403
            return ngx.say(cjson.encode({
                message = "Not allowed."
            }))
        end
    end
    ngx.header['Access-Control-Allow-Credentials'] = "true";
    ngx.header['Access-Control-Allow-Methods'] = "GET,POST,OPTIONS,PUT,DELETE";
    ngx.header["Access-Control-Allow-Headers"] = "Authorization,Content-Type,Accept,Origin,User-Agent,DNT,Cache-Control,Keep-Alive,X-Requested-With,If-Modified-Since"
    if tool.in_array("*", origin_allow) then
        ngx.header['Access-Control-Allow-Origin'] = "*";
    else
        ngx.header['Access-Control-Allow-Origin'] = ngx.var.http_origin;
    end
    if ngx.req.get_method() == "OPTIONS" then
        ngx.header['Access-Control-Max-Age'] = "86400";
        ngx.header['Content-Length'] = "0";
    end
end