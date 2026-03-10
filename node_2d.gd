extends Node2D

@export var pieton_scene = preload("res://piéton_1.tscn")
var spawn_timer = 0.0
const SPAWN_TIME = 3.0

#Spawn 50 pietons
func _init_pieton():
	for i in range(50):
		_spawn_pieton()

func _process(delta):
	spawn_timer += delta
	
	if spawn_timer >= SPAWN_TIME:
		spawn_timer = 0.0
		_spawn_pieton()

func _spawn_pieton():
	var pieton = pieton_scene.instantiate()
	pieton.position = Vector2(-2280 + randi() % 3262, -2088 + randi() % 3275)
	add_child(pieton)


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("body entered: ", body.name)
	if body is CharacterBody2D:
		body.entrer_route()
