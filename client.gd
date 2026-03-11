extends CharacterBody2D

@export var zone_depot_scene = preload("res://zone_depot.tscn")
var zone_depot = null
var dans_voiture = false
var couleur = Color(randf(), randf(), randf(), 0.5)

func _ready():
	add_to_group("clients")
	_spawn_zone()
	$CercleRouge.couleur = couleur
	$CercleRouge.queue_redraw()

func _spawn_zone():
	zone_depot = zone_depot_scene.instantiate()
	zone_depot.position = Vector2(-1144 + randi() % 2137, -1536 + randi() % 2720)
	get_parent().add_child(zone_depot)
	zone_depot.client_associe = self
	zone_depot.get_node("CercleVert").couleur = couleur
	zone_depot.get_node("CercleVert").queue_redraw()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("voiture") and not dans_voiture:
		dans_voiture = true
		visible = false
