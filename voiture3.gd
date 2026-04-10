extends CharacterBody2D

var dezoom = false
const SPEED = 100.0
const BOOST_SPEED = 800.0
const ACCELERATION = 400.0
const BOOST_ACCEL = 2000.0
const STOP_TIME = 0.25
var _decel_rate: float = 0.0
var _drunk_time: float = 0.0
var boost_energy = 100.0
const BOOST_MAX = 100.0
const BOOST_DRAIN = 30.0
const BOOST_REGEN = 0.0
var argent = 0
var compteur = 0
var voitures_possedees = ["voiture1"]
@export var tache_sang_scene = preload("res://sang.tscn")

func _ready():
	add_to_group("voiture")

func _process(_delta):
	if Input.is_action_pressed("zoom_out"):
		$Camera2D.zoom = Vector2(0.5, 0.5)
	else:
		$Camera2D.zoom = Vector2(2, 2)
	
	if has_node("CanvasLayer/MenuShop/Label"):
		$CanvasLayer/MenuShop/Label.text = "Argent : " + str(int(argent)) + "$"
	if has_node("CanvasLayer/LabelArgent"):
		$CanvasLayer/LabelArgent.text = str(int(argent)) + "$"
	
	if has_node("CanvasLayer/JaugeCompteur"):
		$CanvasLayer/JaugeCompteur.value = compteur

	if has_node("CanvasLayer/LabelTimer"):
		var t = get_parent().game_timer
		$CanvasLayer/LabelTimer.text = "%02d:%02d" % [int(t / 60), int(t) % 60]

	if compteur >= 100:
		get_tree().paused = true
		if has_node("CanvasLayer/LabelGameOver"):
			if not $CanvasLayer/LabelGameOver.visible:
				var t = get_parent().game_timer
				var minutes = int(t / 60)
				var seconds = int(t) % 60
				$CanvasLayer/LabelGameOver.text = "Bien joué !\nJeu réalisé en %dm%ds" % [minutes, seconds]
			$CanvasLayer/LabelGameOver.visible = true
	
	if has_node("CanvasLayer/TacheEncre"):
		$CanvasLayer/TacheEncre.visible = compteur >= 80

	if compteur >= 75:
		_drunk_time += _delta
		var intensity = (compteur - 75.0) / 25.0
		var wobble_x = sin(_drunk_time * 1.5) * 30 * intensity
		var wobble_y = cos(_drunk_time * 2.3) * 20 * intensity
		if has_node("Camera2D"):
			$Camera2D.offset = Vector2(wobble_x, wobble_y)
		if has_node("CanvasLayer/DrunkEffect"):
			$CanvasLayer/DrunkEffect.material.set_shader_parameter("intensity", intensity)
			$CanvasLayer/DrunkEffect.material.set_shader_parameter("time_val", _drunk_time)
	else:
		_drunk_time = 0.0
		if has_node("Camera2D"):
			$Camera2D.offset = Vector2.ZERO
		if has_node("CanvasLayer/DrunkEffect"):
			$CanvasLayer/DrunkEffect.material.set_shader_parameter("intensity", 0.0)

	if Input.is_action_just_pressed("ui_cancel"):
		if has_node("CanvasLayer/MenuShop"):
			$CanvasLayer/MenuShop.visible = !$CanvasLayer/MenuShop.visible
	
	if has_node("CanvasLayer/MenuShop/BoutonAcheter2"):
		$CanvasLayer/MenuShop/BoutonAcheter2.visible = !("voiture2" in voitures_possedees)

	if has_node("CanvasLayer/MenuShop/BoutonAcheter3"):
		$CanvasLayer/MenuShop/BoutonAcheter3.visible = !("voiture3" in voitures_possedees)

func _physics_process(_delta):
	var direction = Vector2.ZERO
	var inverse = compteur >= 50
	
	if inverse:
		if Input.is_action_pressed("ui_right"):
			direction.x -= 1
		if Input.is_action_pressed("ui_left"):
			direction.x += 1
		if Input.is_action_pressed("ui_up"):
			direction.y += 1
		if Input.is_action_pressed("ui_down"):
			direction.y -= 1
	else:
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
	var accel = BOOST_ACCEL if using_boost else ACCELERATION

	if direction != Vector2.ZERO:
		_decel_rate = 0.0
		velocity = velocity.move_toward(direction * current_speed, accel * _delta)
		rotation = direction.angle() + PI/2
	else:
		if _decel_rate == 0.0:
			_decel_rate = velocity.length() / STOP_TIME
		velocity = velocity.move_toward(Vector2.ZERO, _decel_rate * _delta)

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
		argent += 25
		var tache = tache_sang_scene.instantiate()
		tache.position = body.position
		get_parent().add_child(tache)
		body.queue_free()

func _on_bouton_acheter_voiture_2_pressed() -> void:
	if argent >= 100:
		argent -= 100
		voitures_possedees.append("voiture2")
		get_parent().changer_voiture(get_parent().voiture2_scene)

func _on_bouton_acheter_voiture_3_pressed() -> void:
	if argent >= 150:
		argent -= 150
		voitures_possedees.append("voiture3")
		get_parent().changer_voiture(get_parent().voiture3_scene)
