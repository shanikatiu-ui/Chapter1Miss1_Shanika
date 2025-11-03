class_name Player
extends CharacterBody2D

# --- Movement Settings ---
@export var SPEED: float = 300.0
@export var JUMP_VELOCITY: float = 400.0 # keep positive, we invert it in code
@export var GRAVITY: float = 1200.0

# --- Player State ---
var state: String = "idle"

# --- Gameplay Variables ---
@export var hide_key := "interact"
var is_hidden := false
var can_hide := false
var current_hiding_object: Area2D = null
var saved_position: Vector2
var haskey: bool = false 

# --- Node References ---
@onready var camera: Camera2D = $Camera2D
@onready var mainplayer_walk: Sprite2D = $RotationNode/mainplayerwalk
@onready var mainplayer_idle: Sprite2D = $RotationNode/mainplayeridle
@onready var animation: AnimationPlayer = $RotationNode/AnimationPlayer
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var rotation_node: Node2D = $RotationNode
@onready var object_marker: Marker2D = $RotationNode/ObjectMarker
@onready var attack_area: Area2D = $AttackArea
@onready var attack_collision: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var pickup_area: Area2D = $PickupArea

var possiblePickupObjects: Array = []
var currentObject

# --- Attack Settings ---
var can_slash: bool = true
var is_attacking: bool = false
@export var slash_time: float = 0.25
@export var sword_return_time: float = 0.4
@export var weapon_damage: float = 1.0


func _ready():
	add_to_group("Player") # ✅ KillZone will only detect this root node

	# ✅ Proper camera activation (fixes "current" error)
	if camera and camera is Camera2D:
		camera.make_current()
	else:
		push_warning("⚠️ Camera2D not found or invalid type in Player scene")

	# Ensure signal connections only once
	if not animation.animation_finished.is_connected(_on_animation_finished):
		animation.animation_finished.connect(_on_animation_finished)

	attack_area.monitoring = false
	attack_collision.disabled = true


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		if currentObject:
			throw_object()
		elif possiblePickupObjects:
			pickup_object()
	elif Input.is_action_just_pressed("attack") and can_slash:
		attack()


# --- Throwing & Pickup ---
func throw_object(): 
	currentObject.reparent(get_tree().current_scene)
	var throwDirection = Vector2(1, -0.3).normalized()
	if mainplayer_walk.flip_h:
		throwDirection.x = -1
	currentObject.throw(throwDirection)
	currentObject = null


func pickup_object():
	currentObject = possiblePickupObjects.pop_front()
	currentObject.global_position = object_marker.global_position
	currentObject.reparent(object_marker)
	currentObject.picked_up()


# --- MOVEMENT SYSTEM (Walk + Jump + Idle) ---
func _physics_process(delta: float) -> void:
	if is_hidden:
		velocity = Vector2.ZERO
		return

	# ✅ Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		if velocity.y > 0:
			velocity.y = 0

	var input_dir: float = Input.get_axis("left", "right")

	# ✅ Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		print("Jump pressed! is_on_floor =", is_on_floor())
		velocity.y = -JUMP_VELOCITY
		state = "jump"

	# ✅ Horizontal movement
	if input_dir != 0.0:
		velocity.x = input_dir * SPEED
		if is_on_floor():
			state = "walk"
	else:
		velocity.x = lerp(velocity.x, 0.0, 0.2)
		if is_on_floor() and velocity.y == 0:
			state = "idle"

	move_and_slide()

	# ✅ Detect landing
	if is_on_floor() and state == "jump":
		state = "idle"

	# ✅ Flip sprite direction and attack area
	if velocity.x != 0.0:
		mainplayer_walk.flip_h = velocity.x < 0.0
		mainplayer_idle.flip_h = velocity.x < 0.0
		_flip_attack_area(sign(velocity.x))

	update_animation()


func update_animation() -> void:
	mainplayer_walk.visible = false
	mainplayer_idle.visible = false

	match state:
		"jump":
			if animation.has_animation("jump"):
				animation.play("jump")
			mainplayer_walk.visible = true
		"walk":
			mainplayer_walk.visible = true
			if animation.has_animation("walk"):
				animation.play("walk")
		"idle":
			mainplayer_idle.visible = true
			if animation.has_animation("idle"):
				animation.play("idle")


# ✅ Flip AttackArea (scale-based, no drift)
func _flip_attack_area(direction: float) -> void:
	if not attack_area:
		return

	if direction < 0:
		attack_area.scale.x = 1.8
	else:
		attack_area.scale.x = 1

	if attack_area.has_node("CollisionShape2D"):
		attack_area.get_node("CollisionShape2D").scale.x = -1


# --- Hide Controls ---
func _process(_delta):
	if Input.is_action_just_pressed(hide_key):
		if can_hide and not is_hidden:
			enter_hide()
		elif is_hidden:
			exit_hide()


# --- Hide System ---
func enter_hide():
	if current_hiding_object == null:
		return
	saved_position = global_position
	is_hidden = true
	mainplayer_walk.visible = false
	mainplayer_idle.visible = false
	collision.disabled = true
	attack_area.monitoring = false
	pickup_area.monitoring = false
	velocity = Vector2.ZERO
	if current_hiding_object.has_node("hide_point"):
		var hide_spot = current_hiding_object.get_node("hide_point")
		global_position = hide_spot.global_position


func exit_hide():
	is_hidden = false
	mainplayer_walk.visible = true
	mainplayer_idle.visible = true
	collision.disabled = false
	attack_area.monitoring = true
	pickup_area.monitoring = true
	global_position = saved_position


# --- Hide Area Detection ---
func _on_area_entered(area):
	if area is InteractionArea:
		can_hide = true
		current_hiding_object = area


func _on_area_exited(area):
	if area == current_hiding_object:
		can_hide = false
		current_hiding_object = null


# --- Pickup Area ---
func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body is GameObject:
		possiblePickupObjects.append(body)


func _on_pickup_area_body_exited(body: Node2D) -> void:
	if body is GameObject:
		possiblePickupObjects.erase(body)


# --- Attack Logic ---
func attack():
	can_slash = false
	is_attacking = true
	if animation.has_animation("attack"):
		animation.play("attack")

	attack_collision.disabled = false
	attack_area.monitoring = true
	print("⚔️ Attack started — AttackArea active!")

	await get_tree().create_timer(0.05).timeout
	print("🗡️ Attack window active")

	await get_tree().create_timer(slash_time).timeout

	attack_area.monitoring = false
	attack_collision.disabled = true
	print("🛑 Attack ended — AttackArea disabled.")

	await animation.animation_finished
	is_attacking = false
	if animation.has_animation("default"):
		animation.play("default")

	await get_tree().create_timer(sword_return_time).timeout
	can_slash = true


func _on_animation_finished():
	if animation.current_animation == "attack" and is_attacking:
		is_attacking = false
		if animation.has_animation("default"):
			animation.play("default")


func _on_attack_area_body_entered(body: Node2D) -> void:
	if is_attacking and body is FollowEnemy:
		print("💥 Enemy hit by attack! ", body.name)
		body.take_damage(weapon_damage)
