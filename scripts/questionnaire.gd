extends Control

var user_data = {
	"water_goal": 0.0,
	"calorie_goal": 0,
	"weight": 0.0,
	"is_male": true,
	"day_start_time": "06:00"
}

# Class variables
var weight_input: LineEdit
var water_input: LineEdit
var calorie_input: LineEdit
var male_button: Button
var female_button: Button
var rec_button: Button
var rec_label: Label
var selected_sex: String = "male"  # Default value

func _ready():
	setup_ui()

func setup_ui():
	# Create centered container for everything
	var center_container = CenterContainer.new()
	center_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center_container)
	
	var vbox = VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(600, 0)
	vbox.add_theme_constant_override("separation", 20)
	center_container.add_child(vbox)
	
	# Title and description
	var title = Label.new()
	title.text = "Welcome! Let's set up your goals"
	title.add_theme_font_size_override("font_size", 24)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_FILL
	var panel_vbox = VBoxContainer.new()
	panel_vbox.add_theme_constant_override("separation", 15)
	panel.add_child(panel_vbox)
	vbox.add_child(panel)

	var sex_container = HBoxContainer.new()
	sex_container.size_flags_horizontal = Control.SIZE_FILL
	sex_container.alignment = BoxContainer.ALIGNMENT_CENTER
	
	# Create button container
	var button_container = HBoxContainer.new()
	button_container.add_theme_constant_override("separation", 5)
	
	# Male button
	male_button = Button.new()
	male_button.text = "Male"
	male_button.toggle_mode = true
	male_button.button_pressed = true
	male_button.custom_minimum_size = Vector2(80, 35)
	male_button.pressed.connect(func(): _on_sex_button_pressed("male"))
	button_container.add_child(male_button)
	
	# Female button
	female_button = Button.new()
	female_button.text = "Female"
	female_button.toggle_mode = true
	female_button.button_pressed = false
	female_button.custom_minimum_size = Vector2(80, 35)
	female_button.pressed.connect(func(): _on_sex_button_pressed("female"))
	button_container.add_child(female_button)
	
	sex_container.add_child(button_container)
	panel_vbox.add_child(sex_container)
	
	# Update initial button appearance
	_update_button_appearance()

	# Weight input
	var weight_container = create_input_field("⚖️ Your weight (kg):", "weight")
	panel_vbox.add_child(weight_container)
	weight_input = weight_container.get_node("weight")
	weight_input.text_changed.connect(update_water_recommendation)

	# Water intake field (now shows calculated value)
	var water_container = create_input_field("💧 Daily water intake (liters):", "water_goal")
	panel_vbox.add_child(water_container)
	water_input = water_container.get_node("water_goal")
	rec_label = water_container.get_node("recommendation")

	# Store reference to recommendation button
	var rec_container = HBoxContainer.new()
	rec_container.add_theme_constant_override("separation", 10)
	
	rec_button = Button.new()
	rec_button.name = "rec_button"
	rec_button.text = "Use Recommended Water Intake"
	rec_button.pressed.connect(apply_water_recommendation)
	rec_container.add_child(rec_button)
	panel_vbox.add_child(rec_container)

	# Calorie goal field
	var calorie_container = create_input_field("🍎 Daily calorie goal:", "calorie_goal")
	panel_vbox.add_child(calorie_container)
	calorie_input = calorie_container.get_node("calorie_goal")

	# Save button
	var save_button = Button.new()
	save_button.text = "Save and Continue"
	save_button.custom_minimum_size.y = 40
	save_button.pressed.connect(save_user_preferences)
	save_button.pressed.connect(load_next_level)
	vbox.add_child(save_button)

func create_input_field(label_text: String, data_key: String) -> HBoxContainer:
	var container = HBoxContainer.new()
	container.add_theme_constant_override("separation", 10)
	
	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 200
	container.add_child(label)
	
	var input = LineEdit.new()
	input.name = data_key
	input.custom_minimum_size = Vector2(100, 35)
	input.placeholder_text = "Enter value..."
	container.add_child(input)
	
	if data_key == "water_goal":
		var rec_label = Label.new()
		rec_label.name = "recommendation"
		rec_label.text = "(Recommended: -- L)"
		container.add_child(rec_label)
	
	return container

# Handling button states
func _on_sex_button_pressed(sex: String) -> void:
	selected_sex = sex

	male_button.button_pressed = (sex == "male")
	female_button.button_pressed = (sex == "female")
	
	_update_button_appearance()
	update_water_recommendation()


func _update_button_appearance() -> void:
	# Set colors for selected/unselected states
	var selected_color = Color(0.2, 0.6, 1.0, 1.0)  # Light blue
	var unselected_color = Color(0.5, 0.5, 0.5, 0.5)  # Gray
	
	male_button.modulate = selected_color if selected_sex == "male" else unselected_color
	female_button.modulate = selected_color if selected_sex == "female" else unselected_color


func update_water_recommendation(_unused = "") -> void:
	if !weight_input.text.length() > 0:
		return
		
	if !weight_input.text.is_valid_float():
		return
			
	var weight = float(weight_input.text)
	var multiplier = 0.04 if selected_sex == "male" else 0.033
	var recommended_water = weight * multiplier
	rec_label.text = "(Recommended: %.1f L)" % recommended_water

func save_user_preferences():
	if water_input and calorie_input and weight_input:
		user_data.water_goal = float(water_input.text)
		user_data.calorie_goal = int(calorie_input.text)
		user_data.weight = float(weight_input.text)
		user_data.is_male = (selected_sex == "male")
		print("Saved user preferences:", user_data)

func apply_water_recommendation():
	if weight_input.text.is_empty():
		print("Error: Please enter weight first")
		return
		
	if !weight_input.text.is_valid_float():
		print("Error: Invalid weight value")
		return
			 
	var weight = float(weight_input.text)
	var multiplier = 0.04 if selected_sex == "male" else 0.033
	var recommended_water = weight * multiplier
	water_input.text = "%.1f" % recommended_water
	print("Water recommendation applied: %.1f L" % recommended_water)
	
func load_next_level():
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
