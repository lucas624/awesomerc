local awful = require("awful")
local menubar = require("menubar")
local naughty = require("naughty")

-- Mouse bindings {{{
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- Key bindings {{{
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "Tab", function ()
        awful.client.focus.byidx( 1)
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey, "Shift"   }, "Tab", function ()
        awful.client.focus.byidx(-1)
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation {{{
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    -- }}}

    -- Standard program {{{
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey,           }, "q", function()
        local fd = io.popen("if [ $(synclient -l | grep TouchpadOff | awk '{print $3}') == 1 ] ; then synclient touchpadoff=0; else synclient touchpadoff=1; fi")
        fd:close()
    end),
    awful.key({ modkey,           }, "l", function()
        local fd = io.popen("xscreensaver-command -lock")
        fd:close()
    end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),
    -- }}}

    -- Prompt {{{
    awful.key({ modkey            }, "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey            }, "x", function ()
        awful.prompt.run({ prompt = "Run Lua code: " },
        mypromptbox[mouse.screen].widget,
        awful.util.eval, nil,
        awful.util.getdir("cache") .. "/history_eval")
    end),
    -- }}}

    -- Menubar {{{
    awful.key({ modkey            }, "p", function() menubar.show() end),
    -- }}}

    -- Custom {{{
    awful.key({ modkey, "Shift"   }, "Right", function ()
        if client.focus then
            local tag = awful.tag.gettags(client.focus.screen)[awful.tag.getidx(client.focus.tag) + 1]
            if tag then
                awful.client.movetotag(tag)
                awful.tag.viewnext()
            end
        end
    end),
    awful.key({ modkey, "Shift"   }, "Left", function ()
        if client.focus then
            local tag = awful.tag.gettags(client.focus.screen)[awful.tag.getidx(client.focus.tag) - 1]
            if tag then
                awful.client.movetotag(tag)
                awful.tag.viewprev()
            end
        end
    end),
    awful.key({ modkey, "Shift"   }, "d", function () awful.tag.delete() end),
    awful.key({ modkey, "Shift"   }, "r", function ()
        awful.prompt.run(
            { prompt = "New tag name: " },
            mypromptbox[mouse.screen].widget,
            function(new_name)
                if not new_name or #new_name == 0 then
                    return
                else
                    local screen = mouse.screen
                    local tag = awful.tag.selected(screen)
                    if tag then
                        tag.name = new_name
                    end
                end
            end
        )
    end),
    awful.key({ modkey,           }, "a", function ()
        awful.prompt.run(
            { prompt = "New tag name: " },
            mypromptbox[mouse.screen].widget,
            function(new_name)
                props = {selected = true}
                t = awful.tag.add(new_name, props)
                awful.tag.viewonly(t)
            end
        )
    end),
    -- Audio hotkeys {{{
    awful.key({                   }, "XF86AudioNext", function() 
        local fd = io.popen('echo "next" | nc localhost 6600')
        local response = fd:read("*all")
        local result = response:match(".*\n(%u+)\n")
        if not result then
            naughty.notify({
                icon    = awful.util.getdir("config") .. "/Icons/warning_64.png",
                preset  = naughty.config.presets.critical,
                title   = "next song debug"
            })
        end
        fd:close()
    end),
    awful.key({                   }, "XF86AudioPrev", function()
        local fd = io.popen('echo "previous" | nc localhost 6600')
        local response = fd:read("*all")
        local result = response:match(".*\n(%u+)\n")
        if not result then
            naughty.notify({
                icon    = awful.util.getdir("config") .. "/Icons/warning_64.png",
                preset  = naughty.config.presets.critical,
                title   = "prev song debug"
            })
        end
        fd:close()
    end),
    awful.key({                   }, "XF86AudioStop", function()
        local fd = io.popen('echo "stop" | nc localhost 6600')
        local response = fd:read("*all")
        local result = response:match(".*\n(%u+)\n")
        if not result then
            naughty.notify({
                icon    = awful.util.getdir("config") .. "/Icons/warning_64.png",
                preset  = naughty.config.presets.critical,
                title   = "stop song debug"
            })
        end
        fd:close()
    end),
    awful.key({                   }, "XF86AudioPlay", function()
        local fd = io.popen('echo "status" | nc localhost 6600')
        local response = fd:read("*all")
        local state = response:match("state: (%l+)")
        fd:close()
        local action = ""
        if state == "stop" then action = "play" end
        if state == "pause" then action = "play" end
        if state == "play" then action = "pause 1" end
        local fd = io.popen('echo "' .. action .. '" | nc localhost 6600')
        local response = fd:read("*all")
        local result = response:match(".*\n(%u+)\n")
        if not result then
            naughty.notify({
                icon    = awful.util.getdir("config") .. "/Icons/warning_64.png",
                preset  = naughty.config.presets.critical,
                title   = "pause song debug"
            })
        end
        fd:close()
    end),
    awful.key({                   }, "XF86AudioLowerVolume", function()
        local fd = io.popen('echo "status" | nc localhost 6600')
        local response = fd:read("*all")
        local volume = tonumber(response:match("volume: (%d+)"))
        fd:close()
        volume = volume - 2
        if volume < 0 then volume = 0 end
        local fd = io.popen('echo "setvol ' .. volume .. '" | nc localhost 6600')
        local response = fd:read("*all")
        local result = response:match(".*\n(%u+)\n")
        if not result then
            naughty.notify({
                icon    = awful.util.getdir("config") .. "/Icons/warning_64.png",
                preset  = naughty.config.presets.critical,
                title   = "pause song debug"
            })
        end
        fd:close()
    end),
    awful.key({                   }, "XF86AudioRaiseVolume", function()
        local fd = io.popen('echo "status" | nc localhost 6600')
        local response = fd:read("*all")
        local volume = tonumber(response:match("volume: (%d+)"))
        fd:close()
        volume = volume + 2
        if volume > 100 then volume = 100 end
        local fd = io.popen('echo "setvol ' .. volume .. '" | nc localhost 6600')
        local response = fd:read("*all")
        local result = response:match(".*\n(%u+)\n")
        if not result then
            naughty.notify({
                icon    = awful.util.getdir("config") .. "/Icons/warning_64.png",
                preset  = naughty.config.presets.critical,
                title   = "pause song debug"
            })
        end
        fd:close()
    end)
    -- }}}
    -- }}}
)



clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,           }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))
