--          Pinku-light Awesome Config           --
--              Misaka !MiKoto.HE2               --
---------------------------------------------------

local gears           = require("gears")
local awful           = require("awful")
awful.rules           = require("awful.rules")
awful.autofocus       = require("awful.autofocus")
local wibox           = require("wibox")
local beautiful       = require("beautiful")
local naughty         = require("naughty")
local vicious         = require("vicious")
local scratch         = require("scratch")


-- Run once

function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
     findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

-- autostart applications
run_once("urxvtd")
run_once("unclutter -idle 10")
run_once("/home/lucy/.config/awesome/compton.sh")
run_once("/home/lucy/.config/awesome/trayer.sh")
run_once("xfce4-power-manager")
run_once("wicd-client")
awful.util.spawn_with_shell("sudo /etc/init.d/NetworkManager stop")

os.setlocale(os.getenv("LANG"))


-- Error Handling
-- Stolen from 'blackburn'

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
        local in_error = false
    end)
end


-- Global variables

home = os.getenv("HOME")
confdir = home .. "/.config/awesome"
scriptdir = confdir .. "/scripts/"
themes = confdir .. "/themes"
active_theme = themes .. "/pinku-lt"
language = string.gsub(os.getenv("LANG"), ".utf8", "")

beautiful.init(active_theme .. "/theme.lua")

terminal = "urxvtc"
editor = os.getenv("EDITOR")
editor_cmd = terminal .. " -e " .. editor
gui_editor = "sublime"
browser = "firefox"

modkey = "Mod4"
altkey = "Mod1"

layouts =
{
    awful.layout.suit.floating,             -- 1
    awful.layout.suit.tile,                 -- 2
    awful.layout.suit.tile.left,            -- 3
    awful.layout.suit.tile.bottom,          -- 4
    awful.layout.suit.tile.top,             -- 5
}


-- Wallpaper

if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end

-- Tags

tags = {
       names = { "media", "web", "chat", "other"},
       layout = { layouts[1], layouts[3], layouts[2], layouts[1], layouts[5] }
       }
for s = 1, screen.count() do
   tags[s] = awful.tag(tags.names, s, tags.layout)
end

-- Menu
programs = {
   { "Terminal", "urxvt" },
   { "Browser", "firefox" },
   { "editor", "/home/lucy/software/subLemon/subLemon_text" },
   { "irc", "quasselclient" },
}
places = {
   { "home", "urxvt -e zsh -c ranger /home/lucy" },
   { "root" , "urxvt -e zsh -c ranger /" },
   { "anime//local" , "urxvt -e zsh -c ranger /home/lucy/anime" },
   { "music//local" , "urxvt -e zsh -c ranger /home/lucy/music" },
   { "anime//alice",  "urxvt -e zsh -c ranger /mnt/animealice"  },
   { "music//alice",  "urxvt -e zsh -c ranger /mnt/musicalice"  },
}

mymainmenu = awful.menu({ items = {
            { "programs" , programs },
            { "places" , places },
  --          { "internet" , myinternet },
  --          { "office" , myoffice },
  --          { "system" , mysystem },
            }
            })
mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })


-- Panel

-- Colours
coldef  = "</span>"
white  = "<span color='#7c7c7c'>"
gray = "<span color='#FF8FB4'>"


-- Textclock widget
mytextclock = awful.widget.textclock(white .. "%A %d %B, %H:%M" .. coldef)

-- attached calendar 
-- also taken from Blackburn. Broken.
local os = os
local string = string
local table = table
local util = awful.util

char_width = nil
text_color = theme.fg_normal
today_color = theme.taglist_fg_focus or "#FF8FB4"
calendar_width = 21

local calendar = nil
local offset = 0

local data = nil

local function pop_spaces(s1, s2, maxsize)
   local sps = ""
   for i = 1, maxsize - string.len(s1) - string.len(s2) do
      sps = sps .. " "
   end
   return s1 .. sps .. s2
end

