extends Node2D

func _ready():
	if self.name in Global.key_founded:
		queue_free()
	print(Global.key_founded)


func _on_area_2d_body_entered(body):
	# Only disappear if the body is the player
	if body.name == "player" or body.is_in_group("player"):
		Global.key_founded.append(self.name)
		print("🔑 Player picked up key!")
		queue_free()
