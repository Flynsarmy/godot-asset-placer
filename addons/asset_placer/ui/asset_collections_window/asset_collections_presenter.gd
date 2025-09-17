extends RefCounted
class_name AssetCollectionsPresenter

var _repository: AssetCollectionRepository
var _assets_repository: AssetsRepository

var _new_collection_name: String = ""
var _new_collection_color: Color

signal show_collections(items: Array[AssetCollection])
signal enable_create_button(enable: bool)
signal clear_text_field()


func _init() -> void:
	_repository = AssetCollectionRepository.new()
	_repository.collections_changed.connect(_load_collections)
	_assets_repository = AssetsRepository.instance()

func ready() -> void:
	_load_collections()
	_update_state_new_collection_state()

func set_color(color: Color) -> void:
	_new_collection_color = color
	_update_state_new_collection_state()

func set_name(name: String) -> void:
	_new_collection_name = name
	_update_state_new_collection_state()

func create_collection() -> void:
	var collection: AssetCollection = AssetCollection.new(_new_collection_name, _new_collection_color)
	_repository.add_collection(collection)
	clear_text_field.emit()
	enable_create_button.emit(false)

func _update_state_new_collection_state() -> void:
	var valid_name: bool = !_new_collection_name.is_empty()
	var valid_color: bool = _new_collection_color != null
	enable_create_button.emit(valid_color && valid_name)

func _load_collections() -> void:
	var collections: Array[AssetCollection] = _repository.get_collections()
	show_collections.emit(collections)

func update_collection(old_name: String, new_collection: AssetCollection) -> void:
	_repository.update_collection(old_name, new_collection)

func get_collection_assets(collection: AssetCollection) -> Array[AssetResource]:
	return _assets_repository.get_all_assets().filter(func (asset: AssetResource):
		return asset.belongs_to_collection(collection)
	)

func collection_name_exists(name: String) -> bool:
	return _repository.get_collections().any(func (collection: AssetCollection):
		return collection.name == name
	)

func delete_collection(collection: AssetCollection) -> void:
	_repository.delete_collection(collection.name)
	for asset in _assets_repository.get_all_assets():
		var updated_tags: Array[String] = asset.tags.filter(func(f): return f != collection.name)
		if updated_tags != asset.tags:
			asset.tags = updated_tags
			_assets_repository.update(asset)
