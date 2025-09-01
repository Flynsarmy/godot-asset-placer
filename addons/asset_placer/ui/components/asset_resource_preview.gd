@tool
extends Button
class_name  AssetResourcePreview

signal left_clicked(asset: AssetResource)
signal right_clicked(asset: AssetResource)

@onready var label: Label = %Label
@onready var asset_thumbnail: AssetThumbnail = %AssetThumbnail

var resource: AssetResource

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	toggled.connect(func(_a): left_clicked.emit(resource))

func set_asset(asset: AssetResource) -> void:
	resource = asset
	label.text = asset.name
	asset_thumbnail.set_resource(asset)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			right_clicked.emit(resource)
