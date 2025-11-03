extends Node2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var label = $Label

const BASE_TEXT = "[E] to "

var active_areas: Array = []
var can_interact: bool = true


func register_area(area: InteractionArea):
	active_areas.push_back(area)


func unregister_area(area: InteractionArea):
	var index = active_areas.find(area)
	if index != -1:
		active_areas.remove_at(index)


func _process(_delta):
	if active_areas.size() > 0 and can_interact and player:
		# Sort areas so the closest one to the player appears first
		active_areas.sort_custom(self._sort_by_distance_to_player)
		var nearest = active_areas[0]

		label.text = BASE_TEXT + nearest.action_name
		label.global_position = nearest.global_position
		label.global_position.y -= 36
		label.global_position.x -= label.size.x / 2
		label.show()
	else:
		label.hide()


func _sort_by_distance_to_player(a, b):
	var dist_a = player.global_position.distance_to(a.global_position)
	var dist_b = player.global_position.distance_to(b.global_position)
	return dist_a < dist_b


func _input(event):
	if event.is_action_pressed("interact") and can_interact:
		if active_areas.size() > 0:
			can_interact = false
			label.hide()

			await active_areas[0].interact.call()

			can_interact = true
