class_name CameraPushZone
extends CameraControllerBase

@export var push_ratio: float = 0.5

# Outer box dimensions
@export var box_width: float = 30.0
@export var box_height: float = 30.0

# Inner box dimensions
@export var inner_width: float = 10.0
@export var inner_height: float = 10.0

# Threshold for detecting corner proximity
@export var corner_threshold: float = 0.5  # Adjust for corner accuracy

var frame_position: Vector3  # Holds the initial target position

# Tracking variables for edge and corner states
var was_touching_left = false
var was_touching_right = false
var was_touching_top = false
var was_touching_bottom = false
var was_touching_inner_left = false
var was_touching_inner_right = false
var was_touching_inner_top = false
var was_touching_inner_bottom = false
var was_touching_top_left_corner = false
var was_touching_top_right_corner = false
var was_touching_bottom_left_corner = false
var was_touching_bottom_right_corner = false

# Zone state tracking
var was_in_speedup_zone = false
var was_in_push_zone = false

func _ready() -> void:
	super()
	frame_position = target.position
	rotation_degrees = Vector3(270, 0, 0)
	dist_above_target = 30.0

func _process(delta: float) -> void:
	if not current:
		return

	var tpos = target.global_position

	# Define edge positions based on frame_position and box dimensions
	var left_edge = frame_position.x - box_width / 2.0
	var right_edge = frame_position.x + box_width / 2.0
	var top_edge = frame_position.z - box_height / 2.0
	var bottom_edge = frame_position.z + box_height / 2.0

	var inner_left_edge = frame_position.x - inner_width / 2.0
	var inner_right_edge = frame_position.x + inner_width / 2.0
	var inner_top_edge = frame_position.z - inner_height / 2.0
	var inner_bottom_edge = frame_position.z + inner_height / 2.0

	# Edge detection and state change tracking
	var touching_left = tpos.x < left_edge
	if touching_left and not was_touching_left:
		print("=== TOUCHING LEFT EDGE ===")
	was_touching_left = touching_left

	var touching_right = tpos.x > right_edge
	if touching_right and not was_touching_right:
		print("=== TOUCHING RIGHT EDGE ===")
	was_touching_right = touching_right

	var touching_top = tpos.z < top_edge
	if touching_top and not was_touching_top:
		print("=== TOUCHING TOP EDGE ===")
	was_touching_top = touching_top

	var touching_bottom = tpos.z > bottom_edge
	if touching_bottom and not was_touching_bottom:
		print("=== TOUCHING BOTTOM EDGE ===")
	was_touching_bottom = touching_bottom

	# Inner box edge detection and state change tracking
	var touching_inner_left = tpos.x < inner_left_edge
	if touching_inner_left and not was_touching_inner_left:
		print("=== TOUCHING INNER LEFT EDGE ===")
	was_touching_inner_left = touching_inner_left

	var touching_inner_right = tpos.x > inner_right_edge
	if touching_inner_right and not was_touching_inner_right:
		print("=== TOUCHING INNER RIGHT EDGE ===")
	was_touching_inner_right = touching_inner_right

	var touching_inner_top = tpos.z < inner_top_edge
	if touching_inner_top and not was_touching_inner_top:
		print("=== TOUCHING INNER TOP EDGE ===")
	was_touching_inner_top = touching_inner_top

	var touching_inner_bottom = tpos.z > inner_bottom_edge
	if touching_inner_bottom and not was_touching_inner_bottom:
		print("=== TOUCHING INNER BOTTOM EDGE ===")
	was_touching_inner_bottom = touching_inner_bottom

	# Corner detection with threshold and state change tracking
	var touching_top_left_corner = (abs(tpos.x - left_edge) < corner_threshold) and (abs(tpos.z - top_edge) < corner_threshold)
	if touching_top_left_corner and not was_touching_top_left_corner:
		print("=== TOUCHING TOP LEFT CORNER ===")
	was_touching_top_left_corner = touching_top_left_corner

	var touching_top_right_corner = (abs(tpos.x - right_edge) < corner_threshold) and (abs(tpos.z - top_edge) < corner_threshold)
	if touching_top_right_corner and not was_touching_top_right_corner:
		print("=== TOUCHING TOP RIGHT CORNER ===")
	was_touching_top_right_corner = touching_top_right_corner

	var touching_bottom_left_corner = (abs(tpos.x - left_edge) < corner_threshold) and (abs(tpos.z - bottom_edge) < corner_threshold)
	if touching_bottom_left_corner and not was_touching_bottom_left_corner:
		print("=== TOUCHING BOTTOM LEFT CORNER ===")
	was_touching_bottom_left_corner = touching_bottom_left_corner

	var touching_bottom_right_corner = (abs(tpos.x - right_edge) < corner_threshold) and (abs(tpos.z - bottom_edge) < corner_threshold)
	if touching_bottom_right_corner and not was_touching_bottom_right_corner:
		print("=== TOUCHING BOTTOM RIGHT CORNER ===")
	was_touching_bottom_right_corner = touching_bottom_right_corner

	# Zone detection (restored)
	var relative_pos = Vector2(tpos.x - frame_position.x, tpos.z - frame_position.z)
	
	var in_speedup_zone = (
		abs(relative_pos.x) <= inner_width / 2.0 and
		abs(relative_pos.y) <= inner_height / 2.0
	)
	
	var in_push_zone = (
		abs(relative_pos.x) <= box_width / 2.0 and
		abs(relative_pos.y) <= box_height / 2.0 and
		not in_speedup_zone
	)

	# Print only when entering zones
	if in_speedup_zone and not was_in_speedup_zone:
		print("=== ENTERED SPEEDUP ZONE ===")
	was_in_speedup_zone = in_speedup_zone

	if in_push_zone and not was_in_push_zone:
		print("=== ENTERED PUSH ZONE ===")
	was_in_push_zone = in_push_zone

	if draw_camera_logic:
		draw_boxes()
	
	rotation_degrees = Vector3(270, 0, 0)
	super(delta)

