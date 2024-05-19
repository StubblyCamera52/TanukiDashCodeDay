extends CharacterBody3D


@export var MAXDEFAULTSPEED: float = 15
@export var WALKACCELERATION: float = 3.6
@export var JUMP_VELOCITY: float = 4.5
@export var DASH_DEBOUNCE: bool = false
@export var DASH_SPEED: float = 5
@export var DECELERATION: float = 0.9
@export var MOVEDECELERATION: float = 0.95
var maxspeed = MAXDEFAULTSPEED
var candivejump = true
var candive = true
var wallforce = Vector3(0,0,0)
var wallcountdown = 0

var playervelocity = Vector3.ZERO

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 200


#ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	maxspeed = MAXDEFAULTSPEED

func _physics_process(delta):
	
	playervelocity = velocity
	# Add the gravity.
	if not is_on_floor():
		if Input.is_action_pressed("PlayerInputJump") or DASH_DEBOUNCE:
			playervelocity.y -= gravity * delta
		else:
			playervelocity.y -= gravity*2 * delta
			if playervelocity.length()<maxspeed:
				maxspeed = playervelocity.length()
				print(maxspeed)
			if maxspeed<MAXDEFAULTSPEED:
				maxspeed = MAXDEFAULTSPEED
	
	if is_on_floor():
		if candive == false:
			Input.start_joy_vibration(0,0,1,0.1)
		#Input.stop_joy_vibration(0)
		candivejump = true
		candive = true
		if DASH_DEBOUNCE == true:
			DASH_DEBOUNCE = false

	# Handle jump.
	if Input.is_action_just_pressed("PlayerInputJump") and is_on_floor():
		Input.start_joy_vibration(0,0.5,0,0.1)
		playervelocity.y += JUMP_VELOCITY
	# dive jump
	if Input.is_action_just_pressed("PlayerInputJump") and candivejump and DASH_DEBOUNCE:
		Input.start_joy_vibration(0,1,0,0.1)
		if playervelocity.y>JUMP_VELOCITY:
			playervelocity.y += JUMP_VELOCITY
		else:
			playervelocity.y = JUMP_VELOCITY
		
		candivejump = false
		maxspeed = MAXDEFAULTSPEED
		candive = false
		DASH_DEBOUNCE = false
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	var input_dir = Input.get_vector("PlayerInputLeft", "PlayerInputRight", "PlayerInputForward", "PlayerInputBackward", 0.5)
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, $SpringArm3D.rotation.y).normalized()
	if direction:
		playervelocity.x += direction.x * WALKACCELERATION
		playervelocity.z += direction.z * WALKACCELERATION
		playervelocity.x *= MOVEDECELERATION
		playervelocity.z *= MOVEDECELERATION
	else:
		playervelocity.x *= DECELERATION
		playervelocity.z *= DECELERATION
	
	playervelocity += wallforce*20
	if wallcountdown > 0:
		wallcountdown-=delta
	else:
		wallforce = Vector3(0,0,0)
	
	if is_on_floor():
		wallforce = Vector3(0,0,0)
		wallcountdown = 0
	
	if playervelocity.length()>0.2:
		var look_direction = Vector2(playervelocity.x, playervelocity.z)
		$jolt.rotation.y = lerp_angle($jolt.rotation.y, 0-look_direction.angle()+PI/2, 24*delta)

	
	if abs(playervelocity.z) < 0.01:
		playervelocity.x = 0
	if abs(playervelocity.x) < 0.01:
		playervelocity.z = 0
	if Vector2(playervelocity.x, playervelocity.z).length() > maxspeed:
		playervelocity.x = (Vector2(playervelocity.x, playervelocity.z).normalized().x)*maxspeed
		playervelocity.z = (Vector2(playervelocity.x, playervelocity.z).normalized().y)*maxspeed
	
	if Input.is_action_just_pressed("PlayerInputDash") and DASH_DEBOUNCE == false and not is_on_floor() and candive:
		#Input.start_joy_vibration(0,0.02,0,0)
		candive = false
		maxspeed = 300
		print(sign(playervelocity.x))
		#playervelocity.x += sign(playervelocity.x) * DASH_SPEED
		#playervelocity.z += sign(playervelocity.z) * DASH_SPEED
		playervelocity.x *= DASH_SPEED
		playervelocity.z *= DASH_SPEED
		if playervelocity.y<0:
			playervelocity.y += 3
		else:
			playervelocity.y = 3
		DASH_DEBOUNCE = true
		#maxspeed=300
	velocity = playervelocity
	
	if is_on_wall_only():
		if Vector2(get_wall_normal().x, get_wall_normal().z).length() > 0.999:
			#velocity = Vector3.ZERO
			if Input.is_action_just_pressed("PlayerInputJump"):
				Input.start_joy_vibration(0,1,0,0.1)
				velocity = 200*Vector3(get_wall_normal().x,0,get_wall_normal().z)+Vector3(0,JUMP_VELOCITY,0)
				wallforce = get_wall_normal()
				wallcountdown = 0.3
				candive = true
				DASH_DEBOUNCE = false
	
	move_and_slide()
	
	if is_on_floor():
		if playervelocity.length()<2:
			$jolt/AnimationPlayer.current_animation = "Idle"
			$jolt/AnimationPlayer.speed_scale = 1
		elif playervelocity.length()<50:
			$jolt/AnimationPlayer.current_animation = "Walk"
			$jolt/AnimationPlayer.speed_scale = playervelocity.length()/30
		elif playervelocity.length()<MAXDEFAULTSPEED+10:
			$jolt/AnimationPlayer.current_animation = "Jog"
			$jolt/AnimationPlayer.speed_scale = playervelocity.length()/30
		else:
			$jolt/AnimationPlayer.current_animation = "Dash"
			$jolt/AnimationPlayer.speed_scale = playervelocity.length()/30
	else:
		if DASH_DEBOUNCE:
			$jolt/AnimationPlayer.current_animation = "Dive"
			$jolt/AnimationPlayer.speed_scale = playervelocity.length()/30
		else:
				if is_on_wall_only():
					$jolt/AnimationPlayer.current_animation = "WallCling"
					$jolt.rotation.y = atan2(get_wall_normal().x,get_wall_normal().z)-PI
				else:
					$jolt/AnimationPlayer.speed_scale = abs(playervelocity.y)/30
					if playervelocity.y > 0:
						if candive:
							$jolt/AnimationPlayer.current_animation = "Jump"
						else:
							$jolt/AnimationPlayer.current_animation = "DiveJump"
					else:
						$jolt/AnimationPlayer.current_animation = "Fall"
	if DASH_DEBOUNCE:
		$jolt.rotation.x = 0-playervelocity.y/150
	else:
		$jolt.rotation.x = 0
		
func _unhandled_input(event):
	if Input.is_action_just_pressed("reset"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene_to_file("res://menu.tscn")
	
