extends RefCounted
class_name Synchronize

var asset_repository: AssetsRepository

static var _instance: Synchronize

signal sync_state_change(running: bool)
signal sync_complete(added: int, removed: int, scanned: int)

var _added = 0
var _removed = 0
var _scanned = 0

var sync_running = false:
	set(value):
		sync_running = value
		call_deferred("emit_signal", "sync_state_change", value)

func _init(assets_repository: AssetsRepository):
	self.asset_repository = assets_repository

static func instance(assets_repository: AssetsRepository) -> Synchronize:
	if not _instance:
		_instance = Synchronize.new(assets_repository)
	return _instance

func sync_all():

	if sync_running:
		push_error("Sync is already running")
		return

	AssetPlacerAsync.instance().enqueue(func():
		sync_running = true
		_sync_all()
		_notify_scan_complete()
		sync_running = false
	)

func _sync_all():
	_clear_invalid_assets()

func add_assets_from_folder(folder_path: String, recursive: bool):
	var dir = DirAccess.open(folder_path)
	for file in dir.get_files():
		_scanned += 1
		var path = folder_path + "/" + file
		if asset_repository.add_asset(path, [], folder_path):
			_added += 1

	if recursive:
		for sub_dir in dir.get_directories():
			var path: String = folder_path + "/" + sub_dir
			add_assets_from_folder(path, true)


func _notify_scan_complete():
	if _added != 0 || _removed != 0:
		call_deferred("emit_signal", "sync_complete", _added, _removed, _scanned)
	_clear_data()

func _clear_invalid_assets():
	for asset in asset_repository.get_all_assets():
		if asset.scene == null:
			_removed += 1
			asset_repository.delete(asset.id)

func _clear_data():
	_removed = 0
	_added = 0
	_scanned = 0
