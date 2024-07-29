extends RigidBody3D

enum STATE {HELD, FIRING, LANDED}
@export var state: STATE = STATE.LANDED
var type = "hairspray"
@export var fuel = 25.0

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent_node_3d().name == "player_weapons":
		state = STATE.HELD


func _process(delta):
	if state == STATE.FIRING:
		fuel -= delta
		if fuel <= 0.0:
			state = STATE.HELD
			fire()


func _physics_process(_delta):
	if state == STATE.HELD:
		freeze = true


func fire():
	if state != STATE.FIRING and fuel > 0.0:
		state = STATE.FIRING
		$AnimationPlayer.play("spray")
	else:
		state = STATE.HELD
		if fuel > 0.0:
			$AnimationPlayer.play_backwards("spray")
		else:
			$AnimationPlayer.play("RESET")


func _on_pickup_body_entered(body): # This area only detects the player layer
	if state == STATE.LANDED:
		body.gain_weapon(type)
		queue_free()
