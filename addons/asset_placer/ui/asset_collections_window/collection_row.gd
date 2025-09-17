@tool
extends HBoxContainer

signal collection_changed(old_name: String, collection: AssetCollection)

@onready var color_button: ColorPickerButton = %ColorButton
@onready var rename_field: LineEdit = %RenameField
@onready var label_button: Button = %LabelButton
@onready var label: Label = %Label
@onready var asset_count_label: RichTextLabel = %AssetCountLabel
@onready var remove_button: Button = %RemoveButton

var collection: AssetCollection :
	set(value):
		collection = value
		_on_set_collection()

func _ready() -> void:
	rename_field.hide()
	rename_field.text_submitted.connect(_on_rename_text_submitted)
	rename_field.editing_toggled.connect(_on_rename_editing_toggled)
	rename_field.gui_input.connect(_on_rename_gui_input)

	label_button.pressed.connect(func ():
		if not collection:
			return

		label_button.hide()
		rename_field.text = label.text
		rename_field.show()
		rename_field.grab_focus()
		rename_field.select_all()
	)

	color_button.popup_closed.connect(func():
		collection.backgroundColor = color_button.color
		collection_changed.emit(collection.name, collection)
	)

func set_asset_count(count: int) -> void:
	asset_count_label.text = "[i]%s assets[/i]" % count

func _on_set_collection() -> void:
	label.text = collection.name
	color_button.color = collection.backgroundColor

func _on_rename_text_submitted(new_text: String) -> void:
	if new_text.is_empty():
		new_text = collection.name

	var old_name: String = collection.name

	collection.name = new_text
	label.text = new_text
	collection_changed.emit(old_name, collection)

func _on_rename_editing_toggled(toggled_on: bool) -> void:
	if not toggled_on:
		rename_field.hide()
		label_button.show()

func _on_rename_gui_input(event: InputEvent) -> void:
	if event.is_pressed() and event is InputEventKey and event.keycode == Key.KEY_ESCAPE:
		rename_field.editing_toggled.emit(false)
