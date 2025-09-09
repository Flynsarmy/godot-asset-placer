@tool
extends Control
@onready var rotate_check_button: CheckBox = %RotateCheckButton
@onready var scale_check_button: CheckBox = %ScaleCheckButton
@onready var x_check_button: CheckButton = %XCheckButton
@onready var z_check_button: CheckButton = %ZCheckButton
@onready var y_check_button: CheckButton = %YCheckButton
@onready var placement_mode_label: Label = %PlacementModeLabel
@onready var error_label: Label = %ErrorLabel
@onready var error_container = %ErrorContainer

var presenter: AssetPlacerPresenter

func _ready():
	hide()
	presenter = AssetPlacerPresenter.instance()
	presenter.transform_mode_changed.connect(set_mode)
	presenter.preview_transform_axis_changed.connect(set_axis)
	presenter.asset_selected.connect(func(a): show())
	presenter.asset_deselected.connect(func(): hide())
	presenter.placement_mode_changed.connect(set_placement_mode)
	presenter.error_shown.connect(show_error)
	presenter.error_hidden.connect(hide_error)
	set_mode(presenter.transform_mode)
	set_axis(presenter.preview_transform_axis)

func _process(delta: float) -> void:
	if error_container.is_visible_in_tree():
		error_label.text = presenter.error_message


func set_mode(mode: AssetPlacerPresenter.TransformMode) -> void:
	rotate_check_button.button_pressed = mode == AssetPlacerPresenter.TransformMode.Rotate
	scale_check_button.button_pressed = mode == AssetPlacerPresenter.TransformMode.Scale

func set_placement_mode(mode: PlacementMode):
	if mode is PlacementMode.PlanePlacement:
		placement_mode_label.text = "Plane Placement"
	if mode is PlacementMode.SurfacePlacement:
		placement_mode_label.text = "Surface Placement"

func show_error():
	error_container.show()
	error_label.text = presenter.error_message

func hide_error():
	error_container.hide()

func set_axis(vector: Vector3):
	x_check_button.button_pressed = vector.x == 1
	y_check_button.button_pressed = vector.y == 1
	z_check_button.button_pressed = vector.z == 1
