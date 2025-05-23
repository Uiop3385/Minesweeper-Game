extends Control

@onready var array_display = get_node("/root/Main/ScreenSwitcher/CanvasLayer/BetterTabContainer/SettingsTab/ScrollContainer/MarginContainer/VBoxContainer/CodeEdit")
@onready var hint_button = get_node("/root/Main/ScreenSwitcher/CanvasLayer/BetterTabContainer/SettingsTab/ScrollContainer/MarginContainer/VBoxContainer/Button2")

var tile_scene = preload("res://scenes/tile.tscn")
var tile_pos_x = 0
var tile_array_x = 1
var tile_pos_y = 0
var tile_array_y = 1
var board_size = 8
var mine_density = 0.2
var zoom = 1
var previous_array = []

func _ready():
	set_up_variables()
	if OS.get_name() == "Android":
		MessageManager.show_standard_messagebox("Android detected", "You are playing on an Android device", "Continue", MessageManager.delete_messageboxes)

func draw_board(total_tiles, mines_placed):
	# generate the board
	for i in range(total_tiles):
		var tile = tile_scene.instantiate()
		$SubViewportContainer/SubViewport/CanvasLayer.add_child(tile)
		ArrayManager.add_tile_to_array([tile_array_x, tile_array_y])
		ArrayManager.add_tile_to_objects(tile, tile_array_x, tile_array_y)
		ArrayManager.set_tile_display(tile_array_x, tile_array_y, "tile_covered")
		tile.coords_x = tile_array_x
		tile.coords_y = tile_array_y
		tile.boom.connect(game_over)
		tile.win.connect(win)
		tile.position.x = tile_pos_x
		tile.position.y = tile_pos_y
		tile_pos_x += 64
		tile_array_x += 1
		if tile_pos_x >= 64 * board_size:
			tile_pos_y += 64
			tile_array_y += 1
			tile_pos_x = 0
			tile_array_x = 1

	# generate the mines
	generate_mines(mines_placed, [])

	# reset the variables
	tile_pos_x = -4
	tile_array_x = 1
	tile_pos_y = -4
	tile_array_y = 1

func erase_board():
	# potentially just delete the entire group instead
	for child in get_tree().get_nodes_in_group("tiles"):
		child.remove_from_group("tiles")
		child.queue_free()

func restart():
	MessageManager.delete_messageboxes()
	erase_board()
	set_up_variables()

func _on_line_edit_text_submitted(new_text):
	board_size = int(new_text)
	erase_board()
	set_up_variables()

func generate_mines(mines_placed, tiles_complete):
	for tile in get_tree().get_nodes_in_group("tiles"):
		while mines_placed > 0:
			var tile_mine_x = randi_range(1, board_size)
			var tile_mine_y = randi_range(1, board_size)

			if [tile_mine_x, tile_mine_y] in tiles_complete:
				continue

			ArrayManager.set_tile_contents(tile_mine_x, tile_mine_y, "tile_mine")
			mines_placed -= 1
			tiles_complete.append([tile_mine_x, tile_mine_y])
			continue
		break

func _on_array_display_updater_button_down():
	array_display.text = str(ArrayManager.get_array())

func _on_line_edit_2_text_submitted(new_text):
	mine_density = float(new_text)/100
	erase_board()
	set_up_variables()

func game_over():
	var tile_x = 1
	var tile_y = 1
	ArrayManager.hint_used = true
	for tile in get_tree().get_nodes_in_group("tiles"):
		if ArrayManager.get_tile_contents(tile_x, tile_y) == "tile_mine" and ArrayManager.get_tile_display(tile_x, tile_y) != "tile_flag":
			ArrayManager.set_tile_display(tile_x, tile_y, "tile_mine")
		if tile.is_flagged and ArrayManager.get_tile_contents(tile_x, tile_y) != "tile_mine":
			ArrayManager.set_tile_display(tile_x, tile_y, "tile_mine_incorrect")
		tile.can_be_flagged = false
		tile.exploded = true
		if tile_x < board_size:
			tile_x += 1
		else:
			tile_y += 1
			tile_x = 1
	MessageManager.show_standard_messagebox("You lost!", "You've exploded a mine, game over! Press Restart to try again.", "Restart", restart)

func win():
	ArrayManager.hint_used = true
	MessageManager.show_standard_messagebox("You win!", "Congratulations, you've won! Press Restart to reset the board.", "Restart", restart)
	for tile in get_tree().get_nodes_in_group("tiles"):
		tile.can_be_flagged = false
		tile.exploded = true

func set_up_variables():
	# set up variables
	hint_button.text = "Get a hint"
	hint_button.add_theme_color_override("font_color", Color("ffffff"))
	hint_button.add_theme_color_override("font_focus_color", Color("ffffff"))
	hint_button.add_theme_color_override("font_hover_color", Color("ffffff"))
	hint_button.add_theme_color_override("font_pressed_color", Color("ffffff"))
	var total_tiles = board_size ** 2
	var mines_placed = round(total_tiles * mine_density)
	tile_pos_x = 0
	tile_pos_y = 0
	ArrayManager.board_size = board_size
	ArrayManager.total_mines = mines_placed
	ArrayManager.first_tile = true
	ArrayManager.hint_used = false
	ArrayManager.reset_array()
	draw_board(total_tiles, mines_placed)

func _on_hint_button_down():
	var tile_x = 1
	var tile_y = 1
	if not ArrayManager.hint_used:
		ArrayManager.hint_used = true
		ArrayManager.first_tile = false
		hint_button.text = "Get a hint (already used)"
		hint_button.add_theme_color_override("font_color", Color("ff0000"))
		hint_button.add_theme_color_override("font_focus_color", Color("ff0000"))
		hint_button.add_theme_color_override("font_hover_color", Color("ff0000"))
		hint_button.add_theme_color_override("font_pressed_color", Color("ff0000"))
		for tile in get_tree().get_nodes_in_group("tiles"):
			if ArrayManager.get_tile_contents(tile_x, tile_y) == "tile_uncovered":
				tile.uncover_tiles(tile_x, tile_y, [], false)
				return
			elif tile_x < board_size:
				tile_x += 1
			else:
				tile_y += 1
				tile_x = 1

func _on_timer_timeout():
	ArrayManager.display_update()

func _on_flag_button_toggled(toggled_on):
	if toggled_on:
		$HBoxContainer/Button.text = "Flag Mode"
	else:
		$HBoxContainer/Button.text = "Dig Mode"
	ArrayManager.flag_mode = toggled_on

func _on_camera_lock_toggled(toggled_on):
	if toggled_on:
		$HBoxContainer/Button2.text = "Swiping\nLocked"
	else:
		$HBoxContainer/Button2.text = "Swiping\nUnlocked"
	ArrayManager.camera_locked = toggled_on
