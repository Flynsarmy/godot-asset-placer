extends RefCounted
class_name EditorToasterCompat


static func toast(message: String) -> void:
	if EditorInterface.has_method("get_editor_toaster"):
		var toaster: EditorToaster = EditorInterface["get_editor_toaster"].call()
		toaster.push_toast(message, 0, "Asset Placer")
	else:
		push_warning(message)
