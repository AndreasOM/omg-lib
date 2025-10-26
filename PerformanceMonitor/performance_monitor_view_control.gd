class_name PerformanceMonitor_ViewControl
extends Control

## Custom control for visualizing PerformanceMonitor waterfall data.
## Phase 3: Direct line drawing + cached labels for performance

# Current frame snapshot to visualize
var _frame_snapshot: PerformanceMonitor_FrameSnapshot = null

# Label cache: text -> Label
var _label_cache: Dictionary = {}

# Visual settings (configurable)
@export var label_font_size: int = 20
@export var line_thickness: float = 4.0
@export var vertical_spacing: float = 4.0  # Extra space between label and line
@export var padding_top: float = 10.0

func update_display() -> void:
	"""Update the waterfall visualization. Phase 2: Direct drawing."""
	_frame_snapshot = PerformanceMonitor.get_worst_frame()
	queue_redraw()

func _draw() -> void:
	if _frame_snapshot == null:
		draw_string(ThemeDB.fallback_font, Vector2(10, 30), "No frames recorded yet")
		return

	var frame = _frame_snapshot
	var width = size.x

	# Get all areas from waterfall (already filtered and sorted)
	var areas = _get_waterfall_areas(frame)

	if areas.is_empty():
		draw_string(ThemeDB.fallback_font, Vector2(10, 30), "No areas to display")
		return

	# Calculate timeline range from actual area times
	var timeline_start_usec = areas[0].start_usec
	var timeline_end_usec = areas[0].end_usec

	for area in areas:
		if area.start_usec < timeline_start_usec:
			timeline_start_usec = area.start_usec
		if area.end_usec > timeline_end_usec:
			timeline_end_usec = area.end_usec

	var timeline_duration_usec = timeline_end_usec - timeline_start_usec
	if timeline_duration_usec <= 0:
		return

	# Find max duration for color scaling
	var max_duration_usec = 0
	for area in areas:
		if area.duration_usec > max_duration_usec:
			max_duration_usec = area.duration_usec

	# Track which labels are used this frame
	var used_labels: Array[String] = []

	# Calculate line height based on font size + spacing
	var line_height = label_font_size + vertical_spacing + line_thickness

	# Draw each area as a horizontal bar + label
	var y_pos = padding_top
	for area in areas:
		var start_offset_usec = area.start_usec - timeline_start_usec
		var end_offset_usec = area.end_usec - timeline_start_usec

		# Calculate X positions (spans full width based on actual timeline)
		var x_start = (float(start_offset_usec) / float(timeline_duration_usec)) * width
		var x_end = (float(end_offset_usec) / float(timeline_duration_usec)) * width

		# Get or create label for this area (positioned above line, aligned with line start)
		var label_text = area.name
		var label = _get_or_create_label(label_text)
		label.position = Vector2(x_start, y_pos)
		label.visible = true
		used_labels.append(label_text)

		# Draw line below label
		var line_y = y_pos + label_font_size + vertical_spacing
		var color = _get_duration_color(area.duration_usec, max_duration_usec)
		draw_line(Vector2(x_start, line_y), Vector2(x_end, line_y), color, line_thickness)

		y_pos += line_height

	# Hide unused labels (but keep in cache)
	for text in _label_cache.keys():
		if text not in used_labels:
			_label_cache[text].visible = false

	# Draw frame rate reference lines
	_draw_framerate_references(timeline_duration_usec, width)

func _draw_framerate_references(timeline_duration_usec: int, width: float) -> void:
	"""Draw vertical reference lines for frame rate targets."""
	const FPS_120_USEC = 8333  # 1000000 / 120 ≈ 8.3ms
	const FPS_60_USEC = 16666  # 1000000 / 60 ≈ 16.6ms
	const FPS_30_USEC = 33333  # 1000000 / 30 ≈ 33.3ms

	# Only draw lines if they're within the timeline
	if timeline_duration_usec <= 0:
		return

	# 120fps line (white) - only if we have a fast frame
	if timeline_duration_usec < FPS_60_USEC:
		var x_pos = (float(FPS_120_USEC) / float(timeline_duration_usec)) * width
		if x_pos <= width:
			draw_line(Vector2(x_pos, 0), Vector2(x_pos, size.y), Color.WHITE, 1.0)

	# 60fps line (green) - only if relevant
	if timeline_duration_usec >= FPS_120_USEC:
		var x_pos = (float(FPS_60_USEC) / float(timeline_duration_usec)) * width
		if x_pos <= width:
			draw_line(Vector2(x_pos, 0), Vector2(x_pos, size.y), Color.GREEN, 2.0)

	# 30fps line (yellow) - only if relevant
	if timeline_duration_usec >= FPS_60_USEC:
		var x_pos = (float(FPS_30_USEC) / float(timeline_duration_usec)) * width
		if x_pos <= width:
			draw_line(Vector2(x_pos, 0), Vector2(x_pos, size.y), Color.YELLOW, 2.0)

func _get_waterfall_areas(frame: PerformanceMonitor_FrameSnapshot) -> Array:
	"""Get filtered and sorted areas for waterfall display (uses anchor-relative paths)."""
	# Use PerformanceMonitor's waterfall logic (anchor-relative, filtered, sorted)
	return PerformanceMonitor.get_worst_frame_waterfall_areas()

func _get_duration_color(duration_usec: int, max_duration_usec: int) -> Color:
	"""Calculate color based on duration: green (fast) -> yellow (mid) -> red (slow)."""
	if max_duration_usec <= 0:
		return Color.GREEN

	# Normalize duration to 0.0-1.0
	var t = float(duration_usec) / float(max_duration_usec)
	t = clamp(t, 0.0, 1.0)

	# Green -> Yellow -> Red gradient
	if t < 0.5:
		# Green to Yellow (0.0 - 0.5)
		var local_t = t * 2.0
		return Color.GREEN.lerp(Color.YELLOW, local_t)
	else:
		# Yellow to Red (0.5 - 1.0)
		var local_t = (t - 0.5) * 2.0
		return Color.YELLOW.lerp(Color.RED, local_t)

func _get_or_create_label(text: String) -> Label:
	"""Get cached label or create new one. Cache key = text itself."""
	if _label_cache.has(text):
		return _label_cache[text]

	# Create new label (first time seeing this text)
	var label = Label.new()
	label.text = text

	# Font styling (use configurable font size)
	var font = load("res://Fonts/Hack-Regular.ttf")
	if font:
		label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", label_font_size)

	# Color styling
	label.add_theme_color_override("font_color", Color(0, 0.631373, 0, 1))
	label.add_theme_color_override("font_outline_color", Color(0.208557, 0.119206, 0.222108, 1))
	label.add_theme_constant_override("outline_size", 4)

	add_child(label)
	_label_cache[text] = label

	return label

func clear_cache() -> void:
	"""Explicitly clear label cache (for development/debugging)."""
	for label in _label_cache.values():
		label.queue_free()
	_label_cache.clear()
