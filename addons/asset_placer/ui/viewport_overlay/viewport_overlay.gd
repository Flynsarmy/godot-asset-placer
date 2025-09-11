@tool
extends Control
@onready var rotate_check_button: CheckBox = %RotateCheckButton
@onready var scale_check_button: CheckBox = %ScaleCheckButton
@onready var x_check_button: CheckButton = %XCheckButton
@onready var z_check_button: CheckButton = %ZCheckButton
@onready var y_check_button: CheckButton = %YCheckButton
@onready var placement_mode_label: Label = %PlacementModeLabel
@onready var error_label: Label = %ErrorLabel
@onready var error_container: HBoxContainer = %ErrorContainer
@onready var mouse_container: MarginContainer = %MouseContainer
@onready var position_label: Label = %PositionLabel


var presenter: AssetPlacerPresenter

func _ready():
	hide()
	error_container.hide()
	presenter = AssetPlacerPresenter.instance()
	presenter.transform_mode_changed.connect(set_mode)
	presenter.preview_transform_axis_changed.connect(set_axis)
	presenter.asset_selected.connect(func(a): show())
	presenter.asset_deselected.connect(func(): hide())
	presenter.placement_mode_changed.connect(set_placement_mode)
	presenter.error_changed.connect(update_error)
	set_mode(presenter.transform_mode)
	set_axis(presenter.preview_transform_axis)

func _forward_3d_gui_input(viewport_camera: Camera3D, event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_container.global_position = get_global_mouse_position() + Vector2(-200, 40)

func set_mode(mode: AssetPlacerPresenter.TransformMode) -> void:
	rotate_check_button.button_pressed = mode == AssetPlacerPresenter.TransformMode.Rotate
	scale_check_button.button_pressed = mode == AssetPlacerPresenter.TransformMode.Scale

func set_placement_mode(mode: PlacementMode):
	if mode is PlacementMode.PlanePlacement:
		placement_mode_label.text = "Plane Placement"
	if mode is PlacementMode.SurfacePlacement:
		placement_mode_label.text = "Surface Placement"

func update_error(new_value: String) -> void:
	if new_value:
		error_container.show()
		error_label.text = new_value
	else:
		error_container.hide()

func set_axis(vector: Vector3) -> void:
	x_check_button.button_pressed = vector.x == 1
	y_check_button.button_pressed = vector.y == 1
	z_check_button.button_pressed = vector.z == 1

func _on_preview_transformed(preview_node: Node3D) -> void:
	var prev_scale: float = preview_node.scale.x
	var pos: Vector3 = preview_node.global_position
	position_label.text = "(%.3f, %.3f, %.3f) %.1fs" % [pos.x, pos.y, pos.z, prev_scale]
