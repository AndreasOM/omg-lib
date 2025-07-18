class_name SerializableString
extends Serializable

var _data: String = ""

func _init( value: String = "" ) -> void:
	self._data = value
	
func from_string( v: String ) -> void:
	self._data = v
func _to_string() -> String:
	return self._data

func is_equal( o: Serializable ) -> bool:
	var so = o as SerializableString
	if so == null:
		return false
	return self._data == so._data
	
func serialize( s: Serializer ) -> bool:
	var bytes = self._data.to_utf8_buffer()
	var l = bytes.size()
	l = s.serialize_u16( l )
	bytes.resize( l )
	for i in range(0, l):
		var b = bytes[ i ]
		b = s.serialize_u8( b )
		bytes[ i ] = b
	
	bytes.push_back( 0 ) # terminate
	self._data = bytes.get_string_from_utf8()	# :TODO: error handling
	
	return true

func debug_str() -> String:
	return "%s" % self._data
	
