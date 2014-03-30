local awful = require("awful")

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