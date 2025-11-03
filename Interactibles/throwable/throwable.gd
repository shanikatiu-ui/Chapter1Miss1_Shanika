class_name Throwable
extends Area2D

@export var gravity_strength : float = 980
@export var throw_speed : float = 400.0
@export var throw_height_strength : float = 100.0
@export var throw_starting_height : float = 49

var picked_up : bool = false
@onready var hurt_box: HurtBox = $HurtBox


func _ready() -> void:
	area_entered.connect(on_area_enter)
	area_exited.connect(on_area_exit)
	setup_hurt_box()


func player_interact() -> void:
	if picked_up:
		return
	picked_up = true
	print("Picked up!")
	PlayerManager.player.pickup_item(self)
	# Disable pickup detection while held
	monitoring = false
	monitorable = false


func on_area_enter(area: Area2D) -> void:
	print("Something entered the area:", area.name)
	if area.is_in_group("player"):
		print("Player entered pickup area.")
		if not PlayerManager.interact_pressed.is_connected(player_interact):
			PlayerManager.interact_pressed.connect(player_interact)


func on_area_exit(area: Area2D) -> void:
	if area.is_in_group("player"):
		print("Player left pickup area.")
		if PlayerManager.interact_pressed.is_connected(player_interact):
			PlayerManager.interact_pressed.disconnect(player_interact)


func setup_hurt_box() -> void:
	hurt_box.monitoring = false
	for c in get_children():
		if c is CollisionShape2D:
			var _col : CollisionShape2D = c.duplicate()
			hurt_box.add_child(_col)
