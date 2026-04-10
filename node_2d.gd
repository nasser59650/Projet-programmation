extends Node2D

@export var pieton_scene = preload("res://piéton_1.tscn")
@export var voiture1_scene = preload("res://voiture_principale3.tscn")
@export var voiture2_scene = preload("res://voiture_principale2.tscn")
@export var voiture3_scene = preload("res://voiture_principale.tscn")
@export var client_scene = preload("res://client.tscn")

var spawn_timer = 0.0
const SPAWN_TIME = 1.0
var client_timer: float = 0.0
const CLIENT_SPAWN_TIME = 30.0
var voiture_actuelle = null
var rage_globale = 0
var game_timer: float = 0.0

func _ready():
	for i in range(50):
		_spawn_pieton()
	voiture_actuelle = get_node("voiture principale")

func _process(delta):
	game_timer += delta
	spawn_timer += delta
	if spawn_timer >= SPAWN_TIME:
		spawn_timer = 0.0
		_spawn_pieton()
	
	client_timer += delta
	if client_timer >= CLIENT_SPAWN_TIME:
		client_timer = 0.0
		_spawn_client()
	
	if voiture_actuelle:
		rage_globale = voiture_actuelle.compteur
	
	if Input.is_action_just_pressed("voiture_1"):
		if "voiture1" in voiture_actuelle.voitures_possedees:
			changer_voiture(voiture1_scene)
	
	if Input.is_action_just_pressed("voiture_2"):
		if "voiture2" in voiture_actuelle.voitures_possedees:
			changer_voiture(voiture2_scene)
	
	if Input.is_action_just_pressed("voiture_3"):
		if "voiture3" in voiture_actuelle.voitures_possedees:
			changer_voiture(voiture3_scene)

func _spawn_pieton():
	var pieton = pieton_scene.instantiate()
	pieton.position = Vector2(-1144 + randi() % 2137, -1536 + randi() % 2720)
	add_child(pieton)

func _spawn_client():
	var client = client_scene.instantiate()
	client.position = Vector2(-1144 + randi() % 2137, -1536 + randi() % 2720)
	add_child(client)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.entrer_route()

func changer_voiture(nouvelle_scene):
	var pos = voiture_actuelle.position
	var ancien_argent = voiture_actuelle.argent
	var ancien_compteur = voiture_actuelle.compteur
	var anciennes_voitures = voiture_actuelle.voitures_possedees
	var ancien_boost = voiture_actuelle.boost_energy
	var ancien_notif_50 = voiture_actuelle._notif_shown_50
	var ancien_notif_75 = voiture_actuelle._notif_shown_75
	voiture_actuelle.queue_free()
	var nouvelle_voiture = nouvelle_scene.instantiate()
	nouvelle_voiture.position = pos
	add_child(nouvelle_voiture)
	nouvelle_voiture.argent = ancien_argent
	nouvelle_voiture.compteur = ancien_compteur
	nouvelle_voiture.voitures_possedees = anciennes_voitures
	nouvelle_voiture.boost_energy = ancien_boost
	nouvelle_voiture._notif_shown_50 = ancien_notif_50
	nouvelle_voiture._notif_shown_75 = ancien_notif_75
	voiture_actuelle = nouvelle_voiture
