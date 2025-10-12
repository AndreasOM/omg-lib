class_name PerformanceMonitor_DeferredCallTiming

var target: Object  # WeakRef would be better but Object works
var method: StringName
var type: int  # 0=TYPE_CALL, 1=TYPE_NOTIFICATION, 2=TYPE_SET
var start_usec: int
var end_usec: int
var duration_usec: int

func _init(p_target: Object, p_method: StringName, p_type: int, p_start_usec: int, p_end_usec: int) -> void:
	self.target = p_target
	self.method = p_method
	self.type = p_type
	self.start_usec = p_start_usec
	self.end_usec = p_end_usec
	self.duration_usec = p_end_usec - p_start_usec

func get_type_string() -> String:
	match type:
		0: return "call"
		1: return "notif"
		2: return "set"
		_: return "unknown"

func get_class_name() -> String:
	return target.get_class() if target != null and is_instance_valid(target) else "Unknown"

func get_key() -> String:
	return "%s::%s [%s]" % [get_class_name(), method, get_type_string()]

func _to_string() -> String:
	return "%s (%.2fms)" % [get_key(), duration_usec / 1000.0]
