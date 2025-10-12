class_name PerformanceMonitor_ViewControl
extends Control

## Custom control for visualizing PerformanceMonitor waterfall data.
## Phase 1: Wraps existing ASCII rendering (will be replaced with direct drawing later)

# Reference to child RichTextLabel for rendering (temporary, Phase 1 only)
var _text_label: RichTextLabel = null

func _ready() -> void:
	# Create RichTextLabel for Phase 1 (ASCII rendering)
	_text_label = RichTextLabel.new()

	# Fill parent space using anchors (parent is Control, not Container)
	_text_label.anchor_right = 1.0
	_text_label.anchor_bottom = 1.0

	# Disable interactive features
	_text_label.scroll_active = false
	_text_label.scroll_following = true
	_text_label.shortcut_keys_enabled = false
	_text_label.deselect_on_focus_loss_enabled = false
	_text_label.drag_and_drop_selection_enabled = false

	# Styling
	_text_label.add_theme_color_override("default_color", Color(0, 0.631373, 0, 1))
	_text_label.add_theme_color_override("font_outline_color", Color(0.208557, 0.119206, 0.222108, 1))
	_text_label.add_theme_constant_override("outline_size", 8)

	# Font
	var font = load("res://Fonts/Hack-Regular.ttf")
	if font:
		_text_label.add_theme_font_override("normal_font", font)
	_text_label.add_theme_font_size_override("normal_font_size", 16)

	add_child(_text_label)

func update_display() -> void:
	"""Update the waterfall visualization. Phase 1: Uses ASCII from PerformanceMonitor."""
	if _text_label == null:
		return

	var waterfall = PerformanceMonitor.get_worst_frame_waterfall()
	_text_label.text = waterfall
