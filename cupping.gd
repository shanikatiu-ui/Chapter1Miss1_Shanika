extends CharacterBody2D
class_name GameObject

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export var base_throwforce_x: float = 300.0
@export var base_throwforce_y: float = -250.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()


func picked_up():
	collision_shape_2d.disabled = true
	set_physics_process(false)


func throw(direction: Vector2):
	set_physics_process(true)

	# Ensure direction.x is either -1 (left) or 1 (right)
	var throw_dir = sign(direction.x)
	if throw_dir == 0:
		throw_dir = 1  # default throw right if undefined

	# Apply throw force based on direction
	velocity = Vector2(base_throwforce_x * throw_dir, base_throwforce_y)

	print("🪃 Throw Dir:", throw_dir, 
		" | Velocity Applied:", velocity,
		" | Direction input:", direction)

	await get_tree().create_timer(0.1).timeout
	collision_shape_2d.disabled = false
