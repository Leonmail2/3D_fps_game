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
}

export var state = IDLE
var player_visible = true
export var detection_radius = 30
export var field_of_view = 60

export var enemy_type = "Dummy"
export var health = 100
export var speed = 10

var path = []
var path_node = 0

onready var nav = get_parent()
onready var player = $"../../../Player"
#var hitcolor = 1.0

var velocity = Vector3()

func die():
	queue_free()

func hit(damage):
	health = clamp(health - damage,0,100)
	print(health)
	#hitcolor = 0.0
	if health == 0:
		die()
	set_state(ALERT)

# Called when the node enters the scene tree for the first time.
func _ready():
	#transform.basis = Basis()
	$RayCastLineOfSight.add_exception($EnemyHitDetector)
	$RayCastLineOfSight.set_as_toplevel(true)
	$GunTimer.wait_time = randf()+0.2
	

func shoot():
	var bullet = preload("res://Bullet.tscn").instance()
	get_node('/root/3DShooter').add_child(bullet)
	bullet.global_transform = $Gun/BulletSpawner.get_global_transform()
	bullet.damage = 15


func set_state(new_state):
	if new_state == ALERT:
		state = ALERT
		$GunTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#$MeshInstance.mesh.material.set_shader_param("hitcolor",hitcolor)
	#hitcolor = clamp(hitcolor + 0.5 * delta, 0.0, 1.0)
	
		
func look_at_player():
	$Gun.look_at(player.global_transform.origin,Vector3.UP)
	var playerxz = Vector3(player.global_transform.origin.x,global_transform.origin.y,player.global_transform.origin.z)
	look_at(playerxz,Vector3.UP)

func _physics_process(delta):
	if state != ALERT:
		var player_dir = $'../../../Player'.transform.origin - transform.origin
		if player_dir.length() < detection_radius:
			$RayCastLineOfSight.look_at_from_position(transform.origin,$'../../../Player'.global_transform.origin,Vector3.UP)
			var object = $RayCastLineOfSight.get_collider()
			if object != null and object.name == "PlayerCollider":
				player_dir = player_dir.normalized()
				if rad2deg(acos(player_dir.dot(-transform.basis.z)))<field_of_view:
					set_state(ALERT)
	match state:
		IDLE:
			pass
		ALERT:
			if path_node < path.size():
				var direction = (path[path_node]-global_transform.origin)
				if direction.length() < 1:
					path_node += 1
				else:
					look_at_player()
					velocity = direction.normalized() * speed
	velocity.y += -30 * delta
	velocity = move_and_slide(velocity,Vector3.UP)

func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0

func _on_MoveTimer_timeout():
	if state == ALERT:
		move_to(player.global_transform.origin)


func _on_GunTimer_timeout():
	shoot()
