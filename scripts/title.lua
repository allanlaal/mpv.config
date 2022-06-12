-- File: title.lua
-- Throttle title updates to 1s intervals by default
-- Interval can also be set with e.g. --script-opts-add=title-interval=5
-- The title can be set normally via mpv.conf or changed at runtime

local opts = { interval = 1 }  -- in seconds
local title, expanded

local function update()
    if not title then return end
    expanded = "$>" .. mp.command_native({"expand-text", title})
    mp.set_property("title", expanded)
end

mp.observe_property("title", "string", function(_, v)
    if v == expanded then return end  -- our own (title not set by the user)
    title = v
    update()
end)

local timer
local function set_timer()
    if opts.interval <= 0 then
        mp.msg.error("title interval must be greater than 0 (" .. opts.interval .. ")")
        opts.interval = 1
    end
    if timer then timer:kill() end
    timer = mp.add_periodic_timer(opts.interval, update)
    update()
end

require("mp.options").read_options(opts, nil, set_timer)
set_timer()