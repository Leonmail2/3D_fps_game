extends KinematicBody
signal player_health_changed
signal player_just_damaged

enum {
	IDLE = 0,
	ALERT = 1,
	SHOOTING = 2,
	SEARCHING_COVER = 3,
	IN_COVER = 4,
	SHOOTING_COVER = 5,
}


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var health = 100
export var MAX_HEALTH = 100
export var PLAYER_SPEED = 25;
export var MAX_SPEED = 9999;
export var ACCELERATION = 8;
export var DEACCELERATION = 10;
export var gravity = -60
export var mouse_sensitivity = 0.001;

var air_time = 0
var velocity = Vector3.ZERO
var movement = Vector3()
var camera_direction = Vector2()

var charge_target = null
var charging = false
var charge_cooldown = 100


func die():
	health = 0
	$Head/DeathCamera.current = true
	

func hit(damage):
	if charging == false:
		health = clamp(health - damage,0.0,MAX_HEALTH)
		print(health)
		$Head/Camera/GunManager.health = health
		emit_signal("player_just_damaged",health)

func heal(hp):
	health = clamp(health+hp,0.0,MAX_HEALTH)
	print(health)
	$Head/Camera/GunManager.health = health
	get_node("HUD/Data/Health").text = str(health)
	get_node("HUD/Data/Heal/AnimationPlayer").play("Heal") # healing vfx
	
	get_node("HUD/Data/Healing").text = "+" + str(hp)
	get_node("HUD/Data/Healing/AnimationPlayer").play("HealingAnimation") # healing health numbers vfx

func check_health():
	health = clamp(health,0,MAX_HEALTH)
	if health == 0:
		die()

func get_movement_input():
	movement = Vector3()
	var camera_basis = $Head.get_global_transform().basis
	if(Input.is_action_pressed("ui_up")):
		movement += camera_basis.z;
	if(Input.is_action_pressed("ui_down")):
		movement -= camera_basis.z;
	if(Input.is_action_pressed("ui_left")):
		movement += get_global_transform().basis.x;
	if(Input.is_action_pressed("ui_right")):
		movement -= get_global_transform().basis.x;
	$Head/Camera/GunManager.movement = movement.normalized()
	return movement.normalized()

func _ready():
	emit_signal("player_health_changed",health)

func _physics_process(delta):
	check_health()
	if health != 0:
		if charging == false:
			charge_cooldown = clamp(charge_cooldown+(delta*10),0,100)
			$HUD.update_charge_bar(charge_cooldown)
			movement = get_movement_input()
			velocity.y += gravity * delta
			if is_on_floor():
				if velocity.x < 1.5 and velocity.x > -1.5 and velocity.z < 1.5 and velocity.z > -1.5:
					velocity.x = 0
					velocity.z = 0
					velocity.y = 0
				if movement != Vector3(0,0,0):
					velocity = lerp(velocity,movement*PLAYER_SPEED,delta*ACCELERATION)
				else:
					velocity = lerp(velocity,movement*PLAYER_SPEED,delta*DEACCELERATION)
			if is_on_floor() and Input.is_key_pressed(KEY_SPACE):
				velocity.y = 25
			velocity = move_and_slide(velocity,Vector3.UP)
			if is_on_floor():
				air_time = 0
			else:
				air_time += delta
		if Input.is_key_pressed(KEY_Q) and charge_cooldown == 100:
			var cast = $Head/Camera/GunManager/RayCast.get_collider()
			if cast != null and cast.name == "EnemyHitDetector":
				charge_target = cast.get_node("../..")
				if charge_target.state != IN_COVER or charge_target.state != SHOOTING_COVER:
					$Head/Camera/GunManager.guns_enabled = false
					$ChargeTimer.start()
					charging = true
					charge_cooldown = 0
		if charging == true:
			$Head/Camera.look_at(charge_target.get_node("EnemyElements/HeadLoc").global_transform.origin,Vector3.UP)
			$Head/Camera.rotate_object_local(Vector3(0,1,0), PI)
			transform = transform.interpolate_with(charge_target.global_transform,4*delta)
			if (charge_target.global_transform.origin - global_transform.origin).length() < 8:
				charge_target.hit(3000,$Head/Camera.global_transform.basis.z * 50)
				charging = false
				charge_target = null
				$Head/Camera/GunManager.guns_enabled = true

func _on_ChargeTimer_timeout():
	$Head/Camera/GunManager.guns_enabled = true
	charging = false
	charge_target = null
	velocity = Vector3()

func _input(event): 
	if event is InputEventMouseMotion and charging == false:
		camera_direction.x += -event.relative.x*mouse_sensitivity
		camera_direction.y += event.relative.y*mouse_sensitivity
		camera_direction.y = clamp(camera_direction.y,-1.5,1.55)
		transform.basis = Basis()
		$Head/Camera.transform.basis = Basis()
		rotate_object_local(Vector3(0,1,0),camera_direction.x)
		$Head/Camera.rotate_object_local(Vector3(1,0,0),camera_direction.y)
		transform = transform.orthonormalized()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


