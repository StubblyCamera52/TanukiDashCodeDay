extends SpringArm3D

@export var mouse_sensitivity: float = 0.005
@export var controller_sensitivity: float = 0.1
# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation.x -= event.relative.y * mouse_sensitivity
		rotation.x = clamp(rotation.x,-0.5*PI, PI*0.5)
		rotation.y -= event.relative.x * mouse_sensitivity
		rotation.y = wrapf(rotation.y, 0.0, PI*2)
			
	if Input.is_action_just_pressed("Unlock Camera"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("Click"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func _process(delta):
	rotation.x -= Input.get_action_strength("PlayerCameraRotateUp") * controller_sensitivity
	rotation.x += Input.get_action_strength("PlayerCameraRotateDown") * controller_sensitivity
	rotation.y += Input.get_action_strength("PlayerCameraRotateLeft") * controller_sensitivity
	rotation.y -= Input.get_action_strength("PlayerCameraRotateRight") * controller_sensitivity
	rotation.y = wrapf(rotation.y, 0.0, PI*2)
	rotation.x = clamp(rotation.x,-0.5*PI, PI*0.1)

