extends RefCounted
class_name AssetPlacerPresenter

static var _instance: AssetPlacerPresenter

static var TRANSFORM_STEP: float = 0.1

signal asset_deselected
signal parent_changed(parent: NodePath)
signal options_changed(options: AssetPlacerOptions)
signal transform_mode_changed(mode: TransformMode)
signal placement_mode_changed(mode: PlacementMode)
signal preview_transform_axis_changed(axis: Vector3)
signal asset_selected(asset: AssetResource)

var _selected_asset: AssetResource
var options: AssetPlacerOptions
var _parent: NodePath = NodePath("")
var transform_mode: TransformMode = TransformMode.None
var snap_settings: EditorSnapSettings

var placement_mode: PlacementMode = PlacementMode.SurfacePlacement.new():
	set(value):
		placement_mode = value
		placement_mode_changed.emit(value)

var preview_transform_axis: Vector3 = Vector3.UP


enum TransformMode {
	None,
	Rotate,
	Scale,
	Move
}

func _init() -> void:
	options = AssetPlacerOptions.new()
	snap_settings = EditorSnapSettings.new()
	_selected_asset = null
	_instance = self

func ready() -> void:
	options_changed.emit(options)
	placement_mode_changed.emit(placement_mode)

func up() -> void:
	snap_settings.connect_settings()

func down() -> void:
	snap_settings.disconnect_settings()

func select_placement_mode(mode: PlacementMode) -> void:
	placement_mode = mode

func select_parent(node: NodePath) -> void:
	_parent = node
	parent_changed.emit(node)

func toggle_transformation_mode(mode: TransformMode) -> void:
	if transform_mode == mode:
		transform_mode = TransformMode.None
	else:
		transform_mode = mode
	transform_mode_changed.emit(transform_mode)
	_select_default_axis(transform_mode)

func clear_parent() -> void:
	_parent = NodePath("")
	parent_changed.emit(_parent)

func set_unform_scaling(value: bool) -> void:
	options.uniform_scaling = value
	if value:
		options.min_scale = uniformV3(options.min_scale.x)
		options.max_scale = uniformV3(options.max_scale.x)
	options_changed.emit(options)

func toggle_axis(axis: Vector3) -> void:
	var new: Vector3 = (preview_transform_axis - axis).abs()
	select_axis(new)

func select_axis(axis: Vector3) -> void:
	preview_transform_axis = axis
	preview_transform_axis_changed.emit(preview_transform_axis)

func _select_default_axis(mode: TransformMode) -> void:
	match mode:
		TransformMode.Rotate:
			select_axis(Vector3.UP)
		TransformMode.Scale:
			select_axis(Vector3.ONE)
		TransformMode.Move:
			select_axis(Vector3.BACK)
		_: pass

func uniformV3(value: float) -> Vector3:
	return Vector3(value, value, value)

func set_min_rotation(vector: Vector3) -> void:
	options.min_rotation = vector
	options_changed.emit(options)

func set_max_scale(vector: Vector3) -> void:
	options.max_scale = vector
	options_changed.emit(options)

func set_min_scale(vector: Vector3) -> void:
	options.min_scale = vector
	options_changed.emit(options)


func set_max_rotation(vector: Vector3) -> void:
	options.max_rotation = vector
	options_changed.emit(options)

func cancel() -> void:
	if transform_mode != TransformMode.None:
		toggle_transformation_mode(TransformMode.None)
	else:
		clear_selection()

func clear_selection() -> void:
	_selected_asset = null
	asset_deselected.emit()

func select_asset(asset: AssetResource) -> void:
	if asset == _selected_asset:
		_selected_asset = null
		asset_deselected.emit()
	else:
		_selected_asset = asset
		asset_selected.emit(asset)
