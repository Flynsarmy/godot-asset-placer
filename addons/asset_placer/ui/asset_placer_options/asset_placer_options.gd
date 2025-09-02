@tool
extends Control

@onready var min_rotation_selector: SpinBoxVector3 = %MinRotationSelector
@onready var max_rotation_selector: SpinBoxVector3 = %MaxRotationSelector

@onready var min_scale_selector: SpinBoxVector3 = %MinScaleSelector
@onready var max_scale_selector: SpinBoxVector3 = %MaxScaleSelector
@onready var uniform_scale_check_box: CheckBox = %UniformScaleCheckBox
@onready var parent_button: Button = %ParentButton
@onready var placement_mode_options_button: OptionButton = %PlacementModeOptionsButton
@onready var plane_axis_spin_box: SpinBoxVector3 = %PlaneAxisSpinBox
@onready var plane_origin_spin_box: SpinBoxVector3 = %PlaneOriginSpinBox
@onready var plane_origin_container: Container = %PlaneOriginContainer
@onready var plane_axis_container: Container = %PlaneAxisContainer

var presenter: AssetPlacerPresenter

func _ready() -> void:
	presenter = AssetPlacerPresenter._instance
	presenter.options_changed.connect(set_options)
	presenter.parent_changed.connect(show_parent)

	placement_mode_options_button.item_selected.connect(func(id):
		match id:
			0: presenter.placement_mode = PlacementMode.SurfacePlacement.new()
			1: presenter.placement_mode = PlacementMode.PlanePlacement.new()
	)

	max_rotation_selector.value_changed.connect(presenter.set_max_rotation)
	min_rotation_selector.value_changed.connect(presenter.set_min_rotation)
	min_scale_selector.value_changed.connect(presenter.set_min_scale)
	max_scale_selector.value_changed.connect(presenter.set_max_scale)
	uniform_scale_check_box.toggled.connect(presenter.set_unform_scaling)

	plane_axis_spin_box.value_changed.connect(func(normal: Vector3):
		var plane = PlaneOptions.new(normal, plane_origin_spin_box.get_vector())
		presenter.placement_mode = PlacementMode.PlanePlacement.new(plane)
	)

	plane_origin_spin_box.value_changed.connect(func(origin: Vector3):
		var plane = PlaneOptions.new(plane_axis_spin_box.get_vector(), origin)
		presenter.placement_mode = PlacementMode.PlanePlacement.new(plane)
	)

	presenter.placement_mode_changed.connect(func(mode: PlacementMode):
		if mode is PlacementMode.PlanePlacement:
			plane_axis_container.show()
			plane_origin_container.show()
			plane_axis_spin_box.set_value_no_signal(mode.plane_options.normal)
			plane_origin_spin_box.set_value_no_signal(mode.plane_options.origin)
		else:
			plane_axis_container.hide()
			plane_origin_container.hide()
		)

	parent_button.pressed.connect(func():
		EditorInterface.popup_node_selector(presenter.select_parent, [&"Node3D"])
	)

	presenter.ready()



func show_parent(parent: NodePath) -> void:
	if not parent.is_empty():
		var scene: Node = EditorInterface.get_edited_scene_root()
		var node: Node = scene.get_node(parent)
		parent_button.text = node.name
		parent_button.icon = EditorIconTexture2D.new(node.get_class())
	else:
		parent_button.text = "No parent selected"
		parent_button.icon = EditorIconTexture2D.new("NodeWarning")

func set_options(options: AssetPlacerOptions) -> void:
	max_rotation_selector.set_value_no_signal(options.max_rotation)
	min_rotation_selector.set_value_no_signal(options.min_rotation)
	min_scale_selector.set_value_no_signal(options.min_scale)
	max_scale_selector.set_value_no_signal(options.max_scale)
	min_scale_selector.uniform = options.uniform_scaling
	max_scale_selector.uniform = options.uniform_scaling
	uniform_scale_check_box.set_pressed_no_signal(options.uniform_scaling)
