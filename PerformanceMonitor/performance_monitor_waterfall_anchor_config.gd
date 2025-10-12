class_name PerformanceMonitor_WaterfallAnchorConfig

var prefix: String
var max_depth: int
var min_duration_usec: int

func _init(p_prefix: String, p_max_depth: int = 0, p_min_duration_usec: int = 0) -> void:
	self.prefix = p_prefix
	self.max_depth = p_max_depth
	self.min_duration_usec = p_min_duration_usec

func _to_string() -> String:
	return "PerformanceMonitor_WaterfallAnchorConfig(prefix='%s', max_depth=%d, min_duration=%dµs)" % [
		prefix,
		max_depth,
		min_duration_usec
	]
