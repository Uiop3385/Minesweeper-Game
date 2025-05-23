extends TextureButton

@onready var res = $ResourcePreloader

var can_be_flagged = true
var is_flagged = false
var exploded = false
var coords_x
var coords_y
var mine_amount
var tile_icon
var tile_contents
var tile_display

signal uncover
signal flag
signal unflag
signal boom
signal win

func _ready():
	await get_tree().process_frame
	recount_board()

func _process(_delta):
	pass

func _on_tile_pressed(event):
	if event is InputEventMouseButton and event.pressed and not exploded:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if not ArrayManager.flag_mode:
					tile_uncover_event()
				else:
					tile_flag_event()
			MOUSE_BUTTON_RIGHT:
				tile_flag_event()

func tile_uncover_event():
	if not is_flagged:
		uncover.emit()
		if tile_contents == "tile_mine":
			if not ArrayManager.first_tile:
				boom.emit()
				ArrayManager.set_tile_display(coords_x, coords_y, "tile_mine_clicked")
				can_be_flagged = false
				exploded = true
			else:
				ArrayManager.set_tile_contents(coords_x, coords_y, "tile_"+str(mine_amount) if mine_amount > 0 else "tile_uncovered")
				ArrayManager.set_tile_display(coords_x, coords_y, ArrayManager.get_tile_contents(coords_x, coords_y))
				if mine_amount == 0:
					uncover_tiles(coords_x, coords_y, [], false)
					recount_surrounding_tiles()
				ArrayManager.first_tile = false
				can_be_flagged = false
		elif tile_contents == "tile_uncovered":
			uncover_tiles(coords_x, coords_y, [], false)
			if ArrayManager.first_tile:
				recount_surrounding_tiles()
			ArrayManager.first_tile = false
		else:
			ArrayManager.set_tile_display(coords_x, coords_y, "tile_"+str(mine_amount) if mine_amount > 0 else "tile_uncovered")
			can_be_flagged = false
			ArrayManager.first_tile = false
		check_win()

func tile_flag_event():
	tile_display = ArrayManager.get_tile_display(coords_x, coords_y)
	if tile_display != "tile_covered":
		can_be_flagged = false
	if can_be_flagged:
		flag.emit()
		ArrayManager.set_tile_display(coords_x, coords_y, "tile_flag")
		is_flagged = true
		can_be_flagged = false
	elif is_flagged:
		unflag.emit()
		ArrayManager.set_tile_display(coords_x, coords_y, "tile_covered")
		can_be_flagged = true
		is_flagged = false

func uncover_tiles(x, y, checked_tiles, update_contents):
	for tile in ArrayManager.adjacent_tiles(x, y):
		if tile in checked_tiles:
			continue
		if update_contents:
			var tile_mine_amount = ArrayManager.count_mines(ArrayManager.adjacent_tiles(tile[0], tile[1]))
			ArrayManager.set_tile_contents(tile[0], tile[1], "tile_"+str(tile_mine_amount) if tile_mine_amount > 0 else "tile_uncovered")
		var contents = ArrayManager.get_tile_contents(tile[0], tile[1])
		if ArrayManager.get_tile_display(tile[0], tile[1]) == "tile_flag":
			checked_tiles.append([tile[0], tile[1]])
			continue
		ArrayManager.set_tile_display(tile[0], tile[1], contents)
		if contents == "tile_uncovered":
			checked_tiles.append([tile[0], tile[1]])
			uncover_tiles(tile[0], tile[1], checked_tiles, update_contents)
	ArrayManager.set_tile_display(coords_x, coords_y, "tile_uncovered")

func check_win():
	var tile_x = 1
	var tile_y = 1
	var unopened_tiles = 0
	for tile in get_tree().get_nodes_in_group("tiles"):
		if ArrayManager.get_tile_display(tile_x, tile_y) == "tile_covered" or ArrayManager.get_tile_display(tile_x, tile_y) == "tile_flag":
			unopened_tiles += 1
		if tile_x < ArrayManager.board_size:
			tile_x += 1
		else:
			tile_y += 1
			tile_x = 1
	if unopened_tiles == ArrayManager.total_mines and not exploded:
		win.emit()

func recount_board():
	mine_amount = ArrayManager.count_mines(ArrayManager.adjacent_tiles(coords_x, coords_y))
	if ArrayManager.get_tile_contents(coords_x, coords_y) == "tile_mine":
		return
	else:
		tile_icon = "tile_"+str(mine_amount) if mine_amount > 0 else "tile_uncovered"
		ArrayManager.set_tile_contents(coords_x, coords_y, "tile_"+str(mine_amount) if mine_amount > 0 else "tile_uncovered")
	tile_contents = ArrayManager.get_tile_contents(coords_x, coords_y)
	tile_display = ArrayManager.get_tile_display(coords_x, coords_y)

func recount_surrounding_tiles():
	var surrounding_tiles = ArrayManager.adjacent_tiles(coords_x, coords_y)
	for tile in get_tree().get_nodes_in_group("tiles"):
		for i in surrounding_tiles:
			if i[0] == tile.coords_x and i[1] == tile.coords_y:
				tile.mine_amount = ArrayManager.count_mines(ArrayManager.adjacent_tiles(tile.coords_x, tile.coords_y))
				ArrayManager.set_tile_contents(tile.coords_x, tile.coords_y, "tile_"+str(tile.mine_amount) if tile.mine_amount > 0 else "tile_uncovered")
				if tile.mine_amount == 0:
					uncover_tiles(tile.coords_x, tile.coords_y, [], true)