local function create_calendar()
   offset = offset or 0

   local now = os.qdate("*t")
   local cal_month = now.month + offset
   local cal_year = now.year
   if cal_month > 12 then
      cal_month = (cal_month % 12)
      cal_year = cal_year + 1
   elseif cal_month < 1 then
      cal_month = (cal_month + 12)
      cal_year = cal_year - 1
   end

   local last_day = os.date("%d", os.time({ day = 1, year = cal_year,
                                            month = cal_month + 1}) - 86400)

   local first_day = os.time({ day = 1, month = cal_month, year = cal_year})
   local first_day_in_week = os.date("%w", first_day)

   local result = "do lu ma me gi ve sa\n" -- days of the week

   -- Italian localization
   -- can be a stub for your own localization
   if language:find("it_IT") == nil
   then
       result = "su mo tu we th fr sa\n"
   else
       result = "do lu ma me gi ve sa\n"
   end

   for i = 1, first_day_in_week do
      result = result .. "   "
   end

   local this_month = false
   for day = 1, last_day do
      local last_in_week = (day + first_day_in_week) % 7 == 0
      local day_str = pop_spaces("", day, 2) .. (last_in_week and "" or " ")
      if cal_month == now.month and cal_year == now.year and day == now.day then
         this_month = true
         result = result ..
            string.format('<span weight="bold" foreground = "%s">%s</span>',
                          today_color, day_str)
      else
         result = result .. day_str
      end
      if last_in_week and day ~= last_day then
         result = result .. "\n"
      end
   end

   local header
   if this_month then
      header = os.date("%a, %d %b %Y")
   else
      header = os.date("%B %Y", first_day)
   end
   return header, string.format('<span font="%s" foreground="%s">%s</span>',
                                theme.font, text_color, result)
end

local function calculate_char_width()
   return beautiful.get_font_height(theme.font) * 0.555
end

function remove_calendar()
   if calendar ~= nil then
      naughty.destroy(calendar)
      calendar = nil
      offset = 0
   end
end

function add_calendar(inc_offset)
   inc_offset = inc_offset or 0

   local save_offset = offset
   remove_calendar()
   offset = save_offset + inc_offset

   local char_width = char_width or calculate_char_width()
   local header, cal_text = create_calendar()
   calendar = naughty.notify({ title = header,
                               text = cal_text,
                               timeout = 0, hover_timeout = 0.5,
                            })
end

function show_calendar(t_out)
   remove_calendar()
   local char_width = char_width or calculate_char_width()
   local header, cal_text = create_calendar()
   calendar = naughty.notify({ title = header,
                               text = cal_text,
                               timeout = t_out,
                            })
end

mytextclock:connect_signal("mouse::enter", function() add_calendar(0) end)
mytextclock:connect_signal("mouse::leave", remove_calendar)
mytextclock:buttons(util.table.join( awful.button({ }, 1, function() add_calendar(-1) end),
                                     awful.button({ }, 3, function() add_calendar(1) end)))


-- MPD widget
mpdwidget = wibox.widget.textbox()
mpdwidget:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn_with_shell(musicplr) end)))
curr_track = nil
vicious.register(mpdwidget, vicious.widgets.mpd,
function(widget, args)
  if (args["{state}"] == "Play") then
    if( args["{Title}"] ~= curr_track )
    then
        curr_track = args["{Title}"]
        run_once(scriptdir .. "mpdinfo")
    end
    return gray .. args["{Artist}"] .. coldef .. white .. " " .. args["{Title}"] .. coldef
  elseif (args["{state}"] == "Pause") then
    return white .. "[mpd " .. coldef .. white .. "is paused]" .. coldef
  else
    curr_track = nil
    return ''
  end
end, 1)




-- Net widget
nnetwidget = wibox.widget.textbox()
vicious.register(nnetwidget, vicious.widgets.net, '<span color="#FF8FB4">↓</span> <span>${wlan0 down_kb}</span><span color="#FF8FB4"> ↑</span> <span>${wlan0 up_kb} </span>', 3)
nnetwidget:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn_with_shell(iptraf) end)))

-- CPU widget
cpuwidget = wibox.widget.textbox()
vicious.register(cpuwidget, vicious.widgets.cpu, '<span color="#FF8FB4">⮦</span> $1% ', 3)

-- MEM widget
memwidget = wibox.widget.textbox()
vicious.register(memwidget, vicious.widgets.mem, '<span color="#FF8FB4">⮡</span> $2MB ', 13)

-- Battery widget
baticon = wibox.widget.imagebox()
baticon:set_image(beautiful.widget_battery)

function batstate()

  local file = io.open("/sys/class/power_supply/BAT0/status", "r")

  if (file == nil) then
    return "Cable plugged"
  end

  local batstate = file:read("*line")
  file:close()

  if (batstate == 'Discharging' or batstate == 'Charging') then
    return batstate
  else
    return "Fully charged"
  end
end

