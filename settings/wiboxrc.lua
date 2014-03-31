local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local radical = require("radical")

-- {{{ Clock widget
  clocktext = wibox.widget.textbox()
  function update_clock(clockwidget)
    local fd = io.popen('date +%S')
    local num = tonumber(fd:read("*all"))
    fd:close()
    local cadena
    if num % 2 == 0 then
      local fd = io.popen('date "+%e/%m %H:%M"')
      cadena = fd:read("*all")
      fd:close()
    else
      local fd = io.popen('date "+%e/%m %H %M"')
      cadena = fd:read("*all")
      fd:close()
    end
    clockwidget:set_text(cadena)
  end

  clock_timer = timer({ timeout = 1})
  clock_timer:connect_signal("timeout", function () update_clock(clocktext) end)
  clock_timer:start()
-- }}}

-- {{{ Simple Separator
  myseparator = wibox.widget.textbox()
  myseparator:set_text(" | ")
-- }}}

-- {{{ Create fraxbat widget
  fraxbat = wibox.widget.textbox()
  fraxbat:set_markup("Battery");

  -- Globals used by fraxbat
  fraxbat_st= nil
  fraxbat_ts= nil
  fraxbat_ch= nil
  fraxbat_now = nil
  fraxbat_est= nil

  -- Function for updating fraxbat
  function hook_fraxbat (tbw, bat)
     -- Battery Present?
     local fh= io.open("/sys/class/power_supply/".. bat .."/present", "r")
     if fh == nil then
        tbw:set_markup("No Bat")
        return(nil)
     end
     local stat= fh:read()
     fh:close()
     if tonumber(stat) < 1 then
        tbw:set_markup("Bat Not Present")
        return(nil)
     end

     -- Status (Charging, Full or Discharging)
     fh= io.open("/sys/class/power_supply/"..bat.."/status", "r")
     if fh == nil then
        tbw:set_markup("N/S")
        return(nil)
     end
     stat= fh:read()
     fh:close()
     if stat == 'Full' then
        tbw:set_markup("100%")
        return(nil)
     end
     stat= string.upper(string.sub(stat, 1, 1))
     if stat == 'D' then tag= 'i' else tag= 'b' end

     -- Remaining + Estimated (Dis)Charging Time
     local charge
     fh = io.open("/sys/class/power_supply/"..bat.."/charge_full_design", "r")
     if fh ~= nil then
        local full= fh:read()
        fh:close()
        full= tonumber(full)
        if full ~= nil then
          fh= io.open("/sys/class/power_supply/"..bat.."/charge_now", "r")
          if fh ~= nil then
             local now= fh:read()
             local est= ""
             fh:close()
             if fraxbat_st == stat then
                delta= os.difftime(os.time(),fraxbat_ts)
                est= math.abs(fraxbat_ch - now)
                if delta > 30 and est > 0 then
                   est= est/delta --est = unidad de carga perdida por segundo
                   if now == fraxbat_now then
                      est= fraxbat_est
                   else
                      fraxbat_est= est
                      fraxbat_now= now
                   end
                   if stat == 'D' then
                      est= now/est -- carga de ahora sobre velocidad de descarga = tiempo en segundos en descargarse
                   else
                      est= (full-now)/est
                   end
                   local h= math.floor(est/3600)
                   est= est % 3600
                   est= string.format(',%02d:%02d',h,math.floor(est/60))
                else
                   est=""
                end
             else
                fraxbat_st= stat
                fraxbat_ts= os.time()
                fraxbat_ch= now
                fraxbat_now= nil
                fraxbat_est= nil
             end
             charge=':<'..tag..'>'..tostring(math.ceil((100*now)/full))..'%</'..tag..'>'..est
          end
        end
     end
     tbw:set_markup(stat..charge)
  end
  -- Timers
  battery_timer = timer({ timeout = 5})
  battery_timer:connect_signal("timeout", function () hook_fraxbat(fraxbat,"BAT0") end)
  battery_timer:start()
-- }}}

