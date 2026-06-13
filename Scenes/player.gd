extends CharacterBody2D

@export var speed: float = 220.0
@export var slide_speed: float = 520.0
@export var acceleration: float = 12.0
@export var friction: float = 8.0
@export var slide_friction: float = 2.0

@onready var anim: AnimatedSprite2D = get_node_or_null("Anim") as AnimatedSprite2D

var is_sliding: bool = false
var last_direction: Vector2 = Vector2.DOWN

var slide_cooldown: float = 1.0
var slide_cooldown_timer: float = 0.0


func _ready() -> void:
	update_animation()


func _physics_process(delta: float) -> void:
	update_slide_cooldown(delta)

	if is_player_frozen():
		velocity = Vector2.ZERO
		move_and_slide()
		update_animation()
		return

	var input_dir: Vector2 = Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	if input_dir != Vector2.ZERO:
		last_direction = snap_to_4dir(input_dir)

	if Input.is_action_just_pressed("slide") and can_slide():
		start_slide()

	if is_sliding:
		update_slide(delta)
	else:
		update_normal_movement(input_dir, delta)

	move_and_slide()
	update_animation()


func is_player_frozen() -> bool:
	var main_scene: Node = get_tree().current_scene

	if main_scene == null:
		return false

	var value = main_scene.get("is_frozen")

	if value == null:
		return false

	return bool(value)


func update_slide_cooldown(delta: float) -> void:
	if slide_cooldown_timer > 0.0:
		slide_cooldown_timer -= delta

	if slide_cooldown_timer < 0.0:
		slide_cooldown_timer = 0.0


func can_slide() -> bool:
	if is_sliding:
		return false

	if slide_cooldown_timer > 0.0:
		return false

	return true


func start_slide() -> void:
	is_sliding = true
	slide_cooldown_timer = slide_cooldown
	velocity = last_direction * slide_speed


func update_slide(delta: float) -> void:
	velocity = velocity.move_toward(
		Vector2.ZERO,
		slide_friction * slide_speed * delta
	)

	if velocity.length() < 40.0:
		is_sliding = false


func update_normal_movement(input_dir: Vector2, delta: float) -> void:
	var target_velocity: Vector2 = input_dir * speed
	var rate: float = acceleration if input_dir != Vector2.ZERO else friction

	velocity = velocity.move_toward(
		target_velocity,
		rate * speed * delta
	)


func snap_to_4dir(dir: Vector2) -> Vector2:
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0.0:
			return Vector2.RIGHT

		return Vector2.LEFT

	if dir.y > 0.0:
		return Vector2.DOWN

	return Vector2.UP


func update_animation() -> void:
	if anim == null:
		return

	if anim.sprite_frames == null:
		return

	var anim_name: String = ""

	if is_sliding:
		anim_name = "slide_" + direction_to_name(last_direction)
	elif velocity.length() > 10.0:
		anim_name = "walk_" + direction_to_name(last_direction)
	else:
		anim_name = "idle_" + direction_to_name(last_direction)

	if not anim.sprite_frames.has_animation(anim_name):
		print("Falta animación: " + anim_name)
		return

	if anim.animation != anim_name:
		anim.play(anim_name)
	elif not anim.is_playing():
		anim.play(anim_name)


func direction_to_name(dir: Vector2) -> String:
	if dir == Vector2.RIGHT:
		return "right"

	if dir == Vector2.LEFT:
		return "left"

	if dir == Vector2.UP:
		return "up"

	return "down"
