extends Resource
class_name Habit

@export var name:String = "sample_habit"
@export var description:String = "sample_description"
@export var is_completed:bool = false
@export var streak:int = 0
@export var last_completed:int = 0
@export var goal:float = 1
@export var completed_part:float = 0

const SECONDS_IN_A_DAY := 86400

func init(_name:String, _description:String = "", _goal:float = 1) -> Habit:
	name = _name
	description = _description
	streak = 0
	is_completed = false
	last_completed = _normalize_unix(0)
	completed_part = 0
	goal = _goal
	return self

func complete_habit(part:float = 1.0) -> void:		# if someone completes a habit, trigger this		**STREAK IMPLEMENTED
	completed_part += part
	if completed_part >= goal:
		is_completed = true
		complete_streak()

func get_progress() -> float:
	return completed_part / goal

func complete_streak() -> void:
	var curr_date := _normalize_unix(Time.get_unix_time_from_system())
	if last_completed != curr_date:
		increment_streak(curr_date - SECONDS_IN_A_DAY)
		last_completed = curr_date
	else:
		print("You've already completed this Habit today!")

func increment_streak(previous_date:int) -> void:
	if last_completed == previous_date:
		streak += 1
	else:
		streak = 1

func reset_daily() -> void:			# reset at midnight for streak
	var curr_date := _normalize_unix(Time.get_unix_time_from_system())
	if last_completed != curr_date:	is_completed = false
	completed_part = 0

func _normalize_unix(unix_time: int) -> int:		# normalize date to 00:00 at midnight, for consistency and simplicity
	var date := Time.get_datetime_dict_from_unix_time(unix_time)
	date["hour"] = 0
	date["minute"] = 0
	date["second"] = 0
	return Time.get_unix_time_from_datetime_dict(date)
