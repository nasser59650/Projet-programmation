extends Node2D

@export var pieton_scene = preload("res://piéton_1.tscn")
var spawn_timer = 0.0
const SPAWN_TIME = 10.0

func _process(delta):
	spawn_timer += delta
	
	if spawn_timer >= SPAWN_TIME:
		spawn_timer = 0.0
		_spawn_pieton()

func _spawn_pieton():
	var pieton = pieton_scene.instantiate()
	pieton.position = Vector2(randi() % 500, randi() % 500)
	add_child(pieton)


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("body entered: ", body.name)
	if body is CharacterBody2D:
		body.entrer_route()
