extends Control

# ====== 仕様ここ ======
const COSTS := [100, 200, 500]
const INCOMES := [50, 100, 200] # 3つ目の増加分。必要なら変更
# =====================

var money: int = 100
var income: int = 0
var idx: int = 0  # 次に買う店（0,1,2）

@onready var money_value: Label = $Hud/MoneyValue
@onready var income_value: Label = $Hud/IncomeValue
@onready var buy_button: TextureButton = $BuyButton
@onready var shops := [$ShopArea/Shop1, $ShopArea/Shop2, $ShopArea/Shop3]

func _ready() -> void:
	# 店は最初すべて非表示
	for s in shops:
		s.visible = false

	# ボタン
	buy_button.pressed.connect(_buy)

	# 毎秒加算（整数）
	var t := Timer.new()
	t.wait_time = 1.0
	t.one_shot = false
	t.autostart = true
	add_child(t)
	t.timeout.connect(_tick)

	_ui()

func _tick() -> void:
	money += income
	_ui()

func _buy() -> void:
	if idx >= COSTS.size():
		return

	var cost: int = COSTS[idx]
	if money < cost:
		return

	money -= cost
	income += INCOMES[idx]
	shops[idx].visible = true
	idx += 1
	_ui()

func _ui() -> void:
	money_value.text = str(money) + " G"
	income_value.text = str(income) + " G/s"

	# 次の価格に応じてボタンを有効/無効
	if idx < COSTS.size():
		buy_button.disabled = (money < COSTS[idx])
	else:
		buy_button.disabled = true
