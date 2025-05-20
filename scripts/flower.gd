extends Node3D

@onready var bamboo_scene = preload("uid://ikldws3unncx")
@onready var bamboo_height

var stage = 0
var rotation_speed = 0.1

func _ready() -> void:
	bamboo_height = get_segment_height(bamboo_scene)

func add_stage(amount: int) -> void:
	print("Growing")
	for i in range(amount):
		var bamboo = bamboo_scene.instantiate()
		bamboo.position = Vector3(0, 0.6 + stage*bamboo_height, 0)	
		add_child(bamboo)
		stage += 1
	
func get_segment_height(scene: PackedScene) -> float:
	var instance = scene.instantiate()
	var mesh_node = instance.get_node("Cylinder")  # adjust if needed
	var aabb = mesh_node.mesh.get_aabb()
	var height = aabb.size.y * mesh_node.scale.y
	instance.queue_free()
	return height

func _process(delta: float) -> void:
	self.rotation.y = lerp_angle(self.rotation.y, self.rotation.y + rotation_speed, delta)
