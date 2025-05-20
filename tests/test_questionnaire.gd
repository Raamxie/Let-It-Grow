extends "res://addons/gut/test.gd"

class_name Questionnare

var questionnaire_scene
var instance

func before_each():
	questionnaire_scene = load("res://scenes/questionnaire.tscn")
	instance = questionnaire_scene.instantiate()
	add_child(instance)
	await get_tree().process_frame

func after_each():
	instance.queue_free()

func test_default_state():
	assert_eq(instance.selected_sex, "male")
	assert_true(instance.male_button.button_pressed)
	assert_false(instance.female_button.button_pressed)

func test_toggle_sex_to_female():
	instance._on_sex_button_pressed("female")
	assert_eq(instance.selected_sex, "female")
	assert_true(instance.female_button.button_pressed)
	assert_false(instance.male_button.button_pressed)

func test_water_recommendation_calculation():
	instance.weight_input.text = "75"
	instance.selected_sex = "male"
	instance.update_water_recommendation()
	await get_tree().process_frame
	assert_string_contains(instance.rec_label.text, "Recommended: 3.0 L")

	instance._on_sex_button_pressed("female")
	instance.weight_input.text = "75"
	instance.update_water_recommendation()
	await get_tree().process_frame
	assert_string_contains(instance.rec_label.text, "Recommended: 2.5 L")

func test_apply_water_recommendation_sets_input():
	instance.weight_input.text = "80"
	instance.selected_sex = "male"
	instance.apply_water_recommendation()
	await get_tree().process_frame
	assert_eq(instance.water_input.text, "3.2")

func test_save_user_preferences_stores_correct_data():
	instance.weight_input.text = "70"
	instance.calorie_input.text = "2500"
	instance.water_input.text = "2.3"
	instance.selected_sex = "female"

	instance.save_user_preferences()

	assert_eq(instance.user_data.weight, 70.0)
	assert_eq(instance.user_data.calorie_goal, 2500)
	assert_eq(instance.user_data.water_goal, 2.3)
	assert_false(instance.user_data.is_male)
