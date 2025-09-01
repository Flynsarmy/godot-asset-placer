extends RefCounted
class_name FolderPresenter

signal folders_loaded(folder: Array[AssetFolder])

var folder_repository: FolderRepository
var asset_repository: AssetsRepository
var sync: Synchronize

func _init() -> void:
	folder_repository = FolderRepository.instance
	asset_repository = AssetsRepository.instance
	sync = Synchronize.new(folder_repository, asset_repository)


func _ready() -> void:
	folders_loaded.emit(folder_repository.get_all())

	folder_repository.folder_changed.connect(func():
		var folders: Array[AssetFolder] = folder_repository.get_all()
		folders_loaded.emit(folders)
	)


func delete_folder(folder: AssetFolder) -> void:
	folder_repository.delete(folder.path)
	for asset in asset_repository.get_all_assets():
		if asset.folder_path == folder.path:
			asset_repository.delete(asset.id)

func sync_folder(folder: AssetFolder) -> void:
	sync.sync_folder(folder)

func include_subfolders(include: bool, folder: AssetFolder) -> void:
	folder.include_subfolders = include
	folder_repository.update(folder)

func add_folder(folder: String) -> void:
	if folder.get_extension().is_empty():
		folder_repository.add(folder)

func add_folders(folders: PackedStringArray) -> void:
	for folder in folders:
		add_folder(folder)

func is_file_supported(file: String) ->  bool:
	return file.ends_with(".tscn") || file.ends_with(".glb") || file.ends_with(".fbx")
