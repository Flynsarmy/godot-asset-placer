extends RefCounted
class_name AssetLibraryPresenter

var library: AssetLibrary
var assets_repository: AssetsRepository
var synchronizer: Synchronize

var _active_collections: Array[AssetCollection] = []
var _current_assets: Array[AssetResource]
var _current_query: String

enum EmptyType {
	Search,  Collection, All, None
}

signal assets_loaded(assets: Array[AssetResource])
signal asset_selection_change
signal show_filter_info(size: int)
signal show_sync_active(bool)
signal show_empty_view(type: EmptyType)

func _init() -> void:
	assets_repository = AssetsRepository.instance()
	synchronizer = Synchronize.instance(assets_repository)



func on_ready() -> void:
	_current_assets = assets_repository.get_all_assets()
	show_filter_info.emit(0)
	assets_repository.assets_changed.connect(_filter_by_collections_and_query)
	_filter_by_collections_and_query()
	synchronizer.sync_state_change.connect(func(v):
		show_sync_active.emit(v)
	)

func add_asset_folder(path: String) -> void:
	var dir_access: DirAccess = DirAccess.open(path)
	for file in dir_access.get_files():
		add_asset(path + file, path)

func on_query_change(query: String) -> void:
	self._current_query = query
	_filter_by_collections_and_query()

func add_asset(path: String, folder_path: String) -> void:
	var tags: Array[String] = []
	for collection in _active_collections:
		tags.push_back(collection.name)

	var id: Variant = ResourceIdCompat.path_to_uid(path)
	if !id:
		push_error("Error getting id from path %s" % path)
		return

	var existing: AssetResource = assets_repository.find_by_uid(id)
	if existing:
		var new_tags: Array[String] = []
		for tag in tags:
			if tag not in existing.tags:
				new_tags.push_back(tag)

		existing.tags.append_array(new_tags)
		assets_repository.update(existing)
	else:
		assets_repository.add_asset(path, tags, folder_path)


func delete_asset(asset: AssetResource) -> void:
	assets_repository.delete(asset.id)

func add_assets_or_folders(files: PackedStringArray) -> void:
	for file in files:
		if file.get_extension().is_empty():
			add_asset_folder(file)
		else:
			add_asset(file, "")

func toggle_asset_collection(asset: AssetResource, collection: AssetCollection, add: bool) -> void:
	if add:
		asset.tags.append(collection.name)
		assets_repository.update(asset)
	else:
		asset.tags.erase(collection.name)
		assets_repository.update(asset)

	_filter_by_collections_and_query()

func toggle_collection_filter(collection: AssetCollection, enabled: bool) -> void:
	if enabled:
		_active_collections.push_back(collection)
	else:
		_active_collections = _active_collections.filter(func(a):
			return a.name != collection.name
		)
	show_filter_info.emit(_active_collections.size())
	_filter_by_collections_and_query()



func _filter_by_collections_and_query() -> void:
	var all: Array[AssetResource] = assets_repository.get_all_assets()
	var filtered: Array[AssetResource] = []

	for asset in all:
		var matches_query: bool = asset.name.containsn(_current_query) || _current_query.is_empty()
		var belongs_to_collection: bool = asset.belongs_to_some_collection(_active_collections) || _active_collections.is_empty()

		if matches_query and belongs_to_collection:
			filtered.push_back(asset)

	if filtered.is_empty():
		if _active_collections.is_empty() && _current_query.is_empty():
			show_empty_view.emit(EmptyType.All)
		elif not _active_collections.is_empty():
			show_empty_view.emit(EmptyType.Collection)
		else:
			show_empty_view.emit(EmptyType.Search)
	else:
		assets_loaded.emit(filtered)
		show_empty_view.emit(EmptyType.None)


func sync() -> void:
	synchronizer.sync_all()
