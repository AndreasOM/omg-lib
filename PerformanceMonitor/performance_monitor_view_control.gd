class_name PerformanceMonitor_ViewControl
extends Control

## Custom control for visualizing PerformanceMonitor waterfall data.
## Phase 2: Direct line drawing for performance

# Current frame snapshot to visualize
var _frame_snapshot: PerformanceMonitor_FrameSnapshot = null

# Visual constants
const LINE_HEIGHT: float = 20.0
const LINE_THICKNESS: float = 4.0
const PADDING_TOP: float = 10.0

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

	# Draw each area as a horizontal bar
	var y_pos = PADDING_TOP
	for area in areas:
		var start_offset_usec = area.start_usec - timeline_start_usec
		var end_offset_usec = area.end_usec - timeline_start_usec

		# Calculate X positions (spans full width based on actual timeline)
		var x_start = (float(start_offset_usec) / float(timeline_duration_usec)) * width
		var x_end = (float(end_offset_usec) / float(timeline_duration_usec)) * width

		# Get color based on duration
		var color = _get_duration_color(area.duration_usec, max_duration_usec)

		# Draw line
		draw_line(Vector2(x_start, y_pos), Vector2(x_end, y_pos), color, LINE_THICKNESS)

		y_pos += LINE_HEIGHT

func _get_waterfall_areas(frame: PerformanceMonitor_FrameSnapshot) -> Array:
	"""Get filtered and sorted areas for waterfall display (mimics get_worst_frame_waterfall logic)."""
	# For Phase 2, just return raw areas sorted by start time
	# Phase 3 will add proper filtering and aggregation
	var areas = frame.areas.duplicate()
	areas.sort_custom(func(a, b): return a.start_usec < b.start_usec)

	# Limit to prevent overflow
	const MAX_AREAS = 20
	if areas.size() > MAX_AREAS:
		areas = areas.slice(0, MAX_AREAS)

	return areas

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
