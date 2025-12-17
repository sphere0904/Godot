extends Control

var money: float = 100.0
var income_per_sec: float = 0.0

var shop_costs = [100.0, 200.0, 500.0]
var shop_incomes = [20.0, 30.0, 50.0]
var shop_bought = [false, false, false] #shopが購入済みかどうかのフラグ

@onready var money_label: Label = $VBoxContainer/MoneyLabel
@onready var income_label: Label = $VBoxContainer/IncomeLabel
@onready var shop1_button: TextureButton = $VBoxContainer/HBoxContainer/Shop1Button
@onready var shop2_button: TextureButton = $VBoxContainer/HBoxContainer/Shop2Button
@onready var shop3_button: TextureButton = $VBoxContainer/HBoxContainer/Shop3Button

func _ready() -> void:
	_update_ui()

func _process(delta: float) -> void:
	money += income_per_sec * delta
	_update_ui()

func _update_ui() -> void:
	money_label.text = "Money: %d G" % int(money)
	income_label.text = "Income: %d G / sec" % int(income_per_sec)

	shop1_button.disabled = shop_bought[0] or money < shop_costs[0]
	shop2_button.disabled = shop_bought[1] or money < shop_costs[1]
	shop3_button.disabled = shop_bought[2] or money < shop_costs[2]

func _try_buy_shop(index: int) -> void:
	if shop_bought[index]:
		return

	var cost = shop_costs[index]
	if money >= cost:
		money -= cost
		income_per_sec += shop_incomes[index]
		shop_bought[index] = true

func _on_Shop1Button_pressed() -> void:
	_try_buy_shop(0)

func _on_Shop2Button_pressed() -> void:
	_try_buy_shop(1)

func _on_Shop3Button_pressed() -> void:
	_try_buy_shop(2)
