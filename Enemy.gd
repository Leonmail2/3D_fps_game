extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
enum {
	IDLE = 0,
	ALERT = 1,
	SHOOTING = 2,
	SEARCHING = 3,
}

var state = IDLE
var player_visible = false
export var detection_radius = 40

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

# Called when the node enters the scene tree for the first time.
func _ready():
	$RayCastLineOfSight.add_exception($EnemyHitDetector)

func shoot():
	var bullet = preload("res://Bullet.tscn").instance()
	get_node('/root/3DShooter').add_child(bullet)
	bullet.global_transform = $Gun/BulletSpawner.get_global_transform()
	bullet.damage = 15
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#$MeshInstance.mesh.material.set_shader_param("hitcolor",hitcolor)
	#hitcolor = clamp(hitcolor + 0.5 * delta, 0.0, 1.0)
	
		


func _physics_process(delta):
	var EnemyToPlayer = $"/root/3DShooter/Player".translation - translation
	if EnemyToPlayer.length() < detection_radius:
		$RayCastLineOfSight.cast_to = EnemyToPlayer
		EnemyToPlayer = EnemyToPlayer.normalize()
		if true:
			EnemyToPlayer = EnemyToPlayer * 30
			var target = $RayCastLineOfSight.get_collider()
			if target != null and target.name == "PlayerCollider":
				player_visible = true
				state = ALERT
			else:
				player_visible = false
	match state:
		IDLE:
			pass
		ALERT:
			if path_node < path.size():
				var direction = (path[path_node]-global_transform.origin)
				if direction.length() < 1:
					path_node += 1
				else:
					$Gun.look_at(player.global_transform.origin,Vector3.UP)
					var playerxz = Vector3(player.global_transform.origin.x,global_transform.origin.y,player.global_transform.origin.z)
					look_at(playerxz,Vector3.UP)
					velocity = direction.normalized() * speed
		SHOOTING:
			pass
		SEARCHING:
			pass
	velocity.y += -40 * delta
	velocity = move_and_slide(velocity,Vector3.UP)

func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0

func _on_GunTimer_timeout():
	if state == ALERT and player_visible == true:
		shoot()


func _on_MoveTimer_timeout():
	move_to(player.global_transform.origin)
