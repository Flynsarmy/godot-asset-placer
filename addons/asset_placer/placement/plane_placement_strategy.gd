extends AssetPlacementStrategy
class_name PlanePlacementStrategy

var plane_options: PlaneOptions
var last_collision_hit: AssetPlacementStrategy.CollisionHit = AssetPlacementStrategy.CollisionHit.zero()


func _init(plane_options: PlaneOptions):
	self.plane_options = plane_options


func get_placement_point(camera: Camera3D, mouse_position: Vector2) -> AssetPlacementStrategy.CollisionHit:
	var ray_origin = camera.project_ray_origin(mouse_position)
	var	ray_dir = camera.project_ray_normal(mouse_position)
	var plane = Plane(plane_options.normal, plane_options.origin)
	var intersection = plane.intersects_ray(ray_origin, ray_dir)
	if intersection:
		last_collision_hit = AssetPlacementStrategy.CollisionHit.new(intersection, plane.normal)
		return last_collision_hit
	else:
		if last_collision_hit:
			return last_collision_hit
		return AssetPlacementStrategy.CollisionHit.zero()

