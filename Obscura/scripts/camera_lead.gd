class_name CameraLead
extends CameraControllerBase

@export var cross_size = 5.0 
@export var lead_speed: float = 60.0
@export var catchup_speed: float = 7.0
@export var catchup_delay_duration: float = 0.1
@export var leash_distance: float = 3.0
@export var max_lead_distance: float = 4.0

var speed_threshold: float = 5.0  #The minimum target speed needs to make the camera "lead". 
var lock_on_duration: float = 0.2

var camera_drag: float = 1.5  # How heavy the camera feels when moving 
var turning_speed: float = 2.0  # How fast camera turns to new directions
var speed_influence: float = 0.15  # How much player speed affects camera movement
var start_move: float = 0.5  # Minimum movement needed before camera starts leading

#Simply use to classify what consider a "sharp turn" by comparing it to the changes in angle
#Larger value = more smooth
const smooth_angle_turn = deg_to_rad(80.0)  

var time_since_stopped: float = 0.0
var current_lead_direction: Vector3 = Vector3.ZERO
var current_lead_distance: float = 0.0
var previous_velocity: Vector3 = Vector3.ZERO
var sustained_speed: float = 0.0
var frame_count: int = 0
var previous_movement_direction: Vector3 = Vector3.ZERO
var time_since_direction_change: float = 0.0
var is_locked_on_target: bool = false

func _ready() -> void:
	super()
	position = target.position
	rotation_degrees = Vector3(270, 0, 0)
#The camera dynamically follow the target based on their current position and their velocity.
func _physics_process(delta: float) -> void:
	if not current:
		return
	
	frame_count += 1
	var current_height = global_position.y
	
	# Read inputs from player. 
	var input_dir = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).limit_length(1.0)

	var target_speed = target.velocity.length()

	# Slowly update the camera average speed based on the target current speed. Making it more smooth 
	if target_speed > sustained_speed:
		sustained_speed = lerp(sustained_speed, target_speed, delta * camera_drag)  
	else:
		sustained_speed = lerp(sustained_speed, target_speed, delta * (camera_drag * 2))
	
	var movement_direction = Vector2.ZERO
	
	# Calculate movement direction based on speed/input.
	if target_speed > start_move:
		movement_direction = Vector2(target.velocity.x, target.velocity.z).normalized()
	elif input_dir.length() > start_move:
		movement_direction = input_dir.normalized()
	
	#It use both velocity and input to detect movement so that as just velocity doesn't detect when there's a single movement.
	var has_movement = target_speed > start_move or input_dir.length() > start_move
	var target_direction = Vector3(movement_direction.x, 0.0, movement_direction.y)
	
	# Calculate the direction change, used to make angle turn more smooth
	var angle_change = 0.0
	if previous_movement_direction.length() > start_move and target_direction.length() > start_move:
		angle_change = previous_movement_direction.angle_to(target_direction)

	if has_movement:
		time_since_stopped = 0.0
		
		#The current target speed factor. didn't use clamb for clarity sake.
		var current_speed_factor = (target_speed - speed_threshold) / (50.0 - speed_threshold)
		if current_speed_factor < 0.0:
			current_speed_factor = 0.0
		elif current_speed_factor > 1.0:
			current_speed_factor = 1.0
		 
		#the average speed factor
		var average_speed_factor = (sustained_speed - speed_threshold) / (50.0 - speed_threshold)
		if average_speed_factor < 0.0:
			average_speed_factor = 0.0
		elif average_speed_factor > 1.0:
				average_speed_factor = 1.0
				
		#the speed factor is used to determine the optimal camera speed, it's based on both factors from above. 
		var speed_factor = (1 - speed_influence) * average_speed_factor + speed_influence * current_speed_factor
	
		# Handle high-speed movement
		if target_speed > 50.0:
			speed_factor = max(speed_factor, (target_speed - 50.0) / 250.0)

		var dynamic_lock_duration = lerp(0.05, lock_on_duration, 1.0 - speed_factor)
		var optimal_position: Vector3

		if target_speed < speed_threshold:
			# Change the lead distance based on player speed
			optimal_position = target.global_position
			current_lead_direction = Vector3.ZERO
			current_lead_distance = 0.0
			is_locked_on_target = true
			time_since_direction_change = 0.0
			
		else:
			#calculate the angle difference between the new and previous directions. 
			# If the angle is large(i.e sharp turns) then it locks on the player
			if angle_change > smooth_angle_turn:
				# Smoothly reduce lead distance to zero over lock_on_duration
				is_locked_on_target = true
				time_since_direction_change = 0.0
				lock_on_duration = dynamic_lock_duration  

				# redeuce its lead distance gradually. no jumpy/teleporting effect
				current_lead_distance = lerp(current_lead_distance, 0.0, delta * (camera_drag * 2))
			else:
				if is_locked_on_target:
					time_since_direction_change += delta
					if time_since_direction_change >= lock_on_duration:
						is_locked_on_target = false

				if is_locked_on_target:
					# Reduce lead distance smoothly
					current_lead_distance = lerp(current_lead_distance, 0.0, delta * (camera_drag * 2))
				else:
					var target_lead_distance = max_lead_distance * speed_factor
					current_lead_distance = lerp(current_lead_distance, target_lead_distance, delta * camera_drag)
					var smooth_turn = lerp(1.0, turning_speed, speed_factor)
					current_lead_direction = current_lead_direction.lerp(target_direction, delta * smooth_turn)

			# Calculate the optimal camera position based on the player's current position and velocity.
			optimal_position = target.global_position + current_lead_direction * current_lead_distance

		var move_speed = catchup_speed if is_locked_on_target else lead_speed
		global_position = global_position.lerp(optimal_position, move_speed * delta)
		
	else:
		time_since_stopped += delta
		current_lead_distance = lerp(current_lead_distance, 0.0, delta * camera_drag)
		global_position = global_position.lerp(target.global_position, catchup_speed * delta)

	global_position.y = current_height

	var to_target = target.global_position - global_position
	var distance = Vector2(to_target.x, to_target.z).length()


	if distance > leash_distance:
		# Scale the direction vector to the leash distance for adjustment
		var direction_to_target = Vector2(to_target.x, to_target.z).normalized()
		var leash_position_adjustment = direction_to_target * leash_distance
		global_position.x = target.global_position.x - leash_position_adjustment.x
		global_position.z = target.global_position.z - leash_position_adjustment.y

	# Store previous movement direction
	if target_direction.length() > start_move:
		previous_movement_direction = target_direction

func _process(delta: float) -> void:
	if not current:
		return
	if draw_camera_logic:
		draw_cross()
		
	rotation_degrees = Vector3(270, 0, 0)
	super(delta)

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
