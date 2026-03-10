extends CharacterBody2D

var dezoom = false
const SPEED = 100.0
const BOOST_SPEED = 800.0
var boost_energy = 100.0
const BOOST_MAX = 100.0
const BOOST_DRAIN = 30.0
const BOOST_REGEN = 0.0
var argent = 500
var compteur = 0
var voitures_possedees = ["voiture1"]

func _process(_delta):
	if Input.is_action_pressed("zoom_out"):
		$Camera2D.zoom = Vector2(0.5, 0.5)
	else:
		$Camera2D.zoom = Vector2(2, 2)
	
	if has_node("CanvasLayer/MenuShop/Label"):
		$CanvasLayer/MenuShop/Label.text = "Argent : " + str(int(argent)) + "$"
	
	if has_node("CanvasLayer/JaugeCompteur"):
		$CanvasLayer/JaugeCompteur.value = compteur
	
	if compteur >= 100:
		get_tree().paused = true
		if has_node("CanvasLayer/LabelGameOver"):
			$CanvasLayer/LabelGameOver.visible = true
	
	if Input.is_action_just_pressed("ui_cancel"):
		if has_node("CanvasLayer/PanelVoiture2"):
			$CanvasLayer/PanelVoiture2.visible = false
		if has_node("CanvasLayer/PanelVoiture3"):
			$CanvasLayer/PanelVoiture3.visible = false
		if has_node("CanvasLayer/MenuShop"):
			$CanvasLayer/MenuShop.visible = false
	
	if has_node("CanvasLayer/MenuShop/BoutonVoiture2"):
		$CanvasLayer/MenuShop/BoutonVoiture2.visible = !("voiture2" in voitures_possedees)
	
	if has_node("CanvasLayer/MenuShop/BoutonVoiture3"):
		$CanvasLayer/MenuShop/BoutonVoiture3.visible = !("voiture3" in voitures_possedees)

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
	
	var using_boost = Input.is_action_pressed("boost") and boost_energy > 0
	
	if using_boost:
		boost_energy -= BOOST_DRAIN * _delta
		boost_energy = max(boost_energy, 0)
	else:
		boost_energy += BOOST_REGEN * _delta
		boost_energy = min(boost_energy, BOOST_MAX)
	
	var current_speed = BOOST_SPEED if using_boost else SPEED
	velocity = direction * current_speed
	
	if direction != Vector2.ZERO:
		rotation = direction.angle() + PI/2
	
	move_and_slide()
	
	if has_node("CanvasLayer/Jauge"):
		$CanvasLayer/Jauge.value = boost_energy

func _on_bouton_shop_pressed() -> void:
	$CanvasLayer/MenuShop.visible = !$CanvasLayer/MenuShop.visible

func _on_bouton_boost_pressed() -> void:
	if argent >= 20:
		argent -= 20
		boost_energy = BOOST_MAX

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("pietons"):
		compteur += 5
		body.queue_free()

func _on_bouton_voiture_2_pressed() -> void:
	$CanvasLayer/MenuShop.visible = false
	$CanvasLayer/PanelVoiture2.visible = true

func _on_bouton_acheter_voiture_2_pressed() -> void:
	if argent >= 100:
		argent -= 100
		voitures_possedees.append("voiture2")
		get_parent().changer_voiture(get_parent().voiture2_scene)

func _on_button_pressed() -> void:
	$CanvasLayer/PanelVoiture2.visible = false
	$CanvasLayer/MenuShop.visible = true

func _on_bouton_voiture_3_pressed() -> void:
	$CanvasLayer/MenuShop.visible = false
	$CanvasLayer/PanelVoiture3.visible = true

func _on_bouton_acheter_voiture_3_pressed() -> void:
	if argent >= 100:
		argent -= 100
		voitures_possedees.append("voiture3")
		get_parent().changer_voiture(get_parent().voiture3_scene)

func _on_bouton_retour_voiture_3_pressed() -> void:
	$CanvasLayer/PanelVoiture3.visible = false
	$CanvasLayer/MenuShop.visible = true


func _on_bouton_retour_pressed() -> void:
	pass # Replace with function body.


func _on_bouton_retour_voiture_2_pressed() -> void:
	pass # Replace with function body.
