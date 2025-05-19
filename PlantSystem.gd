extends Node


const Habit := preload("res://Habit.gd")

# --- tuning constants ---
const SAVE_PATH := "..."
const DAILY_GOAL_ML := 2000		# default; should get adjusted from onboarding
const HEALTH_GAIN := 5		# health +5 on great day (>= 85 %)
const HEALTH_LOSS := 10		# health –10 on bad day (< 60 %)
const HEALTH_THRESHOLD_GROW := 70		# min health to count as a "good" care day
const SCORE_GOOD := 90		# daily score >= 90 % -> great day
const SCORE_BAD := 60		# daily score < 60 % -> bad day

# --- runtime state ---
var growth_days: int = 0
var health: int = HEALTH_THRESHOLD_GROW		# start at 70 so first failure stalls growth
var last_update: Dictionary = {}		# date dict {year,month,day,…}

# --- habits ---
var hydration: Habit

func _ready() -> void:
	_load_state()
	_check_midnight_transition()

# --- current local date helper function ---
func _current_date() -> Dictionary:
	return Time.get_datetime_dict_from_system()

# ---  ---
# adds water intake to the hydration habit and saves current state
func log_water(amount_ml: int) -> void:
	hydration.complete_habit(amount_ml)
	_save_state()

# returns todays hydration percentage
func get_daily_score() -> float:
	return hydration.get_progress() * 100.0

func get_stage() -> String:
	if health == 0:
		return "dead"
	var age_stage := _age_band(growth_days)
	var health_stage := _health_band(health)
	return "%s_%s" % [age_stage, health_stage]

func reset() -> void:
	growth_days = 0
	health = HEALTH_THRESHOLD_GROW
	last_update = _current_date()
	hydration.reset_daily()
	_save_state()

# --- utility band helpers ---
func _age_band(days: int) -> String:
	if days < 2:
		return "sprout"
	elif days < 4:
		return "seedling"
	elif days < 6:
		return "bud"
	else:
		return "bloom"

func _health_band(h: int) -> String:
	if h >= HEALTH_THRESHOLD_GROW:
		return "healthy"
	elif h >= 30:
		return "wilting"
	else:
		return "wilted"

# --- midnight growth logic ---
func _check_midnight_transition() -> void:
	var now_date := _current_date()
	if last_update.is_empty():
		last_update = now_date
		return
	if now_date["year"] != last_update["year"] \
	or now_date["month"] != last_update["month"] \
	or now_date["day"] != last_update["day"]:
		_nightly_update()
		last_update = now_date
		_save_state()

func _nightly_update() -> void:
	var score := get_daily_score()
	if score >= SCORE_GOOD:
		health = min(100, health + HEALTH_GAIN)
	elif score < SCORE_BAD:
		health = max(0, health - HEALTH_LOSS)
	if health >= HEALTH_THRESHOLD_GROW:
		growth_days += 1
	hydration.reset_daily()

# --- persistence ---
func _save_state() -> void:
	var data := {
		"growth_days": growth_days,
		"health": health,
		"last_update": last_update,
		"habit" : {
			"goal": hydration.goal,
			"completed_part": hydration.completed_part,
			"streak": hydration.streak,
			"last_completed": hydration.last_completed
		}
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func _load_state() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		last_update = _current_date()
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var txt := file.get_as_text()
		file.close()
		var data: Variant = JSON.parse_string(txt)
		if data is Dictionary:
			growth_days = data.get("growth_days", 0)
			health = data.get("health", HEALTH_THRESHOLD_GROW)
			last_update = data.get("last_update", _current_date())
			var h = data.get("habit", {})
			hydration.goal = h.get("goal", DAILY_GOAL_ML)
			hydration.completed_part = h.get("completed_part", 0)
			hydration.streak = h.get("streak", 0)
			hydration.last_completed = h.get("last_completed", 0)
		else:
			push_warning("Savegame corrupted or wrongly formatted.")
			reset()