-- {{{ Mem Usage
  -- Icon
    ramicon = wibox.widget.imagebox()--widget({type = "imagebox" })
    ramicon:set_image(beautiful.widget_mem)
    ramicon.resize = false
  -- Percentage
    mempct = wibox.widget.textbox()
  -- Meter
    membar = awful.widget.progressbar()
    membar:set_width(45)
    membar:set_background_color("#3F3F3F")
    membar:set_color("#FF6565" )
    memmargin = wibox.layout.margin(membar , 0, 0, 3, 4)

    local fd = io.popen("free | grep Mem | awk '{print $2}'")
    local total_memory = tonumber(fd:read("*all"))
    fd:close()
    function update_mem( widgetpct, widgetbar )
      local fd = io.popen("free | grep buffers/cache | awk '{print $3}'")
      local used_memory = tonumber(fd:read("*all"))
      fd:close()
      mem_percent = used_memory/total_memory
      widgetpct:set_markup(tostring(math.floor(mem_percent*100)) .. "% ")
      widgetbar:set_value(mem_percent)
      if mem_percent < 0.7 then
        widgetbar:set_color("#7BF256")
      else
        if mem_percent < 0.9 then
          widgetbar:set_color("#E19239")
        else
          widgetbar:set_color("#FF6565")
        end
      end
    end
    mem_timer = timer({ timeout = 10 })
    mem_timer:connect_signal("timeout", function () update_mem(mempct,membar) end)
    mem_timer:start()

    local menu = radical.context{}
    menu:add_item {text="Screen 1",button1=function(_menu,item,mods) print("Hello World! ") end}
    menu:add_item {text="Screen 9"}
    menu:add_item {text="Sub Menu",sub_menu = function()
        local smenu = radical.context{}
        smenu:add_item{text="item 1"}
        smenu:add_item{text="item 2"}
        return smenu
    end}

    membar:set_menu(menu,3) -- 3 = right mouse button, 1 = left mouse button

-- }}}

-- {{{ Volume Indicator
  -- icon
    volicon = wibox.widget.imagebox()
    volicon:set_image(awful.util.getdir("config") .. "/Icons/sound_64.png")
    --volicon.resize = false
    --awful.widget.layout.margins[volicon] = { top = 2 }
 -- scale
    volwidget = wibox.widget.textbox()

    function update_volume( widget,icon_widget )
      local fd = io.popen("amixer sget Master")
      local status = fd:read("*all")
      fd:close()
      local volume = tonumber(string.match(status, "(%d?%d?%d)%%"))
      widget:set_text(volume .. "%")
      if volume == 0 then
        icon_widget:set_image(awful.util.getdir("config") .. "/Icons/volume_down_64.png")
      else
        icon_widget:set_image(awful.util.getdir("config") .. "/Icons/sound_64.png")
      end
    end

    volicon:buttons(awful.util.table.join(
      awful.button({ }, 1, function ()
          awful.util.spawn("amixer set Master 1%+")
          update_volume(volwidget,volicon)
        end),
      awful.button({ }, 3, function () 
          awful.util.spawn("amixer set Master 1%-")
          update_volume(volwidget,volicon)
        end),
      awful.button({"Shift"}, 1, function ()
          awful.util.spawn("amixer set Master 10%+")
          update_volume(volwidget,volicon)
        end),
      awful.button({"Shift"}, 3, function () 
          awful.util.spawn("amixer set Master 10%-")
          update_volume(volwidget,volicon)
        end),
      awful.button({ }, 2, function () 
          local fd = io.popen("amixer sget Master")
          local status = fd:read("*all")
          fd:close()
          local volume = tonumber(string.match(status, "(%d?%d?%d)%%"))
          if volume ~= 0 then
            awful.util.spawn("amixer set Master 0%")
          else
            awful.util.spawn("amixer set Master 100%")
          end
          update_volume(volwidget,volicon)
        end)
    ))

    volwidget:buttons(awful.util.table.join(
      awful.button({ }, 1, function ()
          awful.util.spawn("amixer set Master 1%+")
          update_volume(volwidget,volicon)
        end),
      awful.button({ }, 3, function () 
          awful.util.spawn("amixer set Master 1%-")
          update_volume(volwidget,volicon)
        end),
      awful.button({"Shift"}, 1, function ()
          awful.util.spawn("amixer set Master 10%+")
          update_volume(volwidget,volicon)
        end),
      awful.button({"Shift"}, 3, function () 
          awful.util.spawn("amixer set Master 10%-")
          update_volume(volwidget,volicon)
        end),
      awful.button({ }, 2, function () 
          local fd = io.popen("amixer sget Master")
          local status = fd:read("*all")
          fd:close()
          local volume = tonumber(string.match(status, "(%d?%d?%d)%%"))
          if volume ~= 0 then
            awful.util.spawn("amixer set Master 0%")
          else
            awful.util.spawn("amixer set Master 100%")
          end
          update_volume(volwidget,volicon)
        end)
    ))
    update_volume(volwidget,volicon)
    volume_timer = timer({ timeout = 10 })
    volume_timer:connect_signal("timeout", function () update_volume(volwidget,volicon) end)
    volume_timer:start()
    --vicious.register(volwidget, vicious.widgets.volume, "$1", 1, "Master")
-- }}}

