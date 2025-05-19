extends Resource
class_name Habit

@export var name:String = "sample_habit"
@export var description:String = "sample_description"
@export var is_completed:bool = false
@export var streak:int = 0
@export var last_completed:int = 0




func complete_habit():		# if someone completes a habit, trigger this		**STREAK IMPLEMENTED
	var curr_date := Time.get_unix_time_from_system()
	curr_date = _normalize_unix(curr_date)
	if last_completed != curr_date:
		is_completed = true
		var previous_date := curr_date - 86400
		if last_completed == previous_date:
			streak += 1
		else:
			streak = 1
		last_completed = curr_date
	else:
		print("You've already done this Habit today!")

func reset_daily():			# reset at midnight for streak
	var curr_date := Time.get_unix_time_from_system()
	curr_date = _normalize_unix(curr_date)
	if last_completed != curr_date:
		is_completed = false


func _normalize_unix(unix_time: int) -> int:		# normalize date to 00:00 at midnight, for consistency and simplicity
	var date := Time.get_datetime_dict_from_unix_time(unix_time)
	date["hour"] = 0
	date["minute"] = 0
	date["second"] = 0
	return Time.get_unix_time_from_datetime_dict(date)
