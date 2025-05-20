#@tool
extends Node
#
#class_name habit_tests

@onready var Habit = preload("res://habit.gd")
const SECONDS_IN_A_DAY := 86400

func test_habit_initialization():
	var habit = Habit.new().init("Drink", "Drink some water", 2.0)
	assert(habit.name == "Drink")
	assert(habit.description == "Drink some water")
	assert(habit.goal == 2.0)
	assert(habit.completed_part == 0)
	assert(!habit.is_completed)
	assert(habit.streak == 0)
	assert(habit.last_completed == habit._normalize_unix(0))

func test_get_progress():
	var habit = Habit.new().init("Drink", "", 2.0)
	habit.completed_part = 0.5
	assert(habit.get_progress() == 0.25)
	
func test_complete_habit():
	var habit = Habit.new().init("Drink", "", 2.0)
	habit.complete_habit(1.0)
	assert(habit.get_progress() == 0.5)
	assert(habit.is_completed == false)
	habit.complete_habit(1.0)
	assert(habit.is_completed == true)
	assert(habit.streak == 1)
	habit.complete_habit(1.0)
	assert(habit.streak == 1)

func test_increment_streak():
	var habit = Habit.new().init("Drink")
	var today = habit._normalize_unix(Time.get_unix_time_from_system())
	var yesterday = today - SECONDS_IN_A_DAY
	habit.last_completed = yesterday
	habit.increment_streak(yesterday)
	assert(habit.streak == 1)
	habit.increment_streak(yesterday - SECONDS_IN_A_DAY)
	assert(habit.streak == 1)

func test_reset_daily():
	var habit = Habit.new().init("Drink")
	habit.completed_part = 1
	habit.is_completed = true
	habit.last_completed = habit._normalize_unix(Time.get_unix_time_from_system() - SECONDS_IN_A_DAY)
	habit.reset_daily()
	assert(habit.completed_part == 0)
	assert(habit.is_completed == false)
