extends Node

var messages_control = Control.new()
var messagebox_standard_scene = preload("res://scenes/ui/message.tscn")
var messagebox_standard
var messagebox_standard_title_label

func _ready():
	pass

func show_standard_messagebox(title, message, button_text, button_function):
	messagebox_standard = messagebox_standard_scene.instantiate()
	var title_label = messagebox_standard.get_node("MessagePanel/Title")
	title_label.text = title
	var message_label = messagebox_standard.get_node("MessagePanel/Content")
	message_label.text = message
	var button = messagebox_standard.get_node("MessagePanel/Button")
	button.text = button_text
	button.button_down.connect(button_function)
	get_node("/root/Main/CanvasLayer/Messages").add_child(messagebox_standard)

func delete_messageboxes():
	for child in get_node("/root/Main/CanvasLayer/Messages").get_children():
		child.queue_free()
	await get_tree().process_frame
