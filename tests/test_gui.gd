extends "res://addons/gut/test.gd"

class_name TestGuiPanelVisibility

var gui_scene
var instance

func before_each():
	var gui_scene = load("res://scenes/gui.tscn")
	var gui_instance = gui_scene.instantiate()
	add_child(gui_instance)
	await get_tree().process_frame

	instance = gui_instance.get_node("CanvasLayer/PanelContainer")

func after_each():
	instance.queue_free()

func test_show_sets_visible_true():
	instance.visible = false
	instance._show()
	assert_true(instance.visible)

func test_hide_sets_visible_false():
	instance.visible = true
	instance._hide()
	assert_false(instance.visible)

func test_set_visibility_true():
	instance._set_visibility(true)
	assert_true(instance.visible)

func test_set_visibility_false():
	instance._set_visibility(false)
	assert_false(instance.visible)
