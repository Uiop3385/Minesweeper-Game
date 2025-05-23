extends Control

@onready var bottom_panel = $CanvasLayer/BottomPanel/ScrollContainer/HBoxContainer
@onready var tab_container = $CanvasLayer/BetterTabContainer
@onready var current_button = bottom_panel.get_node("0")

var tabs
var current_tab
var button_list = []

func _ready():
	tabs = bottom_panel.get_child_count()
	current_tab = tab_container.current_tab
	for button in bottom_panel.get_children():
		button.custom_button_pressed.connect(button_update)
		button_list.append(button)

func _on_better_tab_container_tab_switched(tab):
	await get_tree().process_frame
	current_tab = tab
	current_button.set_disabled(false)
	var button = bottom_panel.get_node(str(current_tab))
	button.set_disabled(true)
	current_button = button

func button_update(button):
	var tab_index = int(str(button.name))
	current_button.set_disabled(false)
	button.set_disabled(true)
	current_button = button
	tab_container.switch_tab(tab_index)

func _process(_delta):
	pass
