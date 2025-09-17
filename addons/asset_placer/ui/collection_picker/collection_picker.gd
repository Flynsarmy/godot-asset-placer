@tool
extends PopupMenu
class_name CollectionPicker

signal collection_selected(collection: AssetCollection, selected: bool)

var presenter: AssetCollectionsPresenter = AssetCollectionsPresenter.new()
var pre_selected: Array[AssetCollection] = []

func _ready() -> void:
	hide_on_checkable_item_selection = false
	presenter.show_collections.connect(show_collections)
	presenter.ready()


func show_collections(collections: Array[AssetCollection]) -> void:
	if collections.size() == 0:
		add_check_item("All")
		set_item_checked(0, true)
		set_item_icon(0, make_circle_icon(16, Color.WHITE))
		set_item_disabled(0, true)

	for i in collections.size():
		var collection_name: String = collections[i].name
		var selected: bool = pre_selected.any(func(c): return c.name == collection_name)
		add_check_item(collection_name)
		set_item_checked(i, selected)
		set_item_icon(i, make_circle_icon(16, collections[i].backgroundColor))

	index_pressed.connect(func(index):
		toggle_item_checked(index)
		if index < collections.size():
			collection_selected.emit(collections[index], is_item_checked(index))
	)

static func make_circle_icon(radius: int, color: Color) -> Texture2D:
	var size: int = radius * 2
	var img: Image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))  # Transparent background

	for y in size:
		for x in size:
			var dist: float = Vector2(x, y).distance_to(Vector2(radius, radius))
			if dist <= radius:
				img.set_pixel(x, y, color)

	img.generate_mipmaps()

	var tex: ImageTexture = ImageTexture.create_from_image(img)
	return tex
