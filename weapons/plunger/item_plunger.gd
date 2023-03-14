extends Node3D

@onready var item = preload("res://weapons/plunger/plunger.tscn").instantiate()
@onready var weapons_node = get_node("/root/World/weapons")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("shoot"):
		item.chucked = true
		weapons_node.add_child(item)
		item.rotation_degrees = Vector3(0, 0, 90)
		item.global_transform = global_transform
		item.apply_impulse(Vector3(0, 5, -25))
		queue_free()
