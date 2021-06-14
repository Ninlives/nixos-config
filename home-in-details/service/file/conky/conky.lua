conky.config = {
	update_interval = 1,
	total_run_times = 0,
	net_avg_samples = 1,
	cpu_avg_samples = 1,
	imlib_cache_size = 0,
	double_buffer = true,
	-- no_buffers = true,
	use_xft = true,
	font = 'Zekton:size=6',
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
	gap_x = 260,
	gap_y = 600,
	-- minimum_width = 604, minimum_height = 966,
	-- default_bar_width = 30, default_bar_height = 8,
	draw_shades = false,
	default_color = '#928374',
	default_shade_color = '#000000',
};

conky.text = [[
${alignc}----  CPU  ----
$alignc${cpubar cpu1  6, 170}
$alignc${cpubar cpu2  6, 231}
$alignc${cpubar cpu3  6, 271}
$alignc${cpubar cpu4  6, 298}
$alignc${cpubar cpu5  6, 316}
$alignc${cpubar cpu6  6, 326}
$alignc${cpubar cpu7  6, 330}
$alignc${cpubar cpu8  6, 326}
$alignc${cpubar cpu9  6, 316}
$alignc${cpubar cpu10 6, 298}
$alignc${cpubar cpu11 6, 271}
$alignc${cpubar cpu12 6, 231}
$alignc${membar 6, 170}
${alignc} ----  RAM  ----
]];
