  -- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
-- aquí pondre mis agregados
awful.util.spawn_with_shell("xcompmgr &")
vicious = require("vicious")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/usr/share/awesome/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "xfce4-terminal"
editor = "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

--[[ {{{ Tags
 -- Define a tag table which will hold all screen tags.
 tags = {
   names  = { "www", 2, 3, 4, 5, 6, 7, 8, 9 },
   layout = { layouts[1], layouts[2], layouts[1], layouts[5], layouts[6],
              layouts[12], layouts[9], layouts[3], layouts[7]
 }}
 for s = 1, screen.count() do
     -- Each screen has its own tag table.
     tags[s] = awful.tag(tags.names, s, tags.layout)
 end
 -- }}}]]

-- {{{ Tags
tyrannical.tags = {
    {
        name        = "Term",                 -- Call the tag "Term"
        init        = true,                   -- Load the tag on startup
        exclusive   = true,                   -- Refuse any other type of clients (by classes)
        screen      = {1,2},                  -- Create this tag on screen 1 and screen 2
        layout      = awful.layout.suit.tile, -- Use the tile layout
        class       = { --Accept the following classes, refuse everything else (because of "exclusive=true")
            "xterm" , "urxvt" , "aterm","URxvt","XTerm","konsole","terminator","gnome-terminal"
        }
    } ,
    {
        name        = "Internet",
        init        = true,
        exclusive   = true,
      --icon        = "~net.png",                 -- Use this icon for the tag (uncomment with a real path)
        screen      = screen.count()>1 and 2 or 1,-- Setup on screen 2 if there is more than 1 screen, else on screen 1
        layout      = awful.layout.suit.max,      -- Use the max layout
        class = {
            "Opera"         , "Firefox"        , "Rekonq"    , "Dillo"        , "Arora",
            "Chromium"      , "nightly"        , "minefield"     }
    } ,
    {
        name = "Files",
        init        = true,
        exclusive   = true,
        screen      = 1,
        layout      = awful.layout.suit.tile,
        exec_once   = {"dolphin"}, --When the tag is accessed for the first time, execute this command
        class  = {
            "Thunar", "Konqueror", "Dolphin", "ark", "Nautilus","emelfm"
        }
    } ,
    {
        name = "Develop",
        init        = true,
        exclusive   = true,
        screen      = 1,
        clone_on    = 2, -- Create a single instance of this tag on screen 1, but also show it on screen 2
                         -- The tag can be used on both screen, but only one at once
        layout      = awful.layout.suit.max                          ,
        class ={ 
            "Kate", "KDevelop", "Codeblocks", "Code::Blocks" , "DDD", "kate4"}
    } ,
    {
        name        = "Doc",
        init        = false, -- This tag wont be created at startup, but will be when one of the
                             -- client in the "class" section will start. It will be created on
                             -- the client startup screen
        exclusive   = true,
        layout      = awful.layout.suit.max,
        class       = {
            "Assistant"     , "Okular"         , "Evince"    , "EPDFviewer"   , "xpdf",
            "Xpdf"          ,                                        }
    } ,
}

-- Ignore the tag "exclusive" property for the following clients (matched by classes)
tyrannical.properties.intrusive = {
    "ksnapshot"     , "pinentry"       , "gtksu"     , "kcalc"        , "xcalc"               ,
    "feh"           , "Gradient editor", "About KDE" , "Paste Special", "Background color"    ,
    "kcolorchooser" , "plasmoidviewer" , "Xephyr"    , "kruler"       , "plasmaengineexplorer",
}

-- Ignore the tiled layout for the matching clients
tyrannical.properties.floating = {
    "MPlayer"      , "pinentry"        , "ksnapshot"  , "pinentry"     , "gtksu"          ,
    "xine"         , "feh"             , "kmix"       , "kcalc"        , "xcalc"          ,
    "yakuake"      , "Select Color$"   , "kruler"     , "kcolorchooser", "Paste Special"  ,
    "New Form"     , "Insert Picture"  , "kcharselect", "mythfrontend" , "plasmoidviewer" 
}

-- Make the matching clients (by classes) on top of the default layout
tyrannical.properties.ontop = {
    "Xephyr"       , "ksnapshot"       , "kruler"
}

-- Force the matching clients (by classes) to be centered on the screen on init
tyrannical.properties.centered = {
    "kcalc"
}

tyrannical.settings.block_children_focus_stealing = true --Block popups ()
tyrannical.settings.group_children = true --Force popups/dialogs to have the same tags as the parent client
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

menueditors = {
    {"Sublime", "subl"},
    {"Vim", terminal .. "-e vim"},
    {"Vi", terminal .. "-e vi"},
    {"Nano", terminal .. "-e nano"},
}

menuweb = {
  {"Chrome", "google-chrome-stable"},
  {"Chromium", "chromium"},
  {"Firefox", "firefox"},
}

mymainmenu = awful.menu({ items = { { "Archlinux" },
                                    { "Editores", menueditors },
                                    { "Internet", menuweb },
                                    { "Oficina", menuoffice },
                                    { "Desarrollo", menudevelop },
                                    { "Awesome", myawesomemenu },
                                    { "Configurar", menuconf },
                                    { "Sistema", menusys },
                                    { "Terminal", terminal },
                                    { "Anki", "anki" },
                                    { "Chrome", "google-chrome-stable" },
                                    { "Spacefm", "spacefm" },
                                    { "Reiniciar", "systemctl reboot" },
                                    { "Apagar", "systemctl poweroff" }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock()

-- {{{ Simple Separator
myseparator = wibox.widget.textbox()
myseparator:set_text(" | ")
-- }}}


--{{{ Create fraxbat widget
  fraxbat = wibox.widget.textbox() --widget({ type = "textbox", name = "fraxbat", align = "right" })
  fraxbat:set_markup("fraxbat");

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
  battery_timer = timer({ timeout = 60})
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
  function update_wifi( widgetbar,widgettext,widgeticon )
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
  end
  wifi_timer = timer({ timeout = 2 })
  wifi_timer:connect_signal("timeout", function() update_wifi(wifibar, wifissid, wifiicon) end)
  wifi_timer:start()
-- }}}
--[[ {{{
    mytimer = timer({ timeout = 1 })
    mytimer:connect_signal("timeout", function() mytextbox.text = "Hello awesome world!" end)
    mytimer:start()]]

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
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
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
    right_layout:add(mytextclock)
    right_layout:add(myseparator)
    right_layout:add(wifimargin)
    right_layout:add(wifiicon)
    right_layout:add(wifissid)
    right_layout:add(myseparator)
    right_layout:add(volicon)
    right_layout:add(volwidget)
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

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end),
    awful.key({ modkey, "Shift" }, "Right",
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[awful.tag.getidx(client.focus.tag) + 1]
                          if tag then
                              awful.client.movetotag(tag)
                              awful.tag.viewnext()
                          end
                     end
                  end),
    awful.key({ modkey, "Shift" }, "Left",
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[awful.tag.getidx(client.focus.tag) - 1]
                          if tag then
                              awful.client.movetotag(tag)
                              awful.tag.viewprev()
                          end
                      end
                  end)
)



clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
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

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

do
  local cmds = 
  { 
    terminal .. "wicd-curses",
    "easystroke"
    --and so on...
  }

  for _,i in pairs(cmds) do
    awful.util.spawn(i)
  end
end

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
