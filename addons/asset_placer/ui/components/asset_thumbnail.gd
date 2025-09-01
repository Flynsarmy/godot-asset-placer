@tool
extends TextureRect
class_name AssetThumbnail

const no_preview_tex: CompressedTexture2D = preload("res://addons/asset_placer/ui/components/File.png")

var resource: AssetResource
var previewer: EditorResourcePreview
var last_time_modified: int = 0


func set_resource(resource: AssetResource) -> void:
	resource = resource
	preview_resource(resource)

func preview_resource(resource: AssetResource) -> void:
	if Engine.is_editor_hint() and resource and resource.scene:
		last_time_modified = FileAccess.get_modified_time(resource.scene.resource_path)
		previewer = EditorInterface.get_resource_previewer()
		previewer.queue_edited_resource_preview(resource.scene, self, "_on_preview_generated", resource)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint() and resource and resource.scene:
		var new_time_modified: int = FileAccess.get_modified_time(resource.scene.resource_path)
		if new_time_modified != last_time_modified:
			preview_resource(resource)

func _on_preview_generated(path: String, generated_texture: Texture2D,  thumbnail: Texture2D, data: AssetResource) -> void:
	if generated_texture == null:
		texture = no_preview_tex
	else:
		texture = generated_texture
