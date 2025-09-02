extends RefCounted
class_name EditorSnapSettings

var use_snap_button: Button
var translate_snap_input: LineEdit
var rotate_snap_input: LineEdit
var scale_snap_input: LineEdit

var snapping_enabled: bool = false
var translate_snap: float = 1.0
var rotate_snap: float = 15.0
var scale_snap: float = 0.1

func _init() -> void:
	use_snap_button = EditorInterface\
		.get_editor_main_screen()\
		.find_child('*Node3DEditor*', false, false)\
		.find_children('*', 'Button', true, false)\
		.filter(func (button: Button): return button.accessibility_name == "Use Snap")\
		.front()

	# Get the snap settings dialog inputs
	var snap_inputs: Array[Node] = EditorInterface\
		.get_editor_main_screen()\
		.find_child('*Node3DEditor*', false, false)\
		.find_children('*', 'ConfirmationDialog', false, false)\
		.filter(func (dialog: ConfirmationDialog): return dialog.title == "Snap Settings")\
		.front()\
		.find_children('*', 'LineEdit', true, false)


	translate_snap_input = snap_inputs.pop_front() as LineEdit
	rotate_snap_input = snap_inputs.pop_front() as LineEdit
	scale_snap_input = snap_inputs.pop_front() as LineEdit
	_update_settings()

func connect_settings() -> void:
	use_snap_button.toggled.connect(_on_use_snap_toggled)
	translate_snap_input.text_changed.connect(_on_snap_input_changed)
	rotate_snap_input.text_changed.connect(_on_snap_input_changed)
	scale_snap_input.text_changed.connect(_on_snap_input_changed)

func disconnect_settings() -> void:
	use_snap_button.toggled.disconnect(_on_use_snap_toggled)
	translate_snap_input.text_changed.disconnect(_on_snap_input_changed)
	rotate_snap_input.text_changed.disconnect(_on_snap_input_changed)
	scale_snap_input.text_changed.disconnect(_on_snap_input_changed)

func _update_settings() -> void:
	snapping_enabled = use_snap_button.button_pressed
	translate_snap = float(translate_snap_input.text)
	rotate_snap = float(rotate_snap_input.text)
	scale_snap = float(scale_snap_input.text)

func _on_use_snap_toggled(pressed: bool) -> void:
	_update_settings()

func _on_snap_input_changed(_new_text: String) -> void:
	_update_settings()
