extends CharacterBody2D

const GRAVITY: float = 1200.0
const JUMP_FORCE: float = -500.0

var is_dead: bool = false

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_FORCE

	move_and_slide()

	if get_slide_collision_count() > 0:
		die()

func die() -> void:
	if is_dead:
		return
	is_dead = true

	var main = get_parent()
	if main.has_method("game_over"):
		main.game_over()
