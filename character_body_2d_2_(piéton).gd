extends CharacterBody2D

const SPEED = 30.0
const CHANGE_DIR_TIME = 2.0
var direction = Vector2.ZERO
var timer = 0.0
var en_attente = false

func _ready():
	add_to_group("pietons")
	_new_direction()

func _physics_process(delta):
	if en_attente:
		return
	
	timer += delta
	
	if timer >= CHANGE_DIR_TIME:
		timer = 0.0
		_new_direction()
	
	velocity = direction * SPEED
	
	if direction != Vector2.ZERO:
		rotation = direction.angle() + PI/2
	
	move_and_slide()

func _new_direction():
	var directions = [
		Vector2.RIGHT,
		Vector2.LEFT,
		Vector2.UP,
		Vector2.DOWN
	]
	direction = directions[randi() % directions.size()]

func entrer_route():
	en_attente = true
	await get_tree().create_timer(2.0).timeout
	en_attente = false
