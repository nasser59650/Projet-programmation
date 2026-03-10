extends Node2D

@export var pieton_scene = preload("res://piéton_1.tscn")
@export var voiture1_scene = preload("res://voiture_principale.tscn")
@export var voiture2_scene = preload("res://voiture_principale2.tscn")

var spawn_timer = 0.0
const SPAWN_TIME = 3.0
var voiture_actuelle = null

func _ready():
	for i in range(50):
		_spawn_pieton()
	voiture_actuelle = get_node("voiture principale")

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
	if body is CharacterBody2D:
		body.entrer_route()

func changer_voiture(nouvelle_scene):
	var pos = voiture_actuelle.position
	var ancien_argent = voiture_actuelle.argent
	var ancien_compteur = voiture_actuelle.compteur
	voiture_actuelle.queue_free()
	var nouvelle_voiture = nouvelle_scene.instantiate()
	nouvelle_voiture.position = pos
	add_child(nouvelle_voiture)
	nouvelle_voiture.argent = ancien_argent
	nouvelle_voiture.compteur = ancien_compteur
	voiture_actuelle = nouvelle_voiture
