@tool
extends EditorPlugin

const ADDON_PATH: String = "res://addons/asset_placer"

var _folder_repository: FolderRepository
var _presenter: AssetPlacerPresenter
var  _asset_placer: AssetPlacer
var _assets_repository: AssetsRepository
var synchronizer: Synchronize
#var _updater: PluginUpdater
var _async: AssetPlacerAsync

var _asset_placer_window: AssetLibraryPanel
var _file_system: EditorFileSystem = EditorInterface.get_resource_filesystem()
var _viewport_overlay_res: PackedScene = preload("res://addons/asset_placer/ui/viewport_overlay/viewport_overlay.tscn")
var _plane_preview: Node3D
var overlay: Control

var plugin_path: String:
	get(): return get_script().resource_path.get_base_dir()


func _enable_plugin() -> void:
	pass

func _disable_plugin() -> void:
	pass

func _enter_tree() -> void:
	_async = AssetPlacerAsync.new()
	#_updater = PluginUpdater.new(ADDON_PATH +  "/plugin.cfg", "")
	_asset_placer = AssetPlacer.new(get_undo_redo())
	_folder_repository = FolderRepository.new()
	_assets_repository = AssetsRepository.new()
	synchronizer = Synchronize.new(_folder_repository, _assets_repository)
	_presenter = AssetPlacerPresenter.new()
	scene_changed.connect(_handle_scene_changed)
	_presenter.asset_selected.connect(start_placement)
	_presenter.asset_deselected.connect(_asset_placer.stop_placement)
	_presenter.up()
	_asset_placer_window = load("res://addons/asset_placer/ui/asset_library_panel.tscn").instantiate()
	add_control_to_bottom_panel(_asset_placer_window, "Asset Placer")

	_plane_preview = load("res://addons/asset_placer/ui/plane_preview/plan_preview.tscn").instantiate()
	get_tree().root.add_child(_plane_preview)

	synchronizer.sync_complete.connect(func(added, removed, scanned):
		var message: String = "Asset Placer Sync complete\nAdded: %d Removed: %d Scanned total: %d" % [added, removed, scanned]
		EditorToasterCompat.toast(message)
	)

	overlay =  _viewport_overlay_res.instantiate()
	get_editor_interface().get_editor_viewport_3d().add_child(overlay)

	_file_system.resources_reimported.connect(_react_to_reimorted_files)
	if !_file_system.is_scanning():
		synchronizer.sync_all()


func _exit_tree() -> void:
	overlay.queue_free()
	_plane_preview.queue_free()
	_file_system.resources_reimported.disconnect(_react_to_reimorted_files)
	_presenter.down()
	_presenter.asset_selected.disconnect(start_placement)
	_presenter.asset_deselected.disconnect(_asset_placer.stop_placement)
	_asset_placer.stop_placement()
	scene_changed.disconnect(_handle_scene_changed)
	remove_control_from_bottom_panel(_asset_placer_window)
	_asset_placer_window.queue_free()
	_async.await_completion()


func _handles(object: Object) -> bool:
	return object is Node3D

func _handle_scene_changed(scene: Node) -> void:
	if scene is Node3D:
		_presenter.select_parent(scene.get_path())
	else:
		_presenter.clear_parent()


func _react_to_reimorted_files(files: PackedStringArray):
	synchronizer.sync_all()

func start_placement(asset: AssetResource) -> void:
	EditorInterface.set_main_screen_editor("3D")
	AssetPlacerContextUtil.select_context()
	_asset_placer.start_placement(get_tree().root, asset, _presenter.placement_mode)

func _forward_3d_gui_input(viewport_camera: Camera3D, event: InputEvent) -> int:
	if event is InputEventMouseMotion:
		if event.button_mask == 0:
			if _asset_placer.move_preview(event.position, viewport_camera):
				return EditorPlugin.AFTER_GUI_INPUT_STOP
			else:
				return EditorPlugin.AFTER_GUI_INPUT_PASS

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			return _asset_placer.place_asset(Input.is_key_pressed(KEY_SHIFT))
				#print(1)
				#return EditorPlugin.AFTER_GUI_INPUT_STOP
			#else:
				#print(0)
				#EditorPlugin.AFTER_GUI_INPUT_PASS
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN or event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var direction: int = -1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1
			var axis: Vector3 = _presenter.preview_transform_axis
			if _asset_placer.transform_preview(_presenter.transform_mode, axis, direction):
				return EditorPlugin.AFTER_GUI_INPUT_STOP
			else:
				return EditorPlugin.AFTER_GUI_INPUT_PASS

	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_E:
			_presenter.toggle_transformation_mode(AssetPlacerPresenter.TransformMode.Rotate)
			return EditorPlugin.AFTER_GUI_INPUT_STOP

		if event.keycode == KEY_R:
			_presenter.toggle_transformation_mode(AssetPlacerPresenter.TransformMode.Scale)
			return EditorPlugin.AFTER_GUI_INPUT_STOP

		if event.keycode == KEY_W:
			_presenter.toggle_transformation_mode(AssetPlacerPresenter.TransformMode.None)
			return EditorPlugin.AFTER_GUI_INPUT_STOP

		if event.keycode == KEY_ESCAPE:
			_presenter.cancel()
			return EditorPlugin.AFTER_GUI_INPUT_STOP

		if event.keycode == KEY_Y:
			_presenter.toggle_axis(Vector3.UP)
			return EditorPlugin.AFTER_GUI_INPUT_STOP


		if event.keycode == KEY_Z:
			_presenter.toggle_axis(Vector3.BACK)
			return EditorPlugin.AFTER_GUI_INPUT_STOP

		if event.keycode == KEY_X:
			_presenter.toggle_axis(Vector3.RIGHT)
			return EditorPlugin.AFTER_GUI_INPUT_STOP


	return EditorPlugin.AFTER_GUI_INPUT_PASS
