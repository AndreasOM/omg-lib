@tool

class_name OmgLabel
extends Control

signal fully_faded_in

class Glyph:
	var codepoint: int
	var position: Vector2
	var size: Vector2
	
@export_multiline var text: String = ""
@export var char_fade_in_duration: float = 0.1

var _current_glyph_index: int = 0
var _current_glyph_alpha: float = 0.0
var _animating: bool = false


var _needs_relayout: bool = true
var _layout_size: Vector2
var _baseline_offset: float
var _glyphs: Array[ Glyph ] = []

func	 _ready() -> void:
	queue_redraw()
	self._start_fade_in()
	
func set_text( t: String ) -> void:
	self.text = t
	self._needs_relayout = true
	queue_redraw()
	self._start_fade_in()
	
func _get_theme_type_variation() -> String:
	return "Label"
	
func _start_fade_in():
	_current_glyph_index = 0
	_current_glyph_alpha = 0.0
	_animating = true
	#set_process(true)
	queue_redraw()


func _relayout_if_needed() -> void:
	if !self._needs_relayout:
		return
	self._needs_relayout = false
	self._layout()

func _layout() -> void:
	var font: FontFile = get_theme_font("font")
	var font_size = get_theme_font_size("font_size")	
	var size = font.get_string_size(self.text, font_size)
	self._layout_size = size
	var ascent = font.get_ascent(font_size)
	self._baseline_offset = ascent
	
	self._glyphs.clear()
	var y = 0.0
	var max_line_width = 0.0
	var cache_index = 0	
	
	var lines = text.split("\n")
	var line_height = font.get_height(font_size)

	for line_text in lines:
		var x = 0.0
		var prev_glyph_index = 0
		for i in line_text.length():
			var char_str = line_text[i]
			var char_code = char_str.unicode_at(0)
			var glyph_index = font.get_glyph_index(font_size, char_code, 0)
			if i > 0:
				var kerning = font.get_kerning(
					cache_index,
					font_size,
					Vector2i(prev_glyph_index, glyph_index)
				)
				x += kerning.x
			var char_size = font.get_char_size(char_code, font_size)
			
			var g := Glyph.new()
			g.codepoint = char_code
			g.position = Vector2(x, y + ascent)
			
			g.size = char_size

			self._glyphs.append(g)

			x += char_size.x
			prev_glyph_index = glyph_index
		y += line_height
		if x > max_line_width:
			max_line_width = x
	self._layout_size = Vector2(max_line_width, y)

func _get_minimum_size() -> Vector2:
	self._relayout_if_needed()
	return self._layout_size

func _process(delta: float) -> void:
	if ! self._animating:
		return

	_current_glyph_alpha += delta / char_fade_in_duration

	if _current_glyph_alpha >= 1.0:
		_current_glyph_alpha = 0.0
		_current_glyph_index += 1

		if _current_glyph_index >= _glyphs.size():
			_animating = false
			self.fully_faded_in.emit()
			# set_process(false)
			# _current_glyph_index = _glyphs.size() - 1

	queue_redraw()
	
func _draw() -> void:
	self._relayout_if_needed()
	var font: FontFile = get_theme_font("font")
	var font_size = get_theme_font_size("font_size")
	#var font_color = get_theme_color("font_color")
	var font_color: Color
	if has_theme_color("font_color"):
		font_color = get_theme_color("font_color")
	else:
		font_color = Color(1,1,1,1)	
	#draw_rect(Rect2(Vector2.ZERO, size), Color.RED)

	var canvas_item = get_canvas_item()
	var ascent = font.get_ascent(font_size)
		
	for i in _glyphs.size():
		var glyph = _glyphs[i]
		#var top_left = Vector2(glyph.position.x, glyph.position.y - glyph.size.y)
		#draw_rect(Rect2(top_left, glyph.size), Color(0,1,0,0.5))		

		var color = font_color
		if i < _current_glyph_index:
			color.a = 1.0
		elif i == _current_glyph_index:
			color.a = _current_glyph_alpha
		else:
			color.a = 0.0
			break

		font.draw_char(
			canvas_item,
			glyph.position,
			glyph.codepoint,
			font_size,
			color
		)