batwidget = wibox.widget.textbox()
vicious.register(batwidget, vicious.widgets.bat,
function (widget, args)
  -- plugged
  if (batstate() == 'Cable plugged') then
    baticon:set_image(beautiful.widget_ac)     
    return '<span font="Lemon 9">AC </span>'
    -- critical
  elseif (args[2] <= 5 and batstate() == 'Discharging') then
    baticon:set_image(beautiful.widget_battery_empty)
    naughty.notify({
      text = "Plug in, yo.",
      title = "Battery is critical!",
      position = "top_right",
      timeout = 1,
      fg="#000000",
      bg="#ffffff",
      screen = 1,
      ontop = true,
    })
    -- low
  elseif (args[2] <= 10 and batstate() == 'Discharging') then
    baticon:set_image(beautiful.widget_battery_low)
    naughty.notify({
      text = "Plug in soon!",
      title = "Low battery",
      position = "top_right",
      timeout = 1,
      fg="#ffffff",
      bg="#262729",
      screen = 1,
      ontop = true,
    })
   else baticon:set_image(beautiful.widget_battery)
  end
    return '<span>' .. args[2] .. '%</span>'
end, 1, 'BAT0')

-- Volume widget
volicon = wibox.widget.imagebox()
volicon:set_image(beautiful.widget_vol)
volumewidget = wibox.widget.textbox()
vicious.register(volumewidget, vicious.widgets.volume,  
function (widget, args)
  if (args[2] ~= "♩" ) then 
      if (args[1] == 0) then volicon:set_image(beautiful.widget_vol_no)
      elseif (args[1] <= 50) then  volicon:set_image(beautiful.widget_vol_low)
      else volicon:set_image(beautiful.widget_vol)
      end
  else volicon:set_image(beautiful.widget_vol_mute) 
  end
  return '<span color="#FF8FB4">⮞ </span><span>' .. args[1] .. '% <span color="#FF8FB4">⮏ </span></span>'
end, 1, "Master")

-- Net checker widget
no_net_shown = true
netwidget = wibox.widget.textbox()
vicious.register(netwidget, vicious.widgets.net,
function (widget, args)
    if args["{wlan0 carrier}"] == 0 then
       if no_net_shown == true then
         naughty.notify({ title = "wlan0", text = "No carrier",
         timeout = 7,
         position = "top_left",
         icon = beautiful.widget_no_net_notify,
         fg = "#ff5e5e",
         bg = beautiful.bg_normal })
         no_net_shown = false
       end
       return gray .. " Net " .. coldef .. "<span color='#e54c62'>Off " .. coldef
    else
       no_net_shown = true
       return ''
    end
end, 10)
netwidget:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn_with_shell(wifi) end)))


-- Separator and brackets
spr = wibox.widget.textbox(' ')
leftbr = wibox.widget.textbox(white .. ' [' .. coldef)
rightbr = wibox.widget.textbox(white .. '] ' .. coldef)


-- Layout

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
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = 12 })

-- Wibox layout 

    -- Widgets that are aligned to the upper left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(spr)
    left_layout:add(mylayoutbox[s])
    left_layout:add(spr)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the upper right
    local right_layout = wibox.layout.fixed.horizontal()
-- System Tray [Disabled]
--  if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(spr)
    right_layout:add(cpuwidget)
    right_layout:add(memwidget)
    right_layout:add(nnetwidget)
    right_layout:add(volumewidget)
    right_layout:add(batwidget)
    right_layout:add(spr)
--    right_layout:add(mpdwidget)
--    right_layout:add()
    right_layout:add(mytextclock)
    right_layout:add(spr)
-- Task List in middle of layouts
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)

end
-- Mouse Bindings

root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))


-- Key bindings
globalkeys = awful.util.table.join(

    -- Capture a screenshot
    awful.key({ altkey }, "p", function() awful.util.spawn("screenshot",false) end),

    -- Move clients
    awful.key({ altkey }, "Next",  function () awful.client.moveresize( 1,  1, -2, -2) end),
    awful.key({ altkey }, "Prior", function () awful.client.moveresize( 0,  0,  2,  2) end),
    awful.key({ altkey }, "Down",  function () awful.client.moveresize(  0,  1,   0,   0) end),
    awful.key({ altkey }, "Up",    function () awful.client.moveresize(  0, -1,   0,   0) end),
    awful.key({ altkey }, "Left",  function () awful.client.moveresize(-1,   0,   0,   0) end),
    awful.key({ altkey }, "Right", function () awful.client.moveresize( 1,   0,   0,   0) end),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Show/Hide Wibox
    awful.key({ modkey }, "b", function ()
        mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
    end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ altkey,           }, "Tab",
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
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)     end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)     end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)       end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)       end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)          end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)          end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1)  end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1)  end),
    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Dropdown terminal
    awful.key({ modkey,           }, "z",     function () scratch.drop(terminal) end),

    -- Widgets popups
    awful.key({ altkey,           }, "c",     function () show_calendar(7) end),
    awful.key({ altkey,           }, "h",     function () show_info(7) end),
