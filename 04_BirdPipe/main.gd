extends Node2D

@onready var pipe_scene: PackedScene = preload("res://PipePair.tscn")
@onready var spawn_timer: Timer = $SpawnTimer

var rng := RandomNumberGenerator.new()
var is_over: bool = false

func _ready() -> void:
	rng.randomize()
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _on_spawn_timer_timeout() -> void:
	if is_over:
		return

	var pipe = pipe_scene.instantiate()
	var spawn_x: float = 1300.0
	var random_y: float = rng.randf_range(-150.0, 150.0)

	pipe.position = Vector2(spawn_x, random_y)
	add_child(pipe)

func game_over() -> void:
	if is_over:
		return
	is_over = true
	spawn_timer.stop()
	print("GAME OVER")
