class_name DialogManager
extends Node

@export var dialog_container: MarginContainer = null
@export var front_dialog_container: MarginContainer = null

var _dialog_scenes: Dictionary[ int, PackedScene ] = {}
var _dialogs: Dictionary[ int, Dialog ] = {}

func _ready() -> void:
	for c in dialog_container.get_children():
		c.get_parent().remove_child( c )
		c.queue_free()

func preload_dialog( id: int, path: String ) -> bool:
	var ds = ResourceLoader.load( path ) as PackedScene
	if ds == null:
		print_rich("[color=red][DialogManager] Failed to load %d -> %s" % [ id, path ] )
		return false
	
	self._dialog_scenes[ id ] = ds 
	
	return true

func open_dialog( id: int, duration: float ) -> Dialog:
		
	var d = self._dialogs.get( id, null )
	if d != null:
		return d

	if !self._dialog_scenes.has( id ):
		return null
		
	var ps: PackedScene = self._dialog_scenes.get( id, null )
	d = ps.instantiate() as Dialog
	d.id = id
	d.opened.connect( _on_dialog_opened )
	d.closed.connect( _on_dialog_closed )
	self._dialogs[ id ] = d
	self.dialog_container.add_child( d )
	d.open( duration )
		
	return d

func close_dialog( id: int, duration: float ) -> void:
	var d = self._dialogs.get( id, null )
	if d == null:
		return
		
	d.close( duration )

func _on_dialog_opened( dialog: Dialog ) -> void:
	pass

func _on_dialog_closed( dialog: Dialog ) -> void:
	self._dialogs.erase( dialog.id )
	dialog.get_parent().remove_child( dialog )
	dialog.queue_free()
