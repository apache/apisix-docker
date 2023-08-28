local require = require
local core = require("apisix.core")
local plugin = require("apisix.plugin")
local ngx = ngx
local ngx_worker_id = ngx.worker.id
local log = core.log

local plugin_name = "emmy-debugger"
local _M = {
    version = 1,
    priority = 50000,
    name = plugin_name,
    schema = {}
}

local plugin_attr = plugin.plugin_attr(plugin_name)
if not plugin_attr then
    log.error("Get plugin attr failed, skip dpg listen...")
    return _M
end

-- Code path differences inside and outside the associated Docker container
-- @see https://github.com/EmmyLua/EmmyLuaDebugger/blob/3f8853897fe001250e6e8a80ace5b603b1caccd8/emmy_core/emmy_debugger.cpp#L428
_G.emmy = {
    fixPath = function(path)
        return string.gsub(path, '/usr/local/apisix/apisix', plugin_attr['fix_path'])
    end
}

-- Load emmy and start listening.
package.cpath = package.cpath .. ";/usr/local/emmy/emmy_core.so"
local dbg = require("emmy_core")
local emmy_debug_port = plugin_attr['port'] or 9966
-- Nginx is a multi process model, it avoids repeatedly binding ports and only starts one worker.
if dbg and ngx_worker_id() == 0 then
    dbg.tcpListen("localhost", emmy_debug_port)
    log.warn("emmy-debugger dbg started: ", ngx_worker_id())
end

return _M
