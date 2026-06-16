extends Area2D

const ANTENNA_BROKEN_TEXTURE := preload("res://Sprite/Antenna/antena_rota_normalizada.png")
const ANTENNA_REPAIRED_TEXTURE := preload("res://Sprite/Antenna/antena_reparada_normalizada.png")

var is_repaired: bool = false

@onready var antenna_sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	antenna_sprite.texture = ANTENNA_BROKEN_TEXTURE if not is_repaired else ANTENNA_REPAIRED_TEXTURE


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		get_tree().current_scene.enter_antenna()


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		get_tree().current_scene.exit_antenna()


func repair_visual() -> void:
	is_repaired = true
	antenna_sprite.texture = ANTENNA_REPAIRED_TEXTURE
