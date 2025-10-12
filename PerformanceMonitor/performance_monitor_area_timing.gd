class_name PerformanceMonitor_AreaTiming

var name: String
var node: Node  # Reference to the node (may be null for manual PerformanceArea)
var start_usec: int
var end_usec: int
var duration_usec: int

# For tracking original paths after transformation
var original_path: String = ""  # Single original path (for individual nodes)
var original_paths: Array = []  # Multiple original paths (for accumulated groups)

func _init(p_name: String, p_start_usec: int, p_end_usec: int, p_node: Node = null) -> void:
	self.name = p_name
	self.node = p_node
	self.start_usec = p_start_usec
	self.end_usec = p_end_usec
	self.duration_usec = p_end_usec - p_start_usec

func get_start_offset(frame_start_usec: int) -> int:
	return start_usec - frame_start_usec

func get_end_offset(frame_start_usec: int) -> int:
	return end_usec - frame_start_usec

func _to_string() -> String:
	return "%s [%d-%d] (%s)" % [
		name,
		start_usec,
		end_usec,
		PerformanceMonitor_AreaStats.format_duration(duration_usec)
	]
