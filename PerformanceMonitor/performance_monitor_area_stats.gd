class_name PerformanceMonitor_AreaStats

var name: String

# Circular buffer for percentile calculation
var _samples: Array[int] = []
var _sample_index: int = 0
var _sample_count: int = 0
const MAX_SAMPLES = 1000

# Cached sorted array for percentile queries
var _cached_sorted: Array[int] = []
var _cache_valid: bool = false

# Session statistics (always current)
var min_usec: int = 0
var max_usec: int = 0
var total_usec: int = 0
var count: int = 0

# Track sample timing for samples-per-second calculation
var _first_sample_time_usec: int = 0
var _last_sample_time_usec: int = 0

func _init(p_name: String) -> void:
	self.name = p_name
	_samples.resize(MAX_SAMPLES)

func add_sample(duration_usec: int, sample_time_usec: int = 0) -> void:
	# Update session stats (O(1))
	if count == 0:
		min_usec = duration_usec
		max_usec = duration_usec
		if sample_time_usec > 0:
			_first_sample_time_usec = sample_time_usec
	else:
		min_usec = min(min_usec, duration_usec)
		max_usec = max(max_usec, duration_usec)

	total_usec += duration_usec
	count += 1

	# Track last sample time
	if sample_time_usec > 0:
		_last_sample_time_usec = sample_time_usec

	# Add to circular buffer (O(1))
	_samples[_sample_index] = duration_usec
	_sample_index = (_sample_index + 1) % MAX_SAMPLES
	_sample_count = min(_sample_count + 1, MAX_SAMPLES)

	# Invalidate percentile cache
	_cache_valid = false

func get_avg_usec() -> float:
	if count == 0:
		return 0.0
	return float(total_usec) / float(count)

func get_percentile(p: float) -> int:
	# p in [0.0, 1.0], e.g. 0.99 for p99
	if _sample_count == 0:
		return 0

	_ensure_sorted()
	var index = int(p * float(_sample_count - 1))
	return _cached_sorted[index]

func get_p50() -> int:
	return get_percentile(0.50)

func get_p90() -> int:
	return get_percentile(0.90)

func get_p95() -> int:
	return get_percentile(0.95)

func get_p99() -> int:
	return get_percentile(0.99)

func get_samples_per_second() -> float:
	if count == 0:
		return 0.0
	if count == 1:
		return 0.0
	if _first_sample_time_usec == 0:
		return 0.0
	if _last_sample_time_usec == 0:
		return 0.0

	var duration_usec = _last_sample_time_usec - _first_sample_time_usec
	if duration_usec <= 0:
		return 0.0

	var duration_sec = float(duration_usec) / 1_000_000.0
	return float(count) / duration_sec

func _ensure_sorted() -> void:
	if _cache_valid:
		return

	# Copy active samples (O(n))
	_cached_sorted.clear()
	_cached_sorted.resize(_sample_count)
	for i in range(_sample_count):
		_cached_sorted[i] = _samples[i]

	# Sort (O(n log n))
	_cached_sorted.sort()
	_cache_valid = true

func clear() -> void:
	_samples.clear()
	_samples.resize(MAX_SAMPLES)
	_sample_index = 0
	_sample_count = 0
	_cached_sorted.clear()
	_cache_valid = false
	min_usec = 0
	max_usec = 0
	total_usec = 0
	count = 0
	_first_sample_time_usec = 0
	_last_sample_time_usec = 0

func _to_string() -> String:
	if count == 0:
		return "no samples <- %s" % name

	var avg = get_avg_usec()
	var p50 = get_p50()
	var p90 = get_p90()
	var p95 = get_p95()
	var p99 = get_p99()
	var sps = get_samples_per_second()

	return "%s ->\n  #%5d [%s-%s ~%s] p:[%s %s %s %s] (%.1f/s)" % [
		name,
		count,
		format_duration(min_usec),
		format_duration(max_usec),
		format_duration_float(avg),
		format_duration(p50),
		format_duration(p90),
		format_duration(p95),
		format_duration(p99),
		sps,
	]

static func format_duration(usec: int) -> String:
	if usec < 1000:
		return "%dµs" % usec
	else:
		var ms = float(usec) / 1000.0
		return "%.2fms" % ms

static func format_duration_float(usec: float) -> String:
	if usec < 1000.0:
		return "%.1fµs" % usec
	else:
		var ms = usec / 1000.0
		return "%.2fms" % ms
