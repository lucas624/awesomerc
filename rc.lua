-- Standard awesome library
local gears = require("gears")
awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")

 -- EXTENSIONS (functions etc)
 -- local mykb  = require("myrc.kb_layout") -- change keyboard layout
 -- local myro  = require("myrc.run_once")  -- run app as long it's not running already
 local myerr = require("myrc.error")     -- error reporting

 -- VARIABLES
terminal = "urxvt "
editor = "vim "
editor_cmd = terminal .. " -e " .. editor
configpath="/home/"..os.getenv("USER").."/.config/awesome/"

-- CUSTOM THEMES - pick name from themes/
local theme = "foo"
beautiful.init(configpath .. "/themes/" .. theme ..  "/theme.lua")

-- Default modkey (DEFAULT Mod4 = WinKey)
modkey = "Mod4"

-- TAGS (screens) && LAYOUTS
require("settings.tags")

-- {{{ Wallpaper
  if beautiful.wallpaper then
  	for s = 1, screen.count() do
      gears.wallpaper.maximized(beautiful.wallpaper, s, true)
	end
  end
-- }}}

-- MENUS (menubar, etc)
require("settings.menus")

-- Wibox stuff
require("settings.wiboxrc")

-- Key && mouse bindings
require("settings.binds")
root.keys(globalkeys) -- this actually sets the keys

-- WINDOW RULES
-- rules per app (placement, floating, etc)
require("settings.window_rules")

-- SIGNALs function to execute when a new client appears.
require("stock.signals")

-- STARTUP apps
require("settings.startup")
