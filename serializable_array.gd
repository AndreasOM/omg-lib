class_name SerializableArray

var _data: Array = []
var _default_constructor: Callable = Callable()

func _init( default_constructor: Callable ) -> void:
	_default_constructor = default_constructor

func serialize( s: Serializer ) -> bool:
	var l = self.size()
	l = s.serialize_u16( l )
	self.resize( l )
	for i in range(0, l):
		var	v = self.get_entry( i )
		if v == null:
			v = _default_constructor.call()
		if v.has_method( "serialize" ):
			v.serialize( s )
		else:
			push_error( "Can not serialize %s" % v )
			return false
		self.set_entry( i, v )
	return true

func size() -> int:
	return _data.size()
	
func clear() -> void:
	_data.clear()
	

func _find_object( what: Object, from: int = 0 ) -> int:
	var what_string = what.to_string()
	for idx in range( from, self._data.size() ):
		var v = self._data[ idx ]
		if typeof( v ) != TYPE_OBJECT:
			return -1
		var v_string = v.to_string()
		if v_string == what_string:
			return idx
		
	return -1
func find( what: Variant, from: int = 0) -> int:
	match typeof( what ):
		TYPE_OBJECT:
			return self._find_object( what as Object, from )
		_:
			push_warning( "SerializableArray find used with non-object type")
			return self._data.find(what, from)

func take( value: Variant ) -> Variant:
	var idx = self.find( value, 0 )
	if idx < 0:
		return null
	return self._data.pop_at( idx )
	
func has( value: Variant ) -> bool:
	return self.find( value, 0 ) != -1

func erase( value: Variant ) -> void:
	var idx = self.find( value, 0 )
	if idx < 0:
		return
	self._data.remove_at( idx )

func get_entry( idx: int ) -> Variant:
	return _data.get( idx )
	
func set_entry( idx: int, v: Variant ):
	_data.set( idx, v )
	
func push_back( v: Variant ):
	_data.push_back( v )
	
func pop_back() -> Variant:
	return _data.pop_back()
	
func insert( pos: int, v: Variant ) -> int:
	return _data.insert( pos, v )

func resize( s: int ) -> int:
	return _data.resize( s )

func iter() -> SerializableArrayIterator:
	return SerializableArrayIterator.new( self, 0, self.size(), 1 )
