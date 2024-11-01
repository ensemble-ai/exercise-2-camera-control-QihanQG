class_name CameraTrail
extends CameraControllerBase

@export var cross_size = 5.0 
@export var follow_speed: float = 2
@export var catchup_speed: float = 1.0
@export var leash_distance: float = 6.0

var target_previous_pos: Vector3 
var current_velocity: Vector3 = Vector3.ZERO
var smoothing_factor: float = 0.1
var frame_count: int = 0

func _ready() -> void:
	super()
	global_position = target.global_position
	target_previous_pos = target.global_position
	rotation_degrees = Vector3(270, 0, 0)

func _process(delta: float) -> void:
	if !current:
		return
	if draw_camera_logic:
		draw_cross()
	#rotation_degrees = Vector3(270, 0, 0)
	super(delta)

func _physics_process(delta: float) -> void:
	if !current:
		return

	frame_count += 1
	var tpos = target.global_position
	var cpos = global_position
	var current_height = global_position.y
	
	# Smoothly interpolate towards the target position (only X and Z)
	var optimal_position = Vector3(
		lerp(cpos.x, tpos.x, follow_speed * delta),
		current_height,  # Keep current height
		lerp(cpos.z, tpos.z, follow_speed * delta)
	)
	
	# Enforce leash distance (only in X/Z plane)
	var target_distance = Vector2(tpos.x - optimal_position.x, tpos.z - optimal_position.z)
	var distance = target_distance.length()
	
	if distance > leash_distance:
		target_distance = target_distance.normalized() * leash_distance
		optimal_position.x = tpos.x - target_distance.x
		optimal_position.z = tpos.z - target_distance.y
	
	# Apply smoothed movement (keeping Y unchanged)
	var old_pos = global_position
	global_position = optimal_position
	


func draw_cross() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := StandardMaterial3D.new()
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(Vector3(0.0, 0.0, -cross_size))
	immediate_mesh.surface_add_vertex(Vector3(0.0, 0.0, cross_size))
	immediate_mesh.surface_add_vertex(Vector3(-cross_size, 0.0, 0.0))
	immediate_mesh.surface_add_vertex(Vector3(cross_size, 0.0, 0.0))
	immediate_mesh.surface_end()
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	await get_tree().process_frame
	mesh_instance.queue_free()
