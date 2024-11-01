class_name CameraPushZone
extends CameraControllerBase

@export var push_ratio: float = 0.6
@export var pushbox_top_left: Vector2 = Vector2(-20, 20)
@export var pushbox_bottom_right: Vector2 = Vector2(20, -20)
@export var speedup_zone_top_left: Vector2 = Vector2(-10, 10)
@export var speedup_zone_bottom_right: Vector2 = Vector2(10, -10)

func _ready() -> void:
	super()
	global_position = target.position
	rotation_degrees = Vector3(270, 0, 0)
	dist_above_target = 30.0

func _physics_process(delta: float) -> void:
	if not current:
		return

	var target_speed = target.velocity.length()
	if target_speed <= 0.1:
		return

	# Calculate target's position relative to camera
	var target_pos = target.global_position
	var relative_pos = Vector2(
		target_pos.x - global_position.x,
		target_pos.z - global_position.z
	)
	
	# speed up zone
	var in_speedup = (
		relative_pos.x >= speedup_zone_top_left.x and 
		relative_pos.x <= speedup_zone_bottom_right.x and
		relative_pos.y <= speedup_zone_top_left.y and 
		relative_pos.y >= speedup_zone_bottom_right.y
	)
	
	# If in speedup zone, do not move camera at all
	if in_speedup:
		return

	var movement = target.velocity * delta
	
	# Check edges of outer box
	var at_left = relative_pos.x <= pushbox_top_left.x
	var at_right = relative_pos.x >= pushbox_bottom_right.x
	var at_top = relative_pos.y >= pushbox_top_left.y
	var at_bottom = relative_pos.y <= pushbox_bottom_right.y
	

	if (at_left or at_right) and (at_top or at_bottom):
		global_position += movement
		
	elif at_left or at_right:
		global_position.x += movement.x
		global_position.z += movement.z * push_ratio

	elif at_top or at_bottom:
		global_position.x += movement.x * push_ratio
		global_position.z += movement.z
		
	else:
		global_position += movement * push_ratio
	
	
	global_position.y = target_pos.y + dist_above_target

func _process(_delta: float) -> void:
	if not current:
		return
		
	if draw_camera_logic:
		draw_zones()

	super(_delta)

func draw_zones() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	
	#outer pushbox
	immediate_mesh.surface_add_vertex(Vector3(pushbox_top_left.x, 0, pushbox_top_left.y))
	immediate_mesh.surface_add_vertex(Vector3(pushbox_bottom_right.x, 0, pushbox_top_left.y))
	
	immediate_mesh.surface_add_vertex(Vector3(pushbox_bottom_right.x, 0, pushbox_top_left.y))
	immediate_mesh.surface_add_vertex(Vector3(pushbox_bottom_right.x, 0, pushbox_bottom_right.y))
	
	immediate_mesh.surface_add_vertex(Vector3(pushbox_bottom_right.x, 0, pushbox_bottom_right.y))
	immediate_mesh.surface_add_vertex(Vector3(pushbox_top_left.x, 0, pushbox_bottom_right.y))
	
	immediate_mesh.surface_add_vertex(Vector3(pushbox_top_left.x, 0, pushbox_bottom_right.y))
	immediate_mesh.surface_add_vertex(Vector3(pushbox_top_left.x, 0, pushbox_top_left.y))
	
	#inner speedup zone
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_top_left.x, 0, speedup_zone_top_left.y))
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_bottom_right.x, 0, speedup_zone_top_left.y))
	
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_bottom_right.x, 0, speedup_zone_top_left.y))
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_bottom_right.x, 0, speedup_zone_bottom_right.y))
	
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_bottom_right.x, 0, speedup_zone_bottom_right.y))
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_top_left.x, 0, speedup_zone_bottom_right.y))
	
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_top_left.x, 0, speedup_zone_bottom_right.y))
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_top_left.x, 0, speedup_zone_top_left.y))
	
	immediate_mesh.surface_end()
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	await get_tree().process_frame
	mesh_instance.queue_free()
