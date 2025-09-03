@tool
extends TextureRect
class_name AssetThumbnail

const no_preview_tex: CompressedTexture2D = preload("res://addons/asset_placer/ui/components/File.png")
# How long between preview refreshes, in milliseconds.
const REFRESH_TIME: int = 1000

var resource: AssetResource
var previewer: EditorResourcePreview
var time_since_last_check: int = 0

func set_resource(resource: AssetResource) -> void:
	if not previewer:
		previewer = EditorInterface.get_resource_previewer()
		previewer.preview_invalidated.connect(_on_preview_invalidated)
	self.resource = resource
	preview_resource()

func _on_preview_invalidated(path: String) -> void:
	if resource and resource.scene.resource_path == path:
		preview_resource()

func preview_resource() -> void:
	if resource:
		previewer.queue_edited_resource_preview(resource.scene, self, "_on_preview_generated", resource)

func _process(delta: float) -> void:
	if Engine.is_editor_hint() and resource:
		time_since_last_check += int(delta * 1000)
		if time_since_last_check < REFRESH_TIME:
			return
		time_since_last_check = 0

		previewer.check_for_invalidation(resource.scene.resource_path)

func _on_preview_generated(path: String, generated_texture: Texture2D,  thumbnail: Texture2D, data: AssetResource) -> void:
	if generated_texture == null:
		texture = no_preview_tex
	else:
		texture = generated_texture
