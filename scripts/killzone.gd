extends Area2D
class_name KillZone

@onready var timer: Timer = $Timer

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		print("💀 KillZone triggered by:", body.name)
		timer.start()

func _on_timer_timeout() -> void:
	var manager = get_node_or_null("/root/GlobalPlayerManager")
	if manager:
		manager.add_player_instance()
	else:
		get_tree().reload_current_scene()
