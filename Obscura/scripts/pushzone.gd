class_name CameraPushZone
extends CameraControllerBase

@export var push_ratio: float = 0.5

#Box dimensions 
@export var box_width: float = 30.0
@export var box_height: float = 30.0
@export var inner_width: float = 10.0
@export var inner_height: float = 10.0

@export var pushbox_top_left: Vector2
@export var pushbox_bottom_right: Vector2
@export var speedup_zone_top_left: Vector2
@export var speedup_zone_bottom_right: Vector2

var frame_position: Vector3  

#Basically does nothing, Not used currently in the logic for determining camera speed. The edges is still based on boxes height/width. 
var use_vector_method := true  

func _ready() -> void:
	super()
	frame_position = target.position
	global_position = frame_position
	rotation_degrees = Vector3(270, 0, 0)
	dist_above_target = 30.0
	
	
	use_vector_method = pushbox_bottom_right != Vector2.ZERO
	
	#Calculate where the corners would based on width/height values. But it's not used so it doesn't changed the box sizes.
	if use_vector_method:
		box_width = abs(pushbox_bottom_right.x - pushbox_top_left.x)
		box_height = abs(pushbox_bottom_right.y - pushbox_top_left.y)
		inner_width = abs(speedup_zone_bottom_right.x - speedup_zone_top_left.x)
		inner_height = abs(speedup_zone_bottom_right.y - speedup_zone_top_left.y)

func _physics_process(delta: float) -> void:
	if !current:
		return
	
	var tpos = target.global_position
	var velocity = target.velocity
	
	var relative_pos = Vector2(tpos.x - global_position.x, tpos.z - global_position.z)
	

	var in_speedup_zone = (abs(relative_pos.x) <= inner_width / 2.0 and abs(relative_pos.y) <= inner_height / 2.0)
	
	# Edge detection  based on magnitude of relative position
	var box_half_width = box_width / 2.0
	var box_half_height = box_height / 2.0
	
	var touch_left = relative_pos.x <= -box_half_width
	var touch_right = relative_pos.x >= box_half_width
	var touch_top = relative_pos.y <= -box_half_height
	var touch_bottom = relative_pos.y >= box_half_height
	
	var in_corner = (touch_left and touch_top) or (touch_right and touch_top) or (touch_left and touch_bottom) or (touch_right and touch_bottom)
	
	var move_speed = Vector3.ZERO
	
	if velocity.length() > 0.1:
		if in_speedup_zone:
			move_speed = Vector3.ZERO
		elif in_corner:
			move_speed = velocity
		elif touch_left or touch_right:
			move_speed.x = velocity.x
			move_speed.z = velocity.z * push_ratio
		elif touch_top or touch_bottom:
			move_speed.x = velocity.x * push_ratio
			move_speed.z = velocity.z
		else:
			move_speed = velocity * push_ratio
			
		# Apply movement
		global_position += move_speed * delta
		
		var correction = Vector3.ZERO
		if abs(relative_pos.x) > box_half_width:
			var excess = abs(relative_pos.x) - box_half_width
			correction.x = excess * sign(relative_pos.x) * 0.1
		if abs(relative_pos.y) > box_half_height:
			var excess = abs(relative_pos.y) - box_half_height
			correction.z = excess * sign(relative_pos.y) * 0.1
			
		global_position += correction
	
	
	global_position.y = tpos.y + dist_above_target
	frame_position = global_position
	
	#Not used and no effect in game.
	if use_vector_method:
		var half_box = Vector2(box_width/2, box_height/2)
		var half_inner = Vector2(inner_width/2, inner_height/2)
		pushbox_top_left = Vector2(global_position.x - half_box.x, global_position.z - half_box.y)
		pushbox_bottom_right = Vector2(global_position.x + half_box.x, global_position.z + half_box.y)
		speedup_zone_top_left = Vector2(global_position.x - half_inner.x, global_position.z - half_inner.y)
		speedup_zone_bottom_right = Vector2(global_position.x + half_inner.x, global_position.z + half_inner.y)


func _process(_delta: float) -> void:
	if !current:
		return
	if draw_camera_logic:
		draw_boxes()

	rotation_degrees = Vector3(270, 0, 0)
	super(_delta)

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
