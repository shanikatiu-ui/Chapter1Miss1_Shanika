extends CharacterBody2D
class_name Enemy

@export var speed: float = 50.0

var left_marker: Marker2D
var right_marker: Marker2D
var moving_right: bool = true

func _ready() -> void:
	# Automatically find markers by name
	left_marker = get_node_or_null("Marker2D_Left")
	right_marker = get_node_or_null("Marker2D_Right")

	if left_marker == null or right_marker == null:
		push_error("⚠️ Missing Marker2D_Left or Marker2D_Right as children of Enemy!")
		return

	print("✅ Patrol markers found:", left_marker.name, "and", right_marker.name)

func _physics_process(delta: float) -> void:
	if left_marker == null or right_marker == null:
		return

	var target_pos = right_marker.global_position if moving_right else left_marker.global_position
	var direction = (target_pos - global_position).normalized()

	# Move toward target
	velocity.x = direction.x * speed
	move_and_slide()

	# Flip sprite if available
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.flip_h = velocity.x < 0

	# Check if close enough to switch direction
	if global_position.distance_to(target_pos) < 10.0:
		moving_right = !moving_right
