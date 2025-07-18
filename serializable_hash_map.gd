class_name SerializableHashMap

var _data: Dictionary[ Serializable, Serializable ] = {}
var _default_key: Serializable = null
var _default_constructor: Callable = Callable()

func _init( default_key: Serializable, default_constructor: Callable ) -> void:
	if default_constructor == null:
		push_warning("SerializableHashMap: default_constructor == null")
	if default_constructor.is_null():
		push_warning("SerializableHashMap: default_constructor.is_null()")
	_default_key = default_key
	_default_constructor = default_constructor

func serialize( s: Serializer ) -> bool:
	var the_keys = self.keys()
	var number = the_keys.size()
	number = s.serialize_u16( number )
	
	for idx in range(0,number):
		var k: Serializable = _default_key
		var v = _default_constructor.call()
		if idx < the_keys.size():
			k = the_keys[ idx ]
			v = self.get_entry( k, v )
		k.serialize( s )
		v.serialize( s )
		self.set_entry( k, v )
		
	
	return true

func size() -> int:
	return _data.size()
	
func keys() -> Array:
	return _data.keys()
	
func erase( key: Serializable ) -> bool:
	return _data.erase( key )

func clear() -> void:
	_data.clear()
	
func set_entry(key: Serializable, value: Serializable) -> bool:
	for k in _data.keys():
		if k.is_equal( key ):
			_data[k] = value
			return true
	return _data.set(key, value )
	
func get_entry( key: Serializable, default: Serializable = null ) -> Serializable:
	for k in _data.keys():
		if k.is_equal( key ):
			var v = _data[k]
			return v
			
	return default
	# return _data.get( key, default )
	
func get_or_add( key: Serializable, default: Serializable ) -> Serializable:
	return _data.get_or_add( key, default )


func debug_str() -> String:
	var r = ""
	for k in _data.keys():
		var v = _data[k]
		r += "%s -> %s" %[ k.debug_str(), v.debug_str() ]
	
	return r
	