func draw_boxes() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	
	# Draw outer box
	var outer_left = -box_width / 2
	var outer_right = box_width / 2
	var outer_top = -box_height / 2
	var outer_bottom = box_height / 2
	
	immediate_mesh.surface_add_vertex(Vector3(outer_right, 0, outer_top))
	immediate_mesh.surface_add_vertex(Vector3(outer_right, 0, outer_bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(outer_right, 0, outer_bottom))
	immediate_mesh.surface_add_vertex(Vector3(outer_left, 0, outer_bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(outer_left, 0, outer_bottom))
	immediate_mesh.surface_add_vertex(Vector3(outer_left, 0, outer_top))
	
	immediate_mesh.surface_add_vertex(Vector3(outer_left, 0, outer_top))
	immediate_mesh.surface_add_vertex(Vector3(outer_right, 0, outer_top))
	
	# Draw inner box
	var inner_left = -inner_width / 2
	var inner_right = inner_width / 2
	var inner_top = -inner_height / 2
	var inner_bottom = inner_height / 2
	
	immediate_mesh.surface_add_vertex(Vector3(inner_right, 0, inner_top))
	immediate_mesh.surface_add_vertex(Vector3(inner_right, 0, inner_bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(inner_right, 0, inner_bottom))
	immediate_mesh.surface_add_vertex(Vector3(inner_left, 0, inner_bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(inner_left, 0, inner_bottom))
	immediate_mesh.surface_add_vertex(Vector3(inner_left, 0, inner_top))
	
	immediate_mesh.surface_add_vertex(Vector3(inner_left, 0, inner_top))
	immediate_mesh.surface_add_vertex(Vector3(inner_right, 0, inner_top))
	
	immediate_mesh.surface_end()
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	await get_tree().process_frame
	mesh_instance.queue_free()
