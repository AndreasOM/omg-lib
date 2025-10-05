class_name FrameTiming

var frame_number: int
var start_usec: int
var end_usec: int
var total_duration_usec: int
var areas: Array[FrameAreaTiming] = []

func _init(p_frame_number: int, p_start_usec: int) -> void:
	self.frame_number = p_frame_number
	self.start_usec = p_start_usec
	self.end_usec = 0
	self.total_duration_usec = 0

func finalize(p_end_usec: int) -> void:
	self.end_usec = p_end_usec
	self.total_duration_usec = p_end_usec - self.start_usec

func add_area(area: FrameAreaTiming) -> void:
	self.areas.push_back(area)

func get_area_count() -> int:
	return self.areas.size()

func _to_string() -> String:
	return "Frame #%d: %s (%d areas)" % [
		frame_number,
		PerformanceAreaStats.format_duration(total_duration_usec),
		areas.size()
	]