-- {{{ Wifi indicator
  -- {{ Wifi icon
    wifiicon = wibox.widget.imagebox()
    wifiicon:set_image(awful.util.getdir("config") .. "/Icons/wifi_64_0.png")
  -- }}
  -- {{ Ip
    ip = wibox.widget.textbox()
  -- }}
  -- {{ Signal power
    wifibar = awful.widget.progressbar()
    wifibar:set_width(7)
    wifibar:set_vertical(true)
    wifibar:set_background_color("#3F3F3F")
    wifibar:set_color("#FF6565" )
    wifimargin = wibox.layout.margin(wifibar , 0, 1, 1, 1)
  -- }}
  -- {{ Wifi ESSID
    wifissid = wibox.widget.textbox()
  -- }}
  -- {{ Update function
    function update_wifi( widgetbar,widgettext,widgeticon,widgetip )
      local fd = io.popen("wicd-cli -yd | head -n 1 | awk '{print $2}'")
      local cadena = fd:read("*all")
      fd:close()
      if cadena:find("wireless") or cadena:find("None") then

        -- Estoy desconectado
        -- widgetbar:set_color()
        widgettext:set_text("Not connected")
        widgeticon:set_image(awful.util.getdir("config") .. "/Icons/wifi_disconected_64.png")
        widgetbar:set_value(0)
      else
        --Estoy conectado
        local fd = io.popen("wicd-cli -y -p Quality")
        local quality = tonumber(fd:read("*all"))
        fd:close()
        local fd = io.popen("wicd-cli -y -p Essid")
        local ssid = fd:read("*all")
        fd:close()
        --widgetbar:set_color()
        widgetbar:set_value(quality/100)
        widgettext:set_text(ssid)
        if quality < 25 then
          widgeticon:set_image(awful.util.getdir("config") .. "/Icons/wifi_64_0.png")
        elseif quality < 50 then
          widgeticon:set_image(awful.util.getdir("config") .. "/Icons/wifi_64_33.png")
        elseif quality < 75 then
          widgeticon:set_image(awful.util.getdir("config") .. "/Icons/wifi_64_66.png")
        else
          widgeticon:set_image(awful.util.getdir("config") .. "/Icons/wifi_64_100.png")
        end
      end
      local fd = io.popen("wicd-cli -yd |  awk '/IP/ {print $2}'")
      local cadena = fd:read("*all")
      fd:close()
      widgetip:set_text(cadena)
    end
  -- }}}
  -- {{{ Binds
    wifiicon:buttons(awful.util.table.join(
      awful.button({ }, 1, function ()
        awful.util.spawn(terminal .. " -e ".."wicd-curses")
      end)
    ))
  -- }}}
  -- {{{ Timers 
    wifi_timer = timer({ timeout = 2 })
    wifi_timer:connect_signal("timeout", function() update_wifi(wifibar, wifissid, wifiicon, ip) end)
    wifi_timer:start()
  -- }}}
-- }}}

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts,  1, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1, 1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts,  1, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1, 1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    --right_layout:add(netwidget)
    right_layout:add(ip)
    right_layout:add(myseparator)
    right_layout:add(wifimargin)
    right_layout:add(wifiicon)
    right_layout:add(wifissid)
    right_layout:add(myseparator)
    right_layout:add(volicon)
    right_layout:add(volwidget)
    right_layout:add(myseparator)
    right_layout:add(clocktext)
    right_layout:add(myseparator)
    right_layout:add(ramicon)
    right_layout:add(mempct)
    right_layout:add(memmargin)
    right_layout:add(myseparator)
    right_layout:add(fraxbat)
    right_layout:add(myseparator)
    right_layout:add(mylayoutbox[s])



    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}