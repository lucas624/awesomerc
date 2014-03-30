  local awful = require("awful")
  local beautiful = require("beautiful")
  local menubar = require("menubar")

-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

menueditors = {
    {"Sublime", "subl"},
    {"Vim", terminal .. " -e vim"},
    {"Vi", terminal .. " -e vi"},
    {"Nano", terminal .. " -e nano"},
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