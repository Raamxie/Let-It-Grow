extends Node3D

func _ready():
	$"Gui/CanvasLayer/GridContainer/Button".grow.connect(func(): $Flower.add_stage(1))
