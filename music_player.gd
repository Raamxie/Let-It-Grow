extends Node
var player: AudioStreamPlayer

func _ready() -> void:
	player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = load("res://audio/gentle-ambient-atmosphere.ogg")
	player.volume_db = -10
	player.loop = true
	player.play()
