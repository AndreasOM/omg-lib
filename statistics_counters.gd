class_name StatisticsCounters

var name: String
var _counters: Dictionary = {}

func _init(p_name: String) -> void:
	self.name = p_name

func increment(key: String, amount: int = 1) -> void:
	if !_counters.has(key):
		_counters[key] = 0
	_counters[key] += amount

func clear() -> void:
	_counters.clear()

func to_dict() -> Dictionary:
	return _counters.duplicate()

func _to_string() -> String:
	var keys = _counters.keys()
	keys.sort()
	var parts: Array[String] = []
	for key in keys:
		parts.push_back("\t%s = %d" % [key, _counters[key]])
	return self.name + " {\n" + "\n".join(parts) + "\n}"
