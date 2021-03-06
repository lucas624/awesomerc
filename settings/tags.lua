local awful = require("awful")
local tyrannical = require("tyrannical")

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts = {
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

 tyrannical.tags = {
    {
        name      = "www",
        init      = true,
        screen    = screen.count()>1 and 2 or 1, -- Setup on screen 2 if there is more than 1 screen, else on screen 1
        layout    = awful.layout.suit.floating,  -- Use the max layout
        exclusive = true,
        class     = {
            "Opera"    , "Firefox" , "Rekonq" , "Dillo"                , "Arora" ,
            "Chromium" , "nightly" , "Dwb"    , "Google-chrome-stable"
        }
    } ,
    {
        name      = "term",                            -- Call the tag "Term"
        init      = false,                             -- Load the tag on startup
        exclusive = true,                             -- Refuse any other type of clients (by classes)
        screen    = {1,2},                             -- Create this tag on screen 1 and screen 2
        layout    = awful.layout.suit.fair.horizontal, -- Use the tile layout
        class     = {                                  -- Accept the following classes, refuse everything else (because of "exclusive        = true")
            "xterm"   , "urxvt"      , "aterm"          , "URxvt"          , "XTerm" ,
            "konsole" , "terminator" , "gnome-terminal" , "Xfce4-terminal"
        }
    } ,
    {
        name      = "files",
        init      = false,
        exclusive = false,
        screen    = 1,
        layout    = awful.layout.suit.tile,
        exec_once = {}, --When the tag is accessed for the first time, execute this command
        class     = {
            "Thunar", "Konqueror", "Dolphin", "ark", "Nautilus","emelfm"
        }
    } ,
    {
        name      = "develop",
        init      = false,
        exclusive = true,
        screen    = 1,
        clone_on  = 2, -- Create a single instance of this tag on screen 1, but also show it on screen 2
        layout    = awful.layout.suit.max                          ,
        class     = {
            "Kate", "KDevelop", "Codeblocks", "Code::Blocks" , "DDD", "kate4", "Eclipse"}
    } ,
    {
        name      = "doc",
        init      = false,
        exclusive = true,
        layout    = awful.layout.suit.max,
        class     = {
            "Assistant"     , "Okular"         , "Evince"    , "EPDFviewer"   , "Xpdf" }
    }
}

-- Ignore the tag "exclusive" property for the following clients (matched by classes)
tyrannical.properties.intrusive = {
    "ksnapshot"     , "pinentry"        , "gtksu"     , "kcalc"         , "xcalc"                ,
    "feh"           , "Gradient editor" , "About KDE" , "Paste Special" , "Background color"     ,
    "kcolorchooser" , "plasmoidviewer"  , "Xephyr"    , "kruler"        , "plasmaengineexplorer" ,
    "Qalculate-gtk" , "Pavucontrol"
}

-- Ignore the tiled layout for the matching clients
tyrannical.properties.floating = {
    "pinentry"    , "ksnapshot"      , "pinentry"    , "gtksu"         , "Qalculate-gtk"  ,
    "xine"        , "feh"            , "kmix"        , "kcalc"         , "xcalc"          ,
    "yakuake"     , "Select Color$"  , "kruler"      , "kcolorchooser" , "Paste Special"  ,
    "New Form"    , "Insert Picture" , "kcharselect" , "mythfrontend"  , "plasmoidviewer" ,
    "Pavucontrol"
}

-- Make the matching clients (by classes) on top of the default layout
tyrannical.properties.ontop = {
    "Xephyr" , "ksnapshot" , "kruler" , "Qalculate-gtk" , "Pavucontrol"
}

-- Force the matching clients (by classes) to be centered on the screen on init
tyrannical.properties.centered = {
    "kcalc" , "Qalculate-gtk" , "Pavucontrol"
}

tyrannical.settings.block_children_focus_stealing = false -- Block popups ()
tyrannical.settings.group_children = true                 -- Force popups/dialogs to have the same tags as the parent client
