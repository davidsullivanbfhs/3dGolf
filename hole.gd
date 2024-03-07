extends Node3D

@export var next_hole: PackedScene

#states
enum {AIM, SET_POWER, SHOOT, WIN}

@export var power_speed = 100
@export var angle_speed = 1.1
@export var mouse_sensitivty = 152

var angle_change = 1
var power = 0
var power_change = 1
var shots = 0
var state = AIM
var hole_dir


# Called when the node enters the scene tree for the first time.
func _ready():
	$Arrow.hide()
	$Ball.position = $Tee.position
	change_state(AIM)
	$ui.show_message("Get Ready!")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func change_state(new_state):
	state = new_state
	match state:
		AIM:
			$Arrow.position = $Ball.position
			$Arrow.show()
			set_start_angle()
		SET_POWER:
			power = 0
		SHOOT:
			$Arrow.hide()
			$Ball.shoot($Arrow.rotation.y, power/15)
			shots += 1
			$ui.update_shots(shots)
		WIN:
			$Ball.hide()
			$Arrow.hide()
			$ui.show_message("YOU WON!")
			await get_tree().create_timer(1).timeout
			if next_hole:
				get_tree().change_scene_to_packed(next_hole)

func _input(event):
	if event is InputEventMouseMotion:
		if state == AIM:
			$Arrow.rotation.y -= event.relative.x / mouse_sensitivty
	if event.is_action_pressed("ui_cancel") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if event.is_action_pressed("click"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input. mouse_mode = Input.MOUSE_MODE_CAPTURED
			return
		match state:
			AIM:
				change_state(SET_POWER)
			SET_POWER:
				change_state(SHOOT)

func _process(delta):
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		return
	if state != WIN:
		$CameraGimball.position = $Ball.position
	match state:
		#AIM:
		#	animate_arrow(delta)
		SET_POWER:
			animate_power(delta)
		SHOOT:
			pass

func animate_arrow(delta):
	$Arrow.rotation.y += angle_speed * angle_change * delta
	if $Arrow.rotation.y > hole_dir + PI/2:
		angle_change = -1
	if $Arrow.rotation.y < hole_dir - PI/2:
		angle_change = 1

func animate_power(delta):
	power += power_speed * power_change * delta
	if power >= 100:
		power_change = -1
	if power <= 0:
		power_change = 1
	$ui.update_power_bar(power)
	
func set_start_angle():
	var hole_position = Vector2($Area3D_hole.position.z, $Area3D_hole.position.x)
	var ball_position = Vector2($Ball.position.z, $Ball.position.x)
	hole_dir = (ball_position - hole_position).angle()
	$Arrow.rotation.y = hole_dir


func _on_area_3d_hole_body_entered(body):
	if body.name == "Ball":
		print("WIN!")
		change_state(WIN)


func _on_ball_stopped():
	if state == SHOOT:
		change_state(AIM)
