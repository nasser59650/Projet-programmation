extends CharacterBody2D

var dezoom = false
const SPEED = 100.0
const BOOST_SPEED = 800.0
const ACCELERATION = 400.0
const BOOST_ACCEL = 2000.0
const STOP_TIME = 0.25
const BOOST_STOP_TIME = 0.08
var _decel_rate: float = 0.0
var _drunk_time: float = 0.0
var _notif_time: float = 0.0
var _notif_shown_50: bool = false
var _notif_shown_75: bool = false
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
	if has_node("CanvasLayer/BoutonVehicule3"):
		$CanvasLayer/BoutonVehicule3.add_theme_color_override("font_color", Color(1, 0.85, 0, 1))

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
				$CanvasLayer/LabelGameOver.text = "Bien joué !\n\nTemps : %dm%ds\nArgent gagné : %d$" % [minutes, seconds, argent]
			$CanvasLayer/LabelGameOver.visible = true
		if has_node("CanvasLayer/BoutonRejouer"):
			$CanvasLayer/BoutonRejouer.visible = true
	
	if has_node("CanvasLayer/FlecheDirection"):
		var fleche = $CanvasLayer/FlecheDirection
		var cible: Node2D = null
		for c in get_tree().get_nodes_in_group("clients"):
			if c.dans_voiture and c.zone_depot != null:
				cible = c.zone_depot
				break
		if cible == null:
			var clients = get_tree().get_nodes_in_group("clients")
			for c in clients:
				if not c.dans_voiture:
					if cible == null or global_position.distance_to(c.global_position) < global_position.distance_to(cible.global_position):
						cible = c
		if cible != null:
			var screen_center = get_viewport().get_visible_rect().size / 2
			fleche.position = screen_center
			fleche.visible = true
			fleche.rotation = (cible.global_position - global_position).angle()
		else:
			fleche.visible = false

	if compteur >= 50 and not _notif_shown_50:
		_notif_shown_50 = true
		_show_notif("Contrôle inversé !")
	if compteur >= 75 and not _notif_shown_75:
		_notif_shown_75 = true
		_show_notif("Vision trouble !")

	if _notif_time > 0:
		_notif_time -= _delta
		if has_node("CanvasLayer/LabelNotif"):
			var a: float
			if _notif_time > 0.8:
				a = (1.0 - _notif_time) / 0.2
			elif _notif_time > 0.3:
				a = 1.0
			else:
				a = _notif_time / 0.3
			$CanvasLayer/LabelNotif.modulate.a = a
			if _notif_time <= 0:
				$CanvasLayer/LabelNotif.visible = false

	if compteur >= 75:
		_drunk_time += _delta
		var intensity = 0.4 + (compteur - 75.0) / 25.0 * 0.6
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

	if has_node("CanvasLayer/BoutonVehicule2"):
		$CanvasLayer/BoutonVehicule2.visible = "voiture2" in voitures_possedees
	if has_node("CanvasLayer/BoutonVehicule3"):
		$CanvasLayer/BoutonVehicule3.visible = "voiture3" in voitures_possedees

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
			var stop = BOOST_STOP_TIME if using_boost else STOP_TIME
			_decel_rate = velocity.length() / stop
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
		argent += 10
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

func _on_bouton_vehicule_1_pressed() -> void:
	get_parent().changer_voiture(get_parent().voiture1_scene)

func _on_bouton_vehicule_2_pressed() -> void:
	if "voiture2" in voitures_possedees:
		get_parent().changer_voiture(get_parent().voiture2_scene)

func _on_bouton_vehicule_3_pressed() -> void:
	if "voiture3" in voitures_possedees:
		get_parent().changer_voiture(get_parent().voiture3_scene)

func _on_bouton_rejouer_pressed() -> void:
	_rejouer()

func _rejouer() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _show_notif(msg: String) -> void:
	if has_node("CanvasLayer/LabelNotif"):
		$CanvasLayer/LabelNotif.text = msg
		$CanvasLayer/LabelNotif.modulate.a = 0.0
		$CanvasLayer/LabelNotif.visible = true
		_notif_time = 1.0
