extends Control
@onready var start_button: Button = $VBoxContainer/StartButton

func _ready() -> void:
	start_button.pressed.connect(_on_start)

func _on_start() -> void:
	get_tree().change_scene_to_file("res://MemoryGame.tscn")

