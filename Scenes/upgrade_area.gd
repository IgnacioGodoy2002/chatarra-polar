extends Area2D

var player_inside: bool = false
var interact_cooldown: float = 0.0
var feedback_timer: float = 0.0


func _ready() -> void:
	monitoring = true
	monitorable = true

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	if interact_cooldown > 0.0:
		interact_cooldown -= delta
	if feedback_timer > 0.0:
		feedback_timer -= delta

	if not player_inside:
		return

	var main_scene: Node = get_tree().current_scene

	if main_scene != null:
		var status_value = main_scene.get("status_label")

		if status_value != null and status_value is Label:
			var status_label: Label = status_value as Label
			if feedback_timer <= 0.0:
				status_label.text = "[E] Usar mesa de trabajo   [F] Guardar materiales"

	if interact_cooldown > 0.0:
		return

	if Input.is_action_just_pressed("interact") or Input.is_key_pressed(KEY_E):
		interact_cooldown = 0.35

		if main_scene != null and main_scene.has_method("open_workshop_panels"):
			main_scene.open_workshop_panels()

	elif Input.is_action_just_pressed("deposit_materials"):
		interact_cooldown = 0.35
		feedback_timer = 2.0
		if main_scene != null:
			var sc_val = main_scene.get("scrap_count")
			var status_value = main_scene.get("status_label")
			if status_value != null and status_value is Label:
				var status_label: Label = status_value as Label
				if sc_val != null and int(sc_val) > 0:
					if main_scene.has_method("deposit_scrap"):
						main_scene.call("deposit_scrap")
					status_label.text = "Materiales guardados en la base"
				else:
					status_label.text = "No tenés materiales para guardar"


func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player" and not body.is_in_group("player"):
		return

	player_inside = true

	var main_scene: Node = get_tree().current_scene

	if main_scene != null:
		main_scene.set("is_near_upgrade_table", true)

		var status_value = main_scene.get("status_label")

		if status_value != null and status_value is Label:
			var status_label: Label = status_value as Label
			status_label.text = "[E] Usar mesa de trabajo   [F] Guardar materiales"


func _on_body_exited(body: Node2D) -> void:
	if body.name != "Player" and not body.is_in_group("player"):
		return

	player_inside = false

	var main_scene: Node = get_tree().current_scene

	if main_scene != null:
		main_scene.set("is_near_upgrade_table", false)

		if main_scene.has_method("close_workshop_panels"):
			main_scene.close_workshop_panels()

		var status_value = main_scene.get("status_label")

		if status_value != null and status_value is Label:
			var status_label: Label = status_value as Label
			status_label.text = "Interior de la base"
