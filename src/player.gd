extends Node

class_name Player

var health: int = 100
var max_health: int = 100

func take_damage(amount: int) -> void:
	health = max(health - amount, 0)

func heal(amount: int) -> void:
	health = min(health + amount, max_health)

func is_alive() -> bool:
	return health > 0
