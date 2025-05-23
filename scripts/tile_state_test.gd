extends OptionButton

@onready var tile = get_node("/root/Main/Tile")
@onready var tile_covered = preload("res://sprites/tile_covered.png")
@onready var tile_1 = preload("res://sprites/tile_1.png")
@onready var tile_2 = preload("res://sprites/tile_2.png")
@onready var tile_3 = preload("res://sprites/tile_3.png")
@onready var tile_4 = preload("res://sprites/tile_4.png")
@onready var tile_5 = preload("res://sprites/tile_5.png")
@onready var tile_6 = preload("res://sprites/tile_6.png")
@onready var tile_7 = preload("res://sprites/tile_7.png")
@onready var tile_8 = preload("res://sprites/tile_8.png")
@onready var tile_uncovered = preload("res://sprites/tile_uncovered.png")
@onready var tile_mine = preload("res://sprites/tile_mine.png")
@onready var tile_mine_clicked = preload("res://sprites/tile_mine_clicked.png")
@onready var tile_mine_incorrect = preload("res://sprites/tile_mine_incorrect.png")
@onready var tile_flag = preload("res://sprites/tile_flag.png")

var item_id = selected

func _ready():
	set_tile_state(item_id)

func _process(delta):
	item_id = selected
	set_tile_state(item_id)

func set_tile_state(id):
	match id:
		0:
			tile.icon = tile_covered
		1:
			tile.icon = tile_1
		2:
			tile.icon = tile_2
		3:
			tile.icon = tile_3
		4:
			tile.icon = tile_4
		5:
			tile.icon = tile_5
		6:
			tile.icon = tile_6
		7:
			tile.icon = tile_7
		8:
			tile.icon = tile_8
		9:
			tile.icon = tile_uncovered
		10:
			tile.icon = tile_mine
		11:
			tile.icon = tile_mine_clicked
		12:
			tile.icon = tile_mine_incorrect
		13:
			tile.icon = tile_flag
