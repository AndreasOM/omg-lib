class_name PauseManager extends Node

enum PauseReason { NONE, PLAYER, FOCUS_LOST, CONTROLLER_DISCONNECT }
enum PauseState { RUNNING, PAUSED }

# Signals going UP (out of PauseManager)
signal pause_state_changed(state: PauseState, reason: PauseReason)

var _state: PauseState = PauseState.RUNNING
var _reason: PauseReason = PauseReason.NONE

# Methods going DOWN (into PauseManager)
func request_player_pause() -> void:
	match _state:
		PauseState.RUNNING:
			_transition_to(PauseState.PAUSED, PauseReason.PLAYER)
		PauseState.PAUSED:
			pass  # Already paused, use request_player_resume()

func request_player_resume() -> void:
	match _state:
		PauseState.RUNNING:
			pass  # Already running, nothing to do
		PauseState.PAUSED:
			_transition_to(PauseState.RUNNING, PauseReason.NONE)

func toggle_player_pause() -> void:
	match _state:
		PauseState.RUNNING:
			request_player_pause()
		PauseState.PAUSED:
			# Always allow player to resume, regardless of original pause reason
			request_player_resume()

func notify_focus_lost() -> void:
	match _state:
		PauseState.RUNNING:
			_transition_to(PauseState.PAUSED, PauseReason.FOCUS_LOST)
		PauseState.PAUSED:
			match _reason:
				PauseReason.FOCUS_LOST:
					pass  # Already paused for focus
				PauseReason.PLAYER:
					pass  # Player pause takes priority
				PauseReason.CONTROLLER_DISCONNECT:
					pass  # Controller disconnect takes priority
				PauseReason.NONE:
					_update_reason(PauseReason.FOCUS_LOST)
				_:
					pass  # Unknown reasons

func notify_focus_gained() -> void:
	match _state:
		PauseState.RUNNING:
			pass  # Not paused, nothing to do
		PauseState.PAUSED:
			pass  # Never auto-resume - only player can resume explicitly

func notify_controller_disconnected() -> void:
	match _state:
		PauseState.RUNNING:
			_transition_to(PauseState.PAUSED, PauseReason.CONTROLLER_DISCONNECT)
		PauseState.PAUSED:
			match _reason:
				PauseReason.FOCUS_LOST:
					_update_reason(PauseReason.CONTROLLER_DISCONNECT)
				PauseReason.PLAYER:
					pass  # Player pause takes priority
				PauseReason.CONTROLLER_DISCONNECT:
					pass  # Already paused for this reason
				PauseReason.NONE:
					_update_reason(PauseReason.CONTROLLER_DISCONNECT)
				_:
					pass  # Unknown reasons

# State queries
func get_state() -> PauseState:
	return _state

func get_reason() -> PauseReason:
	return _reason

func is_paused() -> bool:
	return _state == PauseState.PAUSED

# Enum to string helpers
static func state_to_string(state: PauseState) -> String:
	match state:
		PauseState.RUNNING:
			return "RUNNING"
		PauseState.PAUSED:
			return "PAUSED"
		_:
			return "UNKNOWN_STATE"

static func reason_to_string(reason: PauseReason) -> String:
	match reason:
		PauseReason.NONE:
			return "NONE"
		PauseReason.PLAYER:
			return "PLAYER"
		PauseReason.FOCUS_LOST:
			return "FOCUS_LOST"
		PauseReason.CONTROLLER_DISCONNECT:
			return "CONTROLLER_DISCONNECT"
		_:
			return "UNKNOWN_REASON"

# Internal helpers
func _transition_to(new_state: PauseState, reason: PauseReason) -> void:
	var state_changed = (_state != new_state)
	var reason_changed = (_reason != reason)

	if (
		state_changed
		|| reason_changed
	):
		_state = new_state
		_reason = reason
		pause_state_changed.emit(new_state, reason)

func _update_reason(new_reason: PauseReason) -> void:
	if _reason != new_reason:
		_reason = new_reason
		pause_state_changed.emit(_state, new_reason)
