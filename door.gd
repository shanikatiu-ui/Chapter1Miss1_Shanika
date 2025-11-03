extends StaticBody2D

@onready var anim = $AnimationPlayer
@onready var area = $Area2D
@onready var collision = $CollisionShape2D

var opened = false

func _ready():
	# Make sure the Area2D is detecting player collisions
	area.monitoring = true
	area.monitorable = true
	area.body_entered.connect(_on_area_2d_body_entered)
	area.body_exited.connect(_on_area_2d_body_exited)

var player_inside: bool = false

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player") or body.name == "Player":
		player_inside = true
		print("✅ Player entered interaction zone")

func _on_area_2d_body_exited(body):
	if body.is_in_group("Player") or body.name == "Player":
		player_inside = false
		print("🚪 Player left interaction zone")

func _process(_delta):
	if not player_inside or opened:
		return

	if Input.is_action_just_pressed("interact"):
		if "key_door1" in Global.key_founded:
			open_door()
		else:
			print("❌ Door locked! You need the key first!")

func open_door():
	opened = true
	print("🗝️ Door unlocked:", self.name)
	anim.play("open_door")
	await anim.animation_finished
	area.monitoring = false
	collision.disabled = true
