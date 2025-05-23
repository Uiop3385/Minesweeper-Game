extends Camera2D

var drag = 1.0
var external_zoom = 1

# dragging script
func _input(event):
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		position -= event.relative * drag / external_zoom

func _on_h_slider_value_changed(value):
	external_zoom = value
