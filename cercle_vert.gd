extends Node2D

var couleur = Color(0, 1, 0, 0.5)

func _draw():
	draw_circle(Vector2.ZERO, 20.0, couleur)
