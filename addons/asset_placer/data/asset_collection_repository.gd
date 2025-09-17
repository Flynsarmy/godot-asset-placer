extends RefCounted
class_name AssetCollectionRepository

var _data_source: AssetLibraryDataSource

signal collections_changed

func _init() -> void:
	_data_source = AssetLibraryDataSource.new()


func get_collections() -> Array[AssetCollection]:
	return _data_source.get_library().collections


func add_collection(collection: AssetCollection) -> void:
	var lib = _data_source.get_library()
	lib.collections.append(collection)
	_data_source.save_libray(lib)
	collections_changed.emit()

func update_collection(old_name: String, new_collection: AssetCollection) -> void:
	var lib: AssetLibrary = _data_source.get_library()
	for i in lib.collections.size():
		var collection: AssetCollection = lib.collections[i]
		if collection.name == old_name:
			lib.collections[i] = new_collection
			_data_source.save_libray(lib)
			collections_changed.emit()
			break

func delete_collection(name: String) -> void:
	var lib: AssetLibrary = _data_source.get_library()
	var new_collections: Array = lib.collections.filter(func(c): return c.name != name)
	lib.collections = new_collections
	_data_source.save_libray(lib)
	collections_changed.emit()
