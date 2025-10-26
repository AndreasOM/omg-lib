extends Node
class_name OmgCanvasItemAlphaFader

@export var target_path: NodePath = ".."
var _target: CanvasItem = null
var _control_target: Control = null
var _initial_mouse_filter: int = Control.MOUSE_FILTER_IGNORE

signal fading_in(duration: float)
signal faded_in()
signal fading_out(duration: float)
signal faded_out()

var _alpha: float = 1.0
var _alpha_speed: float = 0.0

func _ready() -> void:
    _target = get_node_or_null(target_path) as CanvasItem
    if _target == null:
        push_error("%s: OmgCanvasItemAlphaFader target not found: %s" % [name, target_path])
        set_process(false)
        return
    # if the target is a Control, record its original mouse filter
    _control_target = _target if _target is Control else null
    if _control_target:
        _initial_mouse_filter = _control_target.mouse_filter
    # initialize alpha and visibility
    _target.modulate.a = _alpha
    set_process(true)

func _process(delta: float) -> void:
    if _alpha_speed == 0.0 or _target == null:
        return
    _alpha += _alpha_speed * delta
    if _alpha_speed > 0.0 and _alpha >= 1.0:
        _alpha = 1.0
        _alpha_speed = 0.0
        emit_signal("faded_in")
    elif _alpha_speed < 0.0 and _alpha <= 0.0:
        _alpha = 0.0
        _alpha_speed = 0.0
        # once fully faded out, hide and block input
        _target.visible = false
        if _control_target:
            _control_target.mouse_filter = Control.MOUSE_FILTER_IGNORE
        emit_signal("faded_out")
    # always apply computed alpha
    _target.modulate.a = _alpha

func fade_in(duration: float) -> void:
    if _target == null:
        return
    # make visible and restore input
    _target.visible = true
    if _control_target:
        _control_target.mouse_filter = _initial_mouse_filter
        # :TODO: Match old FadeableContainer behavior for now.
        # Sets all children to STOP without remembering their initial values.
        # This needs more consideration - should we track initial values per child?
        # Problem: Dynamic children added after _ready() won't be tracked.
        for c in _control_target.get_children():
            if c is Control:
                c.mouse_filter = Control.MOUSE_FILTER_STOP
    if duration > 0.0:
        _alpha_speed = (1.0 - _alpha) / duration
        emit_signal("fading_in", duration)
    else:
        _alpha_speed = 0.0
        _alpha = 1.0
        _target.modulate.a = _alpha
        emit_signal("fading_in", duration)
        emit_signal("faded_in")

func fade_out(duration: float) -> void:
    if _target == null:
        return
    # immediately block input
    if _control_target:
        _control_target.mouse_filter = Control.MOUSE_FILTER_IGNORE
        # :TODO: Match old FadeableContainer behavior - see fade_in()
        for c in _control_target.get_children():
            if c is Control:
                c.mouse_filter = Control.MOUSE_FILTER_IGNORE
    if duration > 0.0:
        _alpha_speed = -_alpha / duration
        emit_signal("fading_out", duration)
    else:
        _alpha_speed = 0.0
        _alpha = 0.0
        _target.modulate.a = _alpha
        _target.visible = false
        emit_signal("fading_out", duration)
        emit_signal("faded_out")

func toggle(duration: float) -> void:
    if _alpha <= 0.0 or _alpha_speed < 0.0:
        fade_in(duration)
    else:
        fade_out(duration)