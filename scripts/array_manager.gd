extends Node

var tile_array = []
var tiles_to_update = []
var adjacent_tiles_array = []
var button_objects = {}
var board_size
var total_mines
var first_tile = true
var hint_used = false
var flag_mode = false
var camera_locked = false

func add_tile_to_objects(tile, tile_x, tile_y):
	button_objects[Vector2(tile_x, tile_y)] = tile

func display_update():
	for tile in tiles_to_update:
		var display = tile[2][1]
		var contents = tile[2][0]
		var coords = Vector2(tile[0], tile[1])
		if coords in button_objects:
			var button = button_objects[coords]
			button.texture_normal = button.res.get_resource(display)
			button.tile_contents = contents
	tiles_to_update.clear()

func adjacent_tiles(tile_x, tile_y):
	adjacent_tiles_array = []
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			if dx == 0 and dy == 0:
				continue
			var adjacent_x = tile_x + dx
			var adjacent_y = tile_y + dy
			if valid_position(adjacent_x, adjacent_y):
				var adjacent_tile = array_search(adjacent_x, adjacent_y)
				adjacent_tiles_array.append([adjacent_tile[0], adjacent_tile[1]])
			else:
				continue
	return adjacent_tiles_array

func add_tile_to_array(input):
	input.append(["", ""])
	tile_array.append(input)

func get_array():
	return tile_array

func reset_array():
	tile_array.clear()
	button_objects.clear()

func set_tile_display(tile_x, tile_y, value):
	var tile = array_search(tile_x, tile_y)
	tile[2][1] = value
	tiles_to_update.append(tile)

func set_tile_contents(tile_x, tile_y, value):
	var tile = array_search(tile_x, tile_y)
	tile[2][0] = value

func get_tile_contents(tile_x, tile_y):
	var tile = array_search(tile_x, tile_y)
	return tile[2][0]

func get_tile_display(tile_x, tile_y):
	var tile = array_search(tile_x, tile_y)
	return tile[2][1]

func array_search(tile_x, tile_y):
	for tile in tile_array:
		if tile[0] == tile_x and tile[1] == tile_y:
			return tile
	return "to be honest i have no fucking idea why i need to return this to make this work but i'm just gonna leave it here and hope it will be alright"

func valid_position(tile_x, tile_y):
	if tile_x <= 0 or tile_y <= 0 or tile_x > board_size or tile_y > board_size:
		return false
	else:
		return true

func count_mines(adjacent_tile_array):
	var mines_found = 0
	for tile in adjacent_tile_array:
		var final_tile = get_tile_contents(tile[0], tile[1])
		if final_tile == "tile_mine":
			mines_found += 1
	return mines_found
