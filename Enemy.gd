extends KinematicBody

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
enum {
	IDLE = 0,
	ALERT = 1,
	SHOOTING = 2,
	SEARCHING_COVER = 3,
	IN_COVER = 4,
	SHOOTING_COVER = 5,
}

export var state = IDLE
var player_visible = true
export var detection_radius = 100
export var field_of_view = 60
export var cover_node_loc = "../NavMesh/Cover/"
onready var cover = get_node(cover_node_loc)

export var enemy_type = "Dummy"
export var health = 100
export var speed = 10

var path = []
var path_node = 0

onready var nav = get_parent()
onready var player = $'../../../Player'
onready var raycastSight = $EnemyElements/RayCastLineOfSight
onready var gun = $EnemyElements/Gun
onready var hitDetector = $EnemyElements/EnemyHitDetector
#var hitcolor = 1.0

var velocity = Vector3()

func die(vector):
	var body = $EnemyElements/RigidBody
	var trans = body.get_global_transform()
	$EnemyElements.remove_child($EnemyElements/RigidBody)
	get_node("../../../").add_child(body)
	body.linear_velocity = vector - Vector3(0,20,0)
	body.angular_velocity = Vector3()
	body.global_transform = trans
	queue_free()

func hit(damage,vector):
	health = clamp(health - damage,0,100)
	print(health)
	#hitcolor = 0.0
	if health == 0:
		die(vector)

# Called when the node enters the scene tree for the first time.
func _ready():
	#transform.basis = Basis()
	raycastSight.add_exception(hitDetector)
	raycastSight.set_as_toplevel(true)
	$GunTimer.wait_time = randf()+0.2
	

func shoot():
	var bullet = preload("res://Bullet.tscn").instance()
	get_node('/root/3DShooter').add_child(bullet)
	bullet.global_transform = gun.get_node("BulletSpawner").get_global_transform()
	bullet.damage = 15


func set_state(new_state):
	if new_state == ALERT:
		state = ALERT
		$GunTimer.start(0.8)
		$ShootingTimer.stop()
		$CoverTimer.stop()
	if new_state == SEARCHING_COVER:
		state = SEARCHING_COVER
		$GunTimer.stop()
		$ShootingTimer.stop()
		$CoverTimer.stop()
	if new_state == IN_COVER:
		$GunTimer.stop()
		state = IN_COVER
		velocity = Vector3()
		$CoverTimer.start(2+rand_range(0.0,2.0))
		print("here")
	if new_state == SHOOTING_COVER:
		$GunTimer.start(0.2)
		$ShootingTimer.start(1+rand_range(0.0,0.5))
		state = SHOOTING_COVER

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#$MeshInstance.mesh.material.set_shader_param("hitcolor",hitcolor)
	#hitcolor = clamp(hitcolor + 0.5 * delta, 0.0, 1.0)
	
		
func look_at_player():
	gun.look_at(player.global_transform.origin,Vector3.UP)
	var playerxz = Vector3(player.global_transform.origin.x,global_transform.origin.y,player.global_transform.origin.z)
	look_at(playerxz,Vector3.UP)

func _physics_process(delta):
	if health > 0:
		match state:
			IDLE:
				var player_dir = player.transform.origin - transform.origin
				if player_dir.length() < detection_radius:
					raycastSight.look_at_from_position(transform.origin,player.global_transform.origin,Vector3.UP)
					var object = raycastSight.get_collider()
					if object != null and object.name == "PlayerCollider":
						player_dir = player_dir.normalized()
						if rad2deg(acos(player_dir.dot(-transform.basis.z)))<field_of_view:
							set_state(SEARCHING_COVER)
			ALERT:
				if path_node < path.size():
					var direction = (path[path_node]-global_transform.origin)
					if direction.length() < 1:
						path_node += 1
					else:
						look_at_player()
						velocity = direction.normalized() * speed
				$EnemyElements.global_transform = $EnemyElements.global_transform.interpolate_with($PositionCenter.global_transform,10*delta)			
			SEARCHING_COVER:
				if path_node < path.size():
					var direction = (path[path_node]-global_transform.origin)
					if direction.length() < 1:
						path_node += 1
					else:
						look_at_player()
						velocity = direction.normalized() * speed
					if (cover.transform.origin - transform.origin).length() < 3:
						set_state(IN_COVER)
			IN_COVER:
				look_at_player()
				raycastSight.look_at_from_position(transform.origin,player.global_transform.origin,Vector3.UP)
				$EnemyElements.global_transform = $EnemyElements.global_transform.interpolate_with($PositionCenter.global_transform,5*delta)
			SHOOTING_COVER:
				look_at_player()
				$EnemyElements.global_transform = $EnemyElements.global_transform.interpolate_with(cover.get_node("CoverRight").global_transform,5*delta)
		velocity.y += -30 * delta
		velocity = move_and_slide(velocity,Vector3.UP)
		if health < 40:
			set_state(ALERT)

func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0

func _on_MoveTimer_timeout():
	if state == ALERT:
		move_to(player.global_transform.origin)
	elif state == SEARCHING_COVER:
		move_to(cover.global_transform.origin)

func _on_GunTimer_timeout():
	shoot()


func _on_CoverTimer_timeout():
	raycastSight.look_at_from_position(transform.origin,player.global_transform.origin,Vector3.UP)
	var object = raycastSight.get_collider()
	if object != null and object.name == "PlayerCollider":
		set_state(ALERT)
	else:
		set_state(SHOOTING_COVER)

func _on_ShootingTimer_timeout():
	set_state(IN_COVER)
