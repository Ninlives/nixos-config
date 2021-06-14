conky.config = {
	update_interval = 1,
	total_run_times = 0,
	net_avg_samples = 1,
	cpu_avg_samples = 1,
	imlib_cache_size = 0,
	double_buffer = true,
	-- no_buffers = true,
	use_xft = true,
	font = 'Zekton:size=9',
	override_utf8_locale = true,
	text_buffer_size = 2048,
	own_window_class = 'Conky',
	own_window = true,
	own_window_type = 'normal',
	own_window_transparent = true,
	own_window_hints = 'undecorated,sticky,skip_taskbar,skip_pager',
	own_window_argb_value = 0,
	own_window_argb_visual = true,
	own_window_colour = '#000000',
	alignment = 'top_right',
	gap_x = 150,
	gap_y = 1000,
	minimum_width = 604, minimum_height = 966,
	default_bar_width = 30, default_bar_height = 8,
	draw_shades = false,
	default_color = '#ffffff',
	default_shade_color = '#000000',
	color0 = '#00d9ff',
	color1 = '#ffffff',
	color2 = '#ffffff',

    lua_load = '@script@',
	lua_draw_hook_post = 'main',
};

conky.text = [[
${goto 400}${voffset 65}${color0}${font Zekton:style=bold:size=12}${downspeedf wlo1}
${goto 110}${voffset 55}${color}${font}Temperature:
${goto 0}${voffset 210}${font Zekton:style=bold:size=25}${time %b.%d}${font}
${goto 330}${voffset -25}${font Zekton:style=Bold:size=12}Battery
${alignc -80}${font Zekton:style=Bold:size=9}${battery_percent BAT0}%
${goto 65}${font Zekton:size=12}${voffset 97}CPU${color}${goto 250}${voffset -12}RAM
${goto 263}${font Zekton:style=Bold:size=9}${memperc}%
${goto 125}${voffset 55}${font Zekton:style=Bold:size=10}NixStore
${goto 140}${font Zekton:style=Bold:size=9}${fs_used /nix/store}

${image @image@ -p -10,80 -s 594x966}
]];
