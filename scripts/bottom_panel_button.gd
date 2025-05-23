extends Button

signal custom_button_pressed(button)

func _ready():
	button_down.connect(emit_custom_button_pressed_signal)

func emit_custom_button_pressed_signal():
	custom_button_pressed.emit(self)
