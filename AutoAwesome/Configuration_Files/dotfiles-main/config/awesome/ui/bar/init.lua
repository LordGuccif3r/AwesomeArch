-- Standard awesome library
local awful = require("awful")
local gears = require("gears")

-- Widget library
local wibox = require("wibox")

-- Theme handling library
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

-- Rubato
local rubato = require("module.rubato")

-- Helpers
local helpers = require("helpers")

-- Get screen geometry
local screen_width = awful.screen.focused().geometry.width
local screen_height = awful.screen.focused().geometry.height


-- Helpers
-------------

local wrap_widget = function(widget)
    return {
        widget,
        margins = dpi(6),
        widget = wibox.container.margin
    }
end


-- Launcher
-------------

local awesome_icon = wibox.widget {
    {
        widget = wibox.widget.imagebox,
        image = beautiful.awesome_logo,
        resize = true
    },
    margins = dpi(4),
    widget = wibox.container.margin
}

helpers.add_hover_cursor(awesome_icon, "hand2")


-- Battery
-------------

local charge_icon = wibox.widget{
    bg = beautiful.xcolor8,
    widget = wibox.container.background,
    visible = false
}

local batt = wibox.widget{
    charge_icon,
    color = {beautiful.xcolor2},
    bg = beautiful.xcolor8 .. "88",
    value = 50,
    min_value = 0,
    max_value = 100,
    thickness = dpi(4),
    padding = dpi(2),
    -- rounded_edge = true,
    start_angle = math.pi * 3 / 2,
    widget = wibox.container.arcchart
}

awesome.connect_signal("signal::battery", function(value) 
    local fill_color = beautiful.xcolor2

    if value >= 11 and value <= 30 then
        fill_color = beautiful.xcolor3
    elseif value <= 10 then
        fill_color = beautiful.xcolor1
    end

    batt.colors = {fill_color}
    batt.value = value
end)

awesome.connect_signal("signal::charger", function(state)
    if state then
        charge_icon.visible = true
    else
        charge_icon.visible = false
    end
end)


-- Time
----------

local hour = wibox.widget{
    font = beautiful.font_name .. "bold 14",
    format = "%H",
    align = "center",
    valign = "center",
    widget = wibox.widget.textclock
}

local min = wibox.widget{
    font = beautiful.font_name .. "bold 14",
    format = "%M",
    align = "center",
    valign = "center",
    widget = wibox.widget.textclock
}

local clock = wibox.widget{
    {
        {
            hour,
            min,
            spacing = dpi(5),
            layout = wibox.layout.fixed.vertical
        },
        top = dpi(5),
        bottom = dpi(5),
        widget = wibox.container.margin
    },
    bg = beautiful.lighter_bg,
    shape = helpers.rrect(beautiful.bar_radius),
    widget = wibox.container.background
}


-- Stats
-----------

local stats = wibox.widget{
    {
        wrap_widget(batt),
        clock,
        spacing = dpi(5),
        layout = wibox.layout.fixed.vertical
    },
    bg = beautiful.xcolor0,
    shape = helpers.rrect(beautiful.bar_radius),
    widget = wibox.container.background
}

stats:connect_signal("mouse::enter", function()
    stats.bg = beautiful.xcolor8
    stats_tooltip_show()
end)

stats:connect_signal("mouse::leave", function()
    stats.bg = beautiful.xcolor0
    stats_tooltip_hide()
end)


-- Notification center
-------------------------

local notifs = wibox.widget{
    markup = helpers.colorize_text("", beautiful.xcolor3),
    font = beautiful.font_name .. "18",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}

notifs:connect_signal("mouse::enter", function()
    notifs.markup = helpers.colorize_text(notifs.text, beautiful.xcolor3 .. 55)
end)

notifs:connect_signal("mouse::leave", function()
    notifs.markup = helpers.colorize_text(notifs.text, beautiful.xcolor3)
end)

notifs:buttons(gears.table.join(
    awful.button({}, 1, function()
        notifs_toggle()
    end)
))
    helpers.add_hover_cursor(notifs, "hand2")


-- Setup wibar
-----------------

screen.connect_signal("request::desktop_decoration", function(s)

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Layoutbox
    local layoutbox_buttons = gears.table.join(
    -- Left click
    awful.button({}, 1, function (c)
        awful.layout.inc(1)
    end),

    -- Right click
    awful.button({}, 3, function (c) 
        awful.layout.inc(-1) 
    end),

    -- Scrolling
    awful.button({}, 4, function ()
        awful.layout.inc(-1)
    end),
    awful.button({}, 5, function ()
        awful.layout.inc(1)
    end)
    )

    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(layoutbox_buttons)

    local layoutbox = wibox.widget{
        s.mylayoutbox,
        margins = {bottom = dpi(7), left = dpi(8), right = dpi(8)},
        widget = wibox.container.margin
    }

    helpers.add_hover_cursor(layoutbox, "hand2")


    -- Create the wibar
    s.mywibar = awful.wibar({
        type = "dock",
        position = "left",
        screen = s,
        height = awful.screen.focused().geometry.height - dpi(50),
        width = dpi(50),
        shape = helpers.rrect(beautiful.border_radius),
        bg = beautiful.transparent,
        ontop = true,
        visible = true
    })

    awesome_icon:buttons(gears.table.join(
    awful.button({}, 1, function ()
        dashboard_toggle()
    end)
    ))

    -- Remove wibar on full screen
    local function remove_wibar(c)
        if c.fullscreen or c.maximized then
            c.screen.mywibar.visible = false
        else
            c.screen.mywibar.visible = true
        end
    end

    -- Remove wibar on full screen
    local function add_wibar(c)
        if c.fullscreen or c.maximized then
            c.screen.mywibar.visible = true
        end
    end

    client.connect_signal("property::fullscreen", remove_wibar)

    client.connect_signal("request::unmanage", add_wibar)

     -- Create the taglist widget
    s.mytaglist = require("ui.widgets.pacman_taglist")(s)

    local taglist = wibox.widget{
        s.mytaglist,
        shape = beautiful.taglist_shape_focus,
        bg = beautiful.xcolor0,
        widget = wibox.container.background
    }

    -- Add widgets to wibar
    s.mywibar:setup {
        {
            {
                layout = wibox.layout.align.vertical,
                expand = "none",
                { -- left
                    awesome_icon,
                    taglist,
                    spacing = dpi(10),
                    layout = wibox.layout.fixed.vertical
                },
                -- middle
                nil,
                { -- right
                    stats,
                    notifs,
                    layoutbox,
                    spacing = dpi(8),
                    layout = wibox.layout.fixed.vertical
                }
            },
            margins = dpi(8),
            widget = wibox.container.margin
        },
        bg = beautiful.darker_bg,
        shape = helpers.rrect(beautiful.border_radius),
        widget = wibox.container.background
    }

    -- wibar position
    s.mywibar.x = dpi(25)
end)
