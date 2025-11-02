extends CharacterBody2D
class_name Guard2

@export var SPEED: float = 300.0
@export var pause_duration: float = 0.5

var direction: int = 1
var is_paused: bool = false
var pause_timer: Timer

@onready var sprite: Sprite2D = $guard1
@onready var anim_player: AnimationPlayer = $guard1/guard1walk
@onready var boundary_3: Area2D = $"../boundary3"
@onready var boundary_4: Area2D = $"../boundary4"

func _ready() -> void:
	# Timer setup
	pause_timer = Timer.new()
	pause_timer.wait_time = pause_duration
	pause_timer.one_shot = true
	pause_timer.connect("timeout", Callable(self, "_on_pause_timeout"))
	add_child(pause_timer)

	# Connect signals from boundaries
	boundary_3.connect("body_entered", Callable(self, "_on_boundary_entered"))
	boundary_4.connect("body_entered", Callable(self, "_on_boundary_entered"))

	anim_player.play("walk")

func _physics_process(delta: float) -> void:
	if not is_paused:
		velocity.x = direction * SPEED
	else:
		velocity.x = 0

	move_and_slide()
	sprite.flip_h = direction < 0

	if not anim_player.is_playing():
		anim_player.play("walk")

func _on_boundary_entered(body: Node) -> void:
	# Only react if the body entering is the Guard itself
	if body == self:
		is_paused = true
		velocity = Vector2.ZERO
		anim_player.stop()
		pause_timer.start()

func _on_pause_timeout() -> void:
	direction *= -1
	is_paused = false
	anim_player.play("walk")
