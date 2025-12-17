extends Control

# ％固有名でノードを取得
@onready var info: Label = %Info
@onready var grid: GridContainer = %Grid
@onready var time_label: Label = %TimeLabel
@onready var restart_btn: Button = %RestartBtn

# 処理に使う変数たち
var next_number := 1
var last_number := 5
var running := false
var start_ms := 0

# 1番最初に１回実行される処理
func _ready() -> void:
	for b in grid.get_children():
		if b is Button:
			b.pressed.connect(func(): _on_number_pressed(int((b as Button).text)))
	restart_btn.pressed.connect(new_round)

	new_round()

# 新しいゲームを始める処理
func new_round() -> void:
	next_number = 1
	running = false
	time_label.text = "0.00s"
	info.text = "1→5の順にタップ！"
	_shuffle_buttons()

# ボタンをランダムに配置する処理
func _shuffle_buttons() -> void:
	var kids := grid.get_children()
	kids.shuffle()
	for i in kids.size():
		grid.move_child(kids[i], i)

# 数字ボタンが押されたときの処理
func _on_number_pressed(n: int) -> void:
	# まだスタートしていない時は、1からしか始められない
	if not running:
		if n != 1:
			info.text = "最初は 1 から！"
			return
		running = true
		start_ms = Time.get_ticks_msec()

	# 押された数字が正しければ次に進む
	if n == next_number:
		if n == last_number:
			var elapsed := (Time.get_ticks_msec() - start_ms) / 1000.0
			time_label.text = "%.2fs" % elapsed
			info.text = "クリア！ Restartで再挑戦"
			running = false
		else:
			next_number += 1
			info.text = "次は %d" % next_number
	else:
		# ミスしたら即リセット
		new_round()
