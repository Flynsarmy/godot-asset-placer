@tool
extends Window

const COLLECTION_ROW: PackedScene = preload("uid://7q08js5mtpmm")


@onready var presenter: AssetCollectionsPresenter = AssetCollectionsPresenter.new()
@onready var name_text_field: LineEdit = %NameTextField
@onready var color_picker_button: ColorPickerButton= %ColorPickerButton
@onready var add_button: Button = %AddButton
@onready var collections_list: VBoxContainer = %CollectionsList


func _ready() -> void:
	presenter.enable_create_button.connect(func(enabled):
		add_button.disabled = !enabled
		show_collections(presenter._repository.get_collections())
	)
	presenter.set_color(color_picker_button.color)
	presenter.clear_text_field.connect(name_text_field.clear)
	#presenter.show_collections.connect(show_collections)
	presenter.ready()
	show_collections(presenter._repository.get_collections())

	add_button.pressed.connect(presenter.create_collection)
	name_text_field.text_changed.connect(presenter.set_name)
	color_picker_button.color_changed.connect(presenter.set_color)

func _notification(what : int) -> void:
	if (what == NOTIFICATION_WM_CLOSE_REQUEST):
		queue_free()

func show_collections(items: Array[AssetCollection]) -> void:
	for child in collections_list.get_children():
		child.queue_free()

	for item in items:
		var collection_row: HBoxContainer = COLLECTION_ROW.instantiate()
		collections_list.add_child(collection_row)
		collection_row.collection = item
		collection_row.remove_button.pressed.connect(func ():
			presenter.delete_collection(item)
			show_collections(presenter._repository.get_collections())
		)
		collection_row.collection_changed.connect(func (old_name: String, collection: AssetCollection):
			presenter.update_collection(old_name, collection)
		)
		collection_row.set_asset_count(presenter.get_collection_assets(item).size())
