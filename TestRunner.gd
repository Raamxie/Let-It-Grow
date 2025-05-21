extends Node

@onready var HabitTests = preload("res://habit_tests.gd")

func _ready():
	var tests = HabitTests.new()
	add_child(tests)
	
	print("Running habit_tests.gd ...")
	
	tests.test_habit_initialization()
	tests.test_get_progress()
	tests.test_complete_habit()
	tests.test_increment_streak()
	tests.test_reset_daily()
	
	print("Tests completed.")
