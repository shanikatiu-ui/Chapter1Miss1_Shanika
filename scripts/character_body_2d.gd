extends CharacterBody2D

# === Movement Settings ===
@export var patrol_speed: float = 60.0
@export var chase_speed: float = 120.0
@export var patrol_distance: float = 100.0
@export var detection_range: float = 150.0

# === Internal variables ===
var direction: int = 1
var start_position: Vector2
var player: Node2D = null
var state: String = "patrol"  # can be "patrol", "chase", or "return"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea

func _ready() -> void:
	start_position = global_position
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

func _physics_process(_delta: float) -> void:
	match state:
		"patrol":
			_patrol()
		"chase":
			_chase()
		"return":
			_return_to_patrol()

	move_and_slide()

# === PATROL ===
func _patrol() -> void:
	velocity.x = patrol_speed * direction
	sprite.flip_h = direction < 0

	# Move back and forth between patrol distance
	if global_position.x > start_position.x + patrol_distance:
		direction = -1
	elif global_position.x < start_position.x - patrol_distance:
		direction = 1

# === CHASE ===
func _chase() -> void:
	if player == null:
		state = "return"
		return

	var distance = global_position.distance_to(player.global_position)

	if distance > detection_range * 1.3:
		# Player escaped — go back to patrol
		player = null
		state = "return"
		return

	# Move toward player
	direction = sign(player.global_position.x - global_position.x)
	velocity.x = chase_speed * direction
	sprite.flip_h = direction < 0

# === RETURN TO START ===
func _return_to_patrol() -> void:
	var distance = global_position.distance_to(start_position)

	# Move back toward patrol start
	direction = sign(start_position.x - global_position.x)
	velocity.x = patrol_speed * direction
	sprite.flip_h = direction < 0

	# If close enough, resume normal patrol
	if distance < 10:
		state = "patrol"

# === DETECTION ===
func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		player = body
		state = "chase"

func _on_body_exited(body: Node) -> void:
	if body == player:
		# Don’t instantly stop — let _chase handle the transition
		pass
