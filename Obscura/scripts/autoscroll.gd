class_name CameraScroll
extends CameraControllerBase

@export var box_width:float = 10.0
@export var box_height:float = 10.0
@export var autoscroll_speed:Vector3 = Vector3(10.0, 0.0, 0.0)  # auto-scrolling

var frame_position: Vector3

func _ready() -> void:
	super()
	frame_position = target.position
	rotation_degrees = Vector3(270, 0, 0)  

func _process(delta: float) -> void:
	if !current:
		return
		
	if draw_camera_logic:
		draw_logic()
	
	# Move at a constant speed based on autoscroll speed
	frame_position += autoscroll_speed * delta
	var tpos = target.global_position
	
	# Check if player is behind left edge, if yes then push
	var left_edge = frame_position.x - box_width / 2.0
	if tpos.x < left_edge:
		target.global_position.x = left_edge
	
	#lock on player within box bounds
	var right_edge = frame_position.x + box_width / 2.0      
	var top_edge = frame_position.z - box_height / 2.0
	var bottom_edge = frame_position.z + box_height / 2.0
	
	target.global_position.x = clamp(target.global_position.x, left_edge, right_edge)
	target.global_position.z = clamp(target.global_position.z, top_edge, bottom_edge)
	
	global_position = frame_position
	rotation_degrees = Vector3(270, 0, 0)	
	super(delta)



func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	var left:float = -box_width / 2
	var right:float = box_width / 2
	var top:float = -box_height / 2
	var bottom:float = box_height / 2
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
	immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
	immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
	immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
	
	immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
	immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
	immediate_mesh.surface_end()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	await get_tree().process_frame
	mesh_instance.queue_free()
	
	
	
