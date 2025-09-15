extends Object
class_name AssetTransformations


static func apply_transforms(node: Node3D, options: AssetPlacerOptions) -> void:
	node.global_transform = transform_rotation(node.global_transform, options)
	node.global_transform = transform_scale(node.global_transform, options)

static func transform_rotation(transform: Transform3D, options: AssetPlacerOptions) -> Transform3D:
	var rx: float = randf_range(options.min_rotation.x, options.max_rotation.x)
	transform = transform.rotated(Vector3(1, 0, 0), deg_to_rad(rx))
	var ry: float = randf_range(options.min_rotation.y, options.max_rotation.y)
	transform = transform.rotated(Vector3(0, 1, 0), deg_to_rad(ry))
	var rz: float = randf_range(options.min_rotation.z, options.max_rotation.z)
	transform = transform.rotated(Vector3(0, 0, 1), deg_to_rad(rz))
	return transform


static func transform_scale(transform: Transform3D, options: AssetPlacerOptions) -> Transform3D:
	var scale: float = randf_range(options.min_scale, options.max_scale)
	var basiz: Basis = transform.basis.orthonormalized().scaled(Vector3(scale, scale, scale))
	transform.basis = basiz
	return transform
