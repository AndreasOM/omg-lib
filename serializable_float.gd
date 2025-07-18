class_name SerializableFloat
extends Serializable

var _data: float = 0.0

func _init( value: float = 0.0 ) -> void:
	self._data = value
	
func value() -> float:
	return self._data

func is_equal( o: Serializable ) -> bool:
	var so = o as SerializableFloat
	if so == null:
		return false
	return self._data == so._data
	
	
func serialize( s: Serializer ) -> bool:
	self._data = s.serialize_f32( self._data )
	return true

func debug_str() -> String:
	return "%f" % self._data