--    awful.key({ altkey,           }, "w",     function () perceptive.show_weather(5) end),

    -- Volume control
    awful.key({ "Control" }, "Up", function ()
                                       awful.util.spawn("amixer set Master playback 1%+", false )
                                       vicious.force({ volumewidget })
                                   end),
    awful.key({ "Control" }, "Down", function ()
                                       awful.util.spawn("amixer set Master playback 1%-", false )
                                       vicious.force({ volumewidget })
                                     end),
    awful.key({ "Control" }, "m", function ()
                                       awful.util.spawn("amixer set Master playback mute", false )
                                       vicious.force({ volumewidget })
                                     end),
    awful.key({ "Control" }, "u", function ()
                                      awful.util.spawn("amixer set Master playback unmute", false )
                                      vicious.force({ volumewidget })
                                  end),
    awful.key({ altkey, "Control" }, "m",
                                  function ()
                                      awful.util.spawn("amixer set Master playback 100%", false )
                                      vicious.force({ volumewidget })
                                  end),

    -- Music control
    awful.key({ altkey, "Control" }, "Up", function ()
                                              awful.util.spawn( "mpc toggle", false )
                                              vicious.force({ mpdwidget } )
                                           end),
    awful.key({ altkey, "Control" }, "Down", function ()
                                                awful.util.spawn( "mpc stop", false )
                                                vicious.force({ mpdwidget } )
                                             end ),
    awful.key({ altkey, "Control" }, "Left", function ()
                                                awful.util.spawn( "mpc prev", false )
                                                vicious.force({ mpdwidget } )
                                             end ),
    awful.key({ altkey, "Control" }, "Right", function ()
                                                awful.util.spawn( "mpc next", false )
                                                vicious.force({ mpdwidget } )
                                              end ),

    -- Copy to clipboard
    awful.key({ modkey,        }, "c",      function () os.execute("xsel -p -o | xsel -i -b") end),

    -- User programs
    awful.key({ modkey,        }, "q",      function () awful.util.spawn( "dwb", false ) end),
    awful.key({ modkey,        }, "s",      function () awful.util.spawn(gui_editor) end),

    -- Prompt
    awful.key({ modkey }, "r", function () mypromptbox[mouse.screen]:run() end),
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
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
                        if tags then
                            awful.tag.viewonly(tags)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tags then
                            awful.tag.viewtoggle(tags)
                        end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.movetotag(tag)
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.movetotag(tag)
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)


-- Rules
-- dwb and gimp rules are set for a 1366x768 laptop

awful.rules.rules = {
     -- All clients will match this rule.
     { rule = { },
       properties = { border_width = beautiful.border_width,
                      border_color = beautiful.border_normal,
                      focus = awful.client.focus.filter,
                      keys = clientkeys,
                      buttons = clientbuttons,
                      size_hints_honor = false
                     }
    },

    { rule = { class = "URxvt" },
      properties = {opacity = 1.0} },

    { rule = { class = "MPlayer" },
      properties = { floating = true } },

    { rule = { class = "Dwb" },
          properties = { tag = tags[1][1],
                         x = 0, y = 20,
                         width = 1364, 
                         height = 748 } },

    { rule = { class = "Gvim" },
          properties = { tag = tags[1][2] } },

    { rule = { class = "Zathura" },
        properties = { tag = tags[1][3] } },

    { rule = { class = "Dia" },
          properties = { tag = tags[1][4],
                         floating = true } },

    { rule = { class = "Gimp" },
          properties = { tag = tags[1][4],
                         floating = false } },

    { rule = { class = "Gimp", role = "gimp-image-window" },
          properties = { x = 138, width = 1024,
                         maximized_vertical = true } },

    { rule = { class = "Gimp", role = "gimp-toolbox" },
          properties = { x = 0, maximized_vertical = true } },

    { rule = { class = "Gimp", role = "gimp-dock" },
          properties = { x = 1165, maximized_vertical = true } },

    { rule = { class = "Gimp", role = "gimp-image-new" },
          properties = { x = 480, y = 240} },

    { rule = { class = "Gimp", role = "gimp-toolbox-color-dialog" },
          properties = { x = 138, y = 350} },

    { rule = { class = "Gimp", role = "gimp-file-export" },
          properties = { maximized_vertical = true,
                         maximized_horizontal = true,
                         width = 1366 } },

    { rule = { class = "Transmission-gtk" },
          properties = { tag = tags[1][5] } },

    { rule = { class = "Torrent-search" },
          properties = { tag = tags[1][5] } },
}


-- Signals

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

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
