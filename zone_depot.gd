extends Node2D

var client_associe = null

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("voiture") and client_associe != null and client_associe.dans_voiture:
		body.argent += 70
		client_associe.queue_free()
		queue_free()
