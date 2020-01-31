---
--- * -----------------------------------------------------------------------
--- *      nekoimi <i@sakuraio.com>
--- *                             ------
--- *  Copyright (c) https://nekoimi.com All rights reserved.
--- * -----------------------------------------------------------------------
---

local M = {}
M.__version = '1.0'

function M.get_client_ip()
    local request_headers = ngx.req.get_headers();
    return request_headers["X-REAL-IP"] or request_headers["X_FORWARDED_FOR"] or ngx.var.remote_addr or nil;
end

function M.file_exists(path)
    local file = io.open(path, 'rb');
    if file then
        file:close();
    end
    return file ~= nil;
end

function M.file_get_contents(path)
    local file = io.open(path, 'r');
    if not file then
        ngx.log(ngx.ERR, "open file [" .. path .. "] err")
        return nil
    end
    local content = file:read('*a');
    file:close();
    return content;
end

function M.in_array(value, array)
    for _, v in ipairs(array) do
        if v == value then
            return true
        end
    end
    return false
end

return M