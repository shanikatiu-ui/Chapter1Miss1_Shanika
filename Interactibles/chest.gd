extends StaticBody2D

@onready var anim = $AnimationPlayer
@onready var area = $Area2D

var player_in_zone = false
var opened = false
var player: Node2D = null

@export var interact_distance: float = 50.0  # distance limit

func _on_area_2d_body_entered(body):
	if body.name == "Player" or body.is_in_group("Player"):
		player_in_zone = true
		player = body

func _on_area_2d_body_exited(body):
	if body == player:
		player_in_zone = false
		player = null

func _process(_delta):
	if not player_in_zone or opened:
		return
		
	# ✅ Check distance to ensure the player is actually near
	if player and global_position.distance_to(player.global_position) > interact_distance:
		return
	
	if Input.is_action_just_pressed("interact"):
		if "key" in Global.key_founded:
			open_chest()
		else:
			print("❌ Chest locked! You need the key first!")

func open_chest():
	opened = true
	print("🗝️ Chest unlocked:", self.name)
	anim.play("open")
	await anim.animation_finished
	print("✅ Chest fully opened!")
	area.monitoring = false
