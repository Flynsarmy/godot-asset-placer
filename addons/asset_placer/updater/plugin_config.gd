extends RefCounted
class_name PluginConfiguration

var version: Version

func _init(file_path: String) -> void:
	var config: ConfigFile = ConfigFile.new()
	config.load(file_path)
	version = Version.new(config.get_value("plugin", "version", "unknown"))
