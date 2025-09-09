@tool
extends Node3D

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	var mode: PlacementMode = AssetPlacerPresenter.instance().placement_mode
	_react_placement_mode_change(mode)
	AssetPlacerPresenter.instance().placement_mode_changed.connect(_react_placement_mode_change)

func _react_placement_mode_change(placement_mode: PlacementMode) -> void:
	if placement_mode is PlacementMode.PlanePlacement:
		show()
		_update_mes_per_plane_configuration(placement_mode.plane_options)
	else:
		hide()

func _update_mes_per_plane_configuration(plane_options: PlaneOptions) -> void:
	var normal: Vector3 = plane_options.normal.normalized()
	var forward: Vector3 = normal.cross(Vector3.UP).normalized() if (abs(normal.dot(Vector3.UP)) < 0.99) else normal.cross(Vector3.FORWARD).normalized()
	var right: Vector3 = forward.cross(normal).normalized()
	var basis: Basis = Basis(right, normal, forward)
	mesh_instance.transform.basis = basis.orthonormalized()
	mesh_instance.global_transform = Transform3D(basis.orthonormalized(), plane_options.origin)
