extends CharacterBody2D
class_name FollowEnemy

@export var speed: float = 40.0
@export var stun_duration: float = 2.0
@export var wall_pause_duration: float = 1.0

# Delay before starting death animation
@export var death_start_delay: float = 0.3

var health: float = 1.0
var is_stunned: bool = false
var is_waiting: bool = false
var direction: int = 1
var is_dead: bool = false


func _ready() -> void:
	# --- Connect HitBox signal (Area2D collisions only) ---
	if has_node("HitBox"):
		var hitbox = $HitBox
		if hitbox.has_signal("area_entered"):
			hitbox.area_entered.connect(_on_area_entered)
	else:
		push_error("Missing HitBox node under FollowEnemy!")

	# --- Connect StunTimer ---
	if has_node("StunTimer"):
		$StunTimer.timeout.connect(_on_stun_timer_timeout)
	else:
		push_error("Missing StunTimer node under FollowEnemy!")

	# --- Create WallTimer if not present ---
	if !has_node("WallTimer"):
		var wall_timer = Timer.new()
		wall_timer.name = "WallTimer"
		wall_timer.wait_time = wall_pause_duration
		wall_timer.one_shot = true
		add_child(wall_timer)
		wall_timer.timeout.connect(_on_wall_timer_timeout)


func _physics_process(_delta: float) -> void:
	if is_dead:
		return

	if is_stunned or is_waiting:
		velocity = Vector2.ZERO
	else:
		velocity.x = direction * speed

	# 🌀 Flip sprite depending on direction
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.flip_h = direction < 0

	# ⚡ Flip KillZone, HitBox, and CollisionShapes
	_flip_collisions()

	move_and_slide()


func _flip_collisions() -> void:
	# Flip KillZone and HitBox scales to face movement direction
	if has_node("Killzone"):
		$Killzone.scale.x = direction
	if has_node("HitBox"):
		$HitBox.scale.x = direction

	# Flip any direct CollisionShape2D under this node
	for shape in get_children():
		if shape is CollisionShape2D:
			shape.scale.x = direction

	# Flip any CollisionShape2D inside KillZone or HitBox
	if has_node("Killzone/CollisionShape2D"):
		$Killzone/CollisionShape2D.scale.x = direction
	if has_node("HitBox/CollisionShape2D"):
		$HitBox/CollisionShape2D.scale.x = direction


# --- Damage and death ---
func take_damage(weapon_damage: float):
	if is_dead:
		return
	
	health -= weapon_damage

	if health <= 0.0:
		die()


func die():
	if is_dead:
		return
	
	is_dead = true
	
	# Delay before starting the death animation
	await get_tree().create_timer(death_start_delay).timeout

	if has_node("AnimatedSprite2D"):
		var sprite = $AnimatedSprite2D
		sprite.play("death")
		await sprite.animation_finished

	queue_free()


# --- Wall pause behavior ---
func _on_hit_wall() -> void:
	if is_dead:
		return

	is_waiting = true
	velocity = Vector2.ZERO

	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("idle")

	$WallTimer.start(wall_pause_duration)


func _on_wall_timer_timeout() -> void:
	if is_dead:
		return

	direction *= -1
	is_waiting = false

	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("walk")


# --- Detect collision with thrown or wall Areas ---
func _on_area_entered(area: Area2D) -> void:
	if area == null or is_dead:
		return

	# ✅ If it's a thrown object with a HitArea (like cupping)
	if area.name == "HitArea":
		print("💥 Enemy hit by thrown object (HitArea):", area.get_parent().name)
		start_stun_phase()
		if area.get_parent().has_method("queue_free"):
			area.get_parent().queue_free()  # safely remove thrown object
		return

	# ✅ If it's *any* other Area2D (like wall or sensors)
	if not is_waiting:
		print("Enemy touched Area2D:", area.name)
		_on_hit_wall()
	else:
		print("Ignored Area2D:", area.name)


# --- Stun logic ---
func start_stun_phase() -> void:
	if is_stunned or is_dead:
		return

	is_stunned = true
	print("😵 Enemy stunned!")

	velocity = Vector2.ZERO
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("stunned")

	$StunTimer.start(stun_duration)


func _on_stun_timer_timeout() -> void:
	if is_dead:
		return

	is_stunned = false
	print("🧠 Enemy recovered!")
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("walk")
