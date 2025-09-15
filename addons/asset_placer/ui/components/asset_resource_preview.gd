@tool
extends Button
class_name  AssetResourcePreview

signal left_clicked(asset: AssetResource)
signal right_clicked(asset: AssetResource)
signal asset_changed(asset: AssetResource)

@onready var label: Label = %Label
@onready var asset_thumbnail: AssetThumbnail = %AssetThumbnail
@onready var rename_field: LineEdit = %RenameField

var resource: AssetResource

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	toggled.connect(func(_a): left_clicked.emit(resource))
	rename_field.hide()

	rename_field.text_submitted.connect(_on_rename_text_submitted)
	rename_field.editing_toggled.connect(_on_rename_editing_toggled)
	rename_field.gui_input.connect(_on_rename_gui_input)

func set_asset(asset: AssetResource) -> void:
	resource = asset
	label.text = asset.name
	asset_thumbnail.set_resource(asset)

	tooltip_text = resource._scene.resource_path

func start_rename() -> void:
	if not resource:
		return

	label.hide()
	rename_field.text = label.text
	rename_field.show()
	rename_field.grab_focus()
	rename_field.select_all()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			right_clicked.emit(resource)

func _on_rename_text_submitted(new_text: String) -> void:
	if new_text.is_empty():
		new_text = resource._scene.resource_path.get_file().get_basename()
	resource.name = new_text
	label.text = new_text
	asset_changed.emit(resource)

func _on_rename_editing_toggled(toggled_on: bool) -> void:
	if not toggled_on:
		rename_field.hide()
		label.show()

func _on_rename_gui_input(event: InputEvent) -> void:
	if event.is_pressed() and event is InputEventKey and event.keycode == Key.KEY_ESCAPE:
		rename_field.editing_toggled.emit(false)
