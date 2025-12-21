class_name Dialog
extends MarginContainer

signal opening( dialog: Dialog )
signal opened( dialog: Dialog )
signal closing( dialog: Dialog )
signal closed( dialog: Dialog )

var id: int = -1

func open( _duration: float ) -> void:
	self.opening.emit( self )
	self.visible = true
	self.opened.emit( self )

func close( _duration: float ) -> void:
	self.closing.emit( self )
	self.visible = false
	# :TODO: Do for all children?
	# self.mouse_filter = Control.MOUSE_FILTER_IGNORE
	self.closed.emit( self )
