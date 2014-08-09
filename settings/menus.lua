local awful = require("awful")
local beautiful = require("beautiful")
local menubar = require("menubar")
require("localdata.menus")
-- Create a laucher widget and a main menu
-- Menus {{{
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

menueditors = {
    {"Vim", terminal .. " -e vim"},
    {"Chrome", "google-chrome-stable"},
    {"Chromium", "chromium"},
    {"Firefox", "firefox"},
}

mymainmenu = awful.menu({ items = {
    { "Archlinux" },
    { "Favorites"   , menueditors },
    { "Applications", xdgmenu },
    { "Awesome"    , myawesomemenu } ,
    { "Configurar" , menuconf },
    { "Sistema"    , menusys },
    { "Reiniciar"  , "systemctl reboot" },
    { "Apagar"     , "systemctl poweroff" }
}})
--  }}}
mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}
