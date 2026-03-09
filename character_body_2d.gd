extends CharacterBody2D

var dezoom = false
const SPEED = 100.0
const BOOST_SPEED = 200.0

func _process(_delta):
	if Input.is_action_pressed("zoom_out"):
		$Camera2D.zoom = Vector2(0.5, 0.5)
	else:
		$Camera2D.zoom = Vector2(2, 2)

func _physics_process(_delta):
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	
	var current_speed = BOOST_SPEED if Input.is_action_pressed("boost") else SPEED
	velocity = direction * current_speed
	
	if direction != Vector2.ZERO:
		rotation = direction.angle() + PI/2
	
	move_and_slide()
