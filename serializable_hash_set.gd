class_name SerializableHashSet

var _data: Dictionary[ int, bool ] = {}
var _default_key: int = 0

func _init( default_key: int ) -> void:
	_default_key = default_key

func serialize( s: Serializer ) -> bool:
	var the_keys = self.keys()
	var number = the_keys.size()
	number = s.serialize_u16( number )
	
	for idx in range(0,number):
		var k = _default_key
		if idx < the_keys.size():
			k = the_keys[ idx ]
		k = s.serialize_u32( k )
		self.add_entry( k )
		
	return true

func size() -> int:
	return _data.size()
	
func keys() -> Array:
	return _data.keys()
	
func erase( key: int ) -> bool:
	return _data.erase( key )

func clear() -> void:
	_data.clear()
	
func has( key: int ) -> bool:
	return _data.has( key )

func add_entry(key: int) -> bool:
	return _data.set(key, true )
	
func get_entry( key: int ) -> bool:
	var e = _data.get( key )
	return e != null && e
	
