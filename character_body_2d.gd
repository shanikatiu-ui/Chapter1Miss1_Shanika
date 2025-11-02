extends CharacterBody2D

@export var SPEED: float = 300.0
@export var CROUCH_SPEED: float = 100.0
@export var JUMP_VELOCITY: float = -500.0
@export var GRAVITY: float = 1200.0

var state: String = "idle"
var is_crouching: bool = false

@onready var mainplayer_walk: Sprite2D = $mainplayer        # walking sprite
@onready var mainplayer_idle: Sprite2D = $mainplayer2idle   # idle sprite
@onready var mainplayer_crouch: Sprite2D = $mainplayer3crouch  # crouch sprite
@onready var animation: AnimationPlayer = $animation

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	is_crouching = Input.is_action_pressed("crouch")
	var input_dir: float = Input.get_axis("left", "right")

	if Input.is_action_just_pressed("up") and is_on_floor() and not is_crouching:
		velocity.y = JUMP_VELOCITY
		state = "jump"

	if is_crouching:
		state = "crouch"
		velocity.x = input_dir * CROUCH_SPEED
	elif input_dir != 0.0:
		state = "walk"
		velocity.x = input_dir * SPEED
	else:
		velocity.x = lerp(velocity.x, 0.0, 0.2)
		if is_on_floor():
			state = "idle"

	move_and_slide()

	if velocity.x != 0.0:
		mainplayer_walk.flip_h = velocity.x < 0.0
		mainplayer_idle.flip_h = velocity.x < 0.0
		mainplayer_crouch.flip_h = velocity.x < 0.0

	update_animation()


func update_animation() -> void:
	# Hide all sprites first
	mainplayer_walk.visible = false
	mainplayer_idle.visible = false
	mainplayer_crouch.visible = false

	match state:
		"jump":
			if animation.has_animation("jump"):
				animation.play("jump")
			mainplayer_walk.visible = true
		"crouch":
			mainplayer_crouch.visible = true
			if animation.has_animation("crouch"):
				animation.play("crouch")
		"walk":
			mainplayer_walk.visible = true
			if animation.has_animation("walk"):
				animation.play("walk")
		"idle":
			mainplayer_idle.visible = true
			if animation.has_animation("idle"):
				animation.play("idle")
