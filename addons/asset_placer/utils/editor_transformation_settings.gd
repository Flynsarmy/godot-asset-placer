extends RefCounted
class_name EditorTransformationSettings

signal mode_changed(new_mode: AssetPlacerPresenter.TransformMode, old_mode: AssetPlacerPresenter.TransformMode)

var select_mode_button: Button
var move_mode_button: Button
var rotate_mode_button: Button
var scale_mode_button: Button

var mode: AssetPlacerPresenter.TransformMode = AssetPlacerPresenter.TransformMode.None

func _init() -> void:
	var transformation_inputs: Array[Node] = EditorInterface\
		.get_editor_main_screen()\
		.find_child('*Node3DEditor*', false, false)\
		.find_children('*', 'Button', true, false)\
		.filter(func (button: Button): return button.accessibility_name.contains("Mode"))

	select_mode_button = transformation_inputs\
		.filter(func (button: Button): return button.accessibility_name == "Select Mode")\
		.pop_front() as Button
	move_mode_button = transformation_inputs\
		.filter(func (button: Button): return button.accessibility_name == "Move Mode")\
		.pop_front() as Button
	rotate_mode_button = transformation_inputs\
		.filter(func (button: Button): return button.accessibility_name == "Rotate Mode")\
		.pop_front() as Button
	scale_mode_button = transformation_inputs\
		.filter(func (button: Button): return button.accessibility_name == "Scale Mode")\
		.pop_front() as Button

	_update_settings()

func connect_settings() -> void:
	select_mode_button.toggled.connect(_on_transformation_mode_button_toggled)
	move_mode_button.toggled.connect(_on_transformation_mode_button_toggled)
	rotate_mode_button.toggled.connect(_on_transformation_mode_button_toggled)
	scale_mode_button.toggled.connect(_on_transformation_mode_button_toggled)


func disconnect_settings() -> void:
	select_mode_button.toggled.disconnect(_on_transformation_mode_button_toggled)
	move_mode_button.toggled.disconnect(_on_transformation_mode_button_toggled)
	rotate_mode_button.toggled.disconnect(_on_transformation_mode_button_toggled)
	scale_mode_button.toggled.disconnect(_on_transformation_mode_button_toggled)


func _update_settings() -> void:
	var old_mode: AssetPlacerPresenter.TransformMode = mode

	if rotate_mode_button.button_pressed:
		mode = AssetPlacerPresenter.TransformMode.Rotate
	elif scale_mode_button.button_pressed:
		mode = AssetPlacerPresenter.TransformMode.Scale
	else:
		mode = AssetPlacerPresenter.TransformMode.None

	if old_mode != mode:
		mode_changed.emit(mode, old_mode)

func _on_transformation_mode_button_toggled(_toggled_on: bool) -> void:
	_update_settings()
