extends Control

# 定数を宣言
const GRID_SIZE: int = 3
const CELL_COUNT: int = GRID_SIZE * GRID_SIZE
const REVEAL_SECONDS: float = 2.0
const TARGETS_TO_CLEAR: int = 5
const FRUITS := [
	{"name":"りんご","path":"res://art/apple.png"},
	{"name":"バナナ","path":"res://art/banana.png"},
	{"name":"ぶどう","path":"res://art/grape.png"},
	{"name":"オレンジ","path":"res://art/orange.png"},
	{"name":"いちご","path":"res://art/strawberry.png"},
	{"name":"なし","path":"res://art/pear.png"},
	{"name":"レモン","path":"res://art/lemon.png"},
	{"name":"すいか","path":"res://art/watermelon.png"},
	{"name":"さくらんぼ","path":"res://art/cherry.png"},
]

# シーン上のノードを取得
@onready var title_label: Label  = $VBoxContainer/TitleLabel
@onready var grid: GridContainer = $VBoxContainer/BoardPanel/Grid
@onready var streak_label: Label = $VBoxContainer/HBoxContainer/StreakLabel
@onready var home_button: Button = $VBoxContainer/HBoxContainer/HomeButton

# 変数を宣言
var textures: Array[Texture2D] = []
var names: Array[String] = []
var name_to_texture: Dictionary[String, Texture2D] = {}
var cell_buttons: Array[Button] = []
var cell_images:  Array[TextureRect] = []
var cell_fruit_name: Array[String] = []
var target_name: String = ""
var streak: int = 0
var input_locked: bool = true
var round_active: bool = false
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# 最初に1回だけ動く
func _ready() -> void:
	rng.randomize()
	_load_fruit_textures()
	home_button.pressed.connect(_go_home)
	_build_grid()
	_start_new_game()

func _load_fruit_textures() -> void:
	textures.clear()
	names.clear()
	name_to_texture.clear()
	for f in FRUITS:
		var tex: Texture2D = load(f.path) as Texture2D
		if tex:
			var n: String = f.name
			textures.append(tex)
			names.append(n)
			name_to_texture[n] = tex

func _build_grid() -> void:
	for c in grid.get_children():
		c.queue_free()

	cell_buttons.clear()
	cell_images.clear()
	cell_fruit_name.resize(CELL_COUNT)

	for i in range(CELL_COUNT):
		# 親：Button（クリック受付）
		var btn := Button.new()
		btn.focus_mode = Control.FOCUS_NONE
		btn.text = ""  # ラベルは出さない
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.size_flags_vertical   = Control.SIZE_EXPAND_FILL

		# 子：TextureRect（画像表示・縮小制御）
		var img := TextureRect.new()
		img.expand = true                                # ← これが効くのは TextureRect
		img.set_anchors_preset(Control.PRESET_FULL_RECT)	# ← 親(Button)いっぱいに広げる
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		img.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		img.size_flags_vertical   = Control.SIZE_EXPAND_FILL

		btn.add_child(img)
		grid.add_child(btn)

		cell_buttons.append(btn)
		cell_images.append(img)

		var idx: int = i
		btn.pressed.connect(func() -> void:
			_on_cell_pressed(idx)
		)

func _start_new_game() -> void:
	streak = 0
	_update_streak()
	_next_round()

func _update_streak() -> void:
	streak_label.text = "連続正解: %d/%d" % [streak, TARGETS_TO_CLEAR]

func _next_round() -> void:
	round_active = false
	input_locked = true

	var chosen_names: Array[String] = []
	var chosen_textures: Array[Texture2D] = []
	chosen_names.resize(CELL_COUNT)
	chosen_textures.resize(CELL_COUNT)

	for i in range(CELL_COUNT):
		var idx: int = rng.randi_range(0, textures.size() - 1)
		chosen_textures[i] = textures[idx]
		chosen_names[i] = names[idx]

	var target_idx: int = rng.randi_range(0, CELL_COUNT - 1)
	target_name = chosen_names[target_idx]

	# 記憶表示（画像は TextureRect にセット）
	for i in range(CELL_COUNT):
		cell_images[i].texture = chosen_textures[i]
		cell_buttons[i].disabled = true
		cell_fruit_name[i] = chosen_names[i]
		cell_buttons[i].tooltip_text = cell_fruit_name[i]
		
	title_label.text = "覚えて！ (%.1f 秒)" % REVEAL_SECONDS

	await get_tree().create_timer(REVEAL_SECONDS).timeout

	# 隠す
	for i in range(CELL_COUNT):
		cell_images[i].texture = null
		cell_buttons[i].disabled = false

	title_label.text = "%s はどこ？ タップしてね" % target_name
	input_locked = false
	round_active = true

func _on_cell_pressed(index: int) -> void:
	if input_locked or not round_active:
		return
	input_locked = true
	round_active = false

	var is_correct: bool = (cell_fruit_name[index] == target_name)

	if is_correct:
		var tex: Texture2D = name_to_texture.get(target_name, null) as Texture2D
		if tex:
			cell_images[index].texture = tex  # 押したセルだけ正解を戻す
		title_label.text = "正解！"
		streak += 1
		_update_streak()
		await get_tree().create_timer(0.8).timeout

		if streak >= TARGETS_TO_CLEAR:
			await _show_result_and_return_home(true)
		else:
			_next_round()
	else:
		title_label.text = "不正解…"
		# 正解セルを一瞬表示
		var correct_idx: int = -1
		for i in range(CELL_COUNT):
			if cell_fruit_name[i] == target_name:
				correct_idx = i
				break
		if correct_idx >= 0:
			var tex2: Texture2D = name_to_texture.get(target_name, null) as Texture2D
			if tex2:
				cell_images[correct_idx].texture = tex2
		await get_tree().create_timer(1.0).timeout
		await _show_result_and_return_home(false)

func _go_home() -> void:
	get_tree().change_scene_to_file("res://Main.tscn")

func _show_result_and_return_home(cleared: bool) -> void:
	title_label.text = "🎉 クリア！" if cleared else "💥 失敗！"
	for b in cell_buttons:
		b.disabled = true
	await get_tree().create_timer(1.2).timeout
	get_tree().change_scene_to_file("res://Main.tscn")

