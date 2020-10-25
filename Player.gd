extends KinematicBody
signal player_health_changed
signal player_just_damaged
signal ammo_change
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var health = 100
export var MAX_HEALTH = 100
export var PLAYER_SPEED = 25;
export var MAX_SPEED = 9999;
export var ACCELERATION = 8;
export var DEACCELERATION = 10;
export var gravity = -50
export var mouse_sensitivity = 0.001;

var velocity = Vector3.ZERO
var movement = Vector3()
var camera_direction = Vector2()

var reloading = false
var play_walk_anim = false

var anim_pistol_state = ""
var can_shoot_pistol = true
var pistol_clip = 15
export var max_pistol_clip = 15
export var pistol_ammo = 20
export var max_pistol_ammo = 20

const pistol_cooldown_length = 0.4
const pistol_reload_length = 1

var anim_shotgun_state = ""
var can_shoot_shotgun = true
var shotgun_clip = 5
export var max_shotgun_clip = 5
export var shotgun_ammo = 27
export var max_shotgun_ammo = 50

const shotgun_cooldown_length = 0.8
const shotgun_reload_length = 0.4

func die():
	health = 0
	$Head/DeathCamera.current = true
	

func hit(damage):
	health = clamp(health - damage,0.0,100)
	print(health)
	emit_signal("player_just_damaged",health)

func heal(hp):
	health = clamp(health+hp,0.0,100)
	print(health)
	emit_signal("player_health_changed",health)

func check_health():
	health = clamp(health,0,MAX_HEALTH)
	if health == 0:
		die()
	
func _on_PistolTimer_timeout():
	can_shoot_pistol = true
	anim_pistol_state = ""

func _on_HitSoundDelay_timeout():
	$Head/Camera/Gun/Hit.play()

func shootPistol():
	var target = $Head/Camera/RayCast.get_collider()
	if(can_shoot_pistol == true and pistol_clip > 0):
		pistolAnimationHandler("Cooldown")
		pistol_clip = clamp(pistol_clip - 1,0,max_pistol_clip)
		emit_signal("ammo_change",pistol_ammo,pistol_clip)
		$Head/Camera/Gun/Shot.play()
		if(target != null and target.name == "EnemyHitDetector"):
			target.get_parent_spatial().hit(34)
			$Timers/HitSoundDelay.start()

func shootShotgun():
	var target = $Head/Camera/RayCast.get_collider()
	if(can_shoot_shotgun == true and shotgun_clip > 0):
		pistolAnimationHandler("Cooldown")
		shotgun_clip = clamp(shotgun_clip - 1,0,max_shotgun_clip)
		emit_signal("ammo_change",shotgun_ammo,shotgun_clip)
		$Head/Camera/Gun/Shot.play()
		

func reloadPistol():
	if(pistol_ammo>0 and pistol_clip != max_pistol_clip and reloading == false and can_shoot_pistol == true):
		$Timers/PistolReloadTimer.start(pistol_reload_length)
		$Head/Camera/Gun/Reload.play()
		pistolAnimationHandler("Reload")
		reloading = true
	else:
		print("No ammo!")
	
func _on_PistolReloadTimer_timeout():
	if pistol_ammo > 0:
		var new_ammo = clamp(pistol_ammo - (max_pistol_clip - pistol_clip),0.0,max_pistol_ammo)
		pistol_clip = clamp(pistol_ammo,0.0,max_pistol_clip)
		pistol_ammo = clamp(new_ammo,0,max_pistol_ammo)
		emit_signal("ammo_change",pistol_ammo,pistol_clip)
	reloading = false


func pistolAnimationHandler(anim):
	if anim_pistol_state == "":
		if anim == "Running":
			$Head/Camera/Gun/AnimationPlayer.play("Gun|WalkCycle",0.01,1)
		elif anim == "Cooldown":
			$Timers/PistolTimer.start(pistol_cooldown_length)
			can_shoot_pistol = false
			anim_pistol_state = "ReloadInProgress"
			$Head/Camera/Gun/AnimationPlayer.play("Gun|Reload",-2,-3,true)
			$Head/Camera/Gun/MuzzleParticles.emitting = true
			$Head/Camera/Gun/ShellParticles.emitting = true
		elif anim == "Reload":
			$Timers/PistolTimer.start(pistol_reload_length)
			can_shoot_pistol = false
			anim_pistol_state = "ReloadInProgress"
			$Head/Camera/Gun/AnimationPlayer.play("Gun|Reload",0.4,1)
		else:
			$Head/Camera/Gun/AnimationPlayer.play("Gun|Idle",0.2,1.2)
	elif anim_pistol_state == "ReloadInProgress":
		pass
		
func reloadHandler():
	reloadPistol()

func get_movement_input():
	movement = Vector3()
	var camera_basis = $Head.get_global_transform().basis
	if(Input.is_action_pressed("ui_up")):
		movement -= camera_basis.z;
	if(Input.is_action_pressed("ui_down")):
		movement += camera_basis.z;
	if(Input.is_action_pressed("ui_left")):
		movement -= get_global_transform().basis.x;
	if(Input.is_action_pressed("ui_right")):
		movement += get_global_transform().basis.x;
	return movement.normalized()

func get_keyboard_input():
	if(Input.is_key_pressed(KEY_R)):
		reloadHandler()


func _ready():
	emit_signal("ammo_change",pistol_ammo,pistol_clip)

func _physics_process(delta):
	check_health()
	get_keyboard_input()
	if health != 0:
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
		
		
		
		print(velocity)
		velocity = move_and_slide(velocity,Vector3.UP)
		if is_on_floor() and Input.is_key_pressed(KEY_SPACE):
			velocity.y = 25
		
		play_walk_anim = false
		if movement.x != 0 or movement.z != 0:
			play_walk_anim = true
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			shootPistol()
		elif play_walk_anim:
			pistolAnimationHandler("Running")
		else:
			pistolAnimationHandler("Idle")
		
	
func _input(event):
	if event is InputEventMouseMotion:
		camera_direction.x += -event.relative.x*mouse_sensitivity
		camera_direction.y += -event.relative.y*mouse_sensitivity
		camera_direction.y = clamp(camera_direction.y,-1.5,1.55)
		transform.basis = Basis()
		$Head/Camera.transform.basis = Basis()
		rotate_object_local(Vector3(0,1,0),camera_direction.x)
		$Head/Camera.rotate_object_local(Vector3(1,0,0),camera_direction.y)
		transform = transform.orthonormalized()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


