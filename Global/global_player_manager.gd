extends Node

const PLAYER = preload("res://player/player.tscn")

signal interact_pressed

var player: Player
var player_spawned: bool = false

func _ready() -> void:
	if not player or not is_instance_valid(player):
		add_player_instance()
	await get_tree().create_timer(0.2).timeout
	player_spawned = true

func add_player_instance() -> void:
	for child in get_tree().current_scene.get_children():
		if child is Player:
			child.queue_free()

	player = PLAYER.instantiate()
	get_tree().current_scene.add_child(player)

	# Optional: spawn position
	var spawn = get_tree().current_scene.get_node_or_null("PlayerSpawn")
	if spawn:
		player.global_position = spawn.global_position

	player.name = "Player"
	print("✅ Player spawned")

func emit_interact_pressed() -> void:
	interact_pressed.emit()
