class_name Serializable

static func _default() -> Variant:
	return null

func is_equal( o: Serializable ) -> bool:
	return false
	
func serialize( s: Serializer ) -> bool:
	return false

func debug_str() -> String:
	return "[???]"
