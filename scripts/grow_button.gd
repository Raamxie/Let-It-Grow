extends Button

signal grow

func _pressed() -> void:
	emit_signal("grow")
