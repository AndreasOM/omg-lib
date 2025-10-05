class_name FrameAreaTiming

var name: String
var start_usec: int
var end_usec: int
var duration_usec: int

func _init(p_name: String, p_start_usec: int, p_end_usec: int) -> void:
	self.name = p_name
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
		PerformanceAreaStats.format_duration(duration_usec)
	]
