class_name SerializableArrayIterator

var _start
var _increment
var _stop
var _current
var _sa

func _init( sa: SerializableArray, start, stop, increment) -> void:
	self._sa = sa
	self._start = start
	self._current = start
	self._stop = stop
	self._increment = increment

func should_continue() -> bool:
	return (_current < _stop)

func _iter_init(_arg) -> bool:
	return should_continue()

func _iter_next(_arg) -> bool:
	_current += _increment
	return should_continue()

func _iter_get(_arg) -> Variant:
	return _sa.get_entry( _current )
		
