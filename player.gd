extends CharacterBody3D
class_name Player

# repurposed from lightsource
# thank you past me

const sensitivity = -0.005
const speed = 6
const gravity = 20
const jumpspeed = 16
const coyotetime = 0.25

var panning: Vector2
var timesinceground = 0
var justjumped = false

func _ready():
	Global.player = self
	$Camera3D.rotation.y = randf() * TAU
	panning.x = $Camera3D.rotation.y

func _process(delta: float):
	movementinput()
	pancamera(delta)

func movementinput():
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var direction = Vector2.ZERO
		if Input.is_action_pressed("forward"):
			direction += Vector2.UP
		if Input.is_action_pressed("back"):
			direction += Vector2.DOWN
		if Input.is_action_pressed("left"):
			direction += Vector2.LEFT
		if Input.is_action_pressed("right"):
			direction += Vector2.RIGHT
		direction = direction.normalized().rotated(-$Camera3D.rotation.y) * speed
		velocity = Vector3(direction.x, velocity.y, direction.y)
		if Input.is_action_just_pressed("jump"):
			if timesinceground <= coyotetime and not justjumped:
				velocity.y = jumpspeed
				justjumped = true
			#else:
				#velocity.y = -32

func pancamera(delta: float):
	for axis in 2:
		var correction = 1 - 2 ** (delta * -32)
		var spin = (panning[axis] - $Camera3D.rotation[1 - axis]) * correction
		$Camera3D.rotation[1 - axis] += spin
		panning[axis] -= spin
	$Camera3D.rotation.x = clamp($Camera3D.rotation.x, -PI / 2, PI / 2)

func _physics_process(delta: float):
	velocity.y -= gravity * delta
	#var testform = transform
	#testform.origin.y += 1.001
	#var testvel = Vector3(velocity.x, 0, velocity.z).normalized()
	#var stepping = test_move(transform, testvel) and not test_move(testform, testvel)
	#if stepping and is_on_floor():
		#velocity.y += 8
	velocity.y = max(velocity.y, -12)
	move_and_slide()
	timesinceground += delta
	if is_on_floor():
		timesinceground = 0
		justjumped = false

func _input(event: InputEvent):
	if event.is_action_pressed("click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			panning += event.relative * sensitivity
