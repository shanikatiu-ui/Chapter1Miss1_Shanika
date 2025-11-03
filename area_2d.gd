extends Area2D

@export var action_name: String = "Hide" # Text shown by the interaction manager
@export var hiding_spot: NodePath          # Optional: assign the hiding object or sprite

@onready var interaction_manager = get_tree().get_first_node_in_group("interaction_manager")
@onready var player = get_tree().get_first_node_in_group("player")

var is_hiding: bool = false


func _ready():
	# Register this area to the interaction manager
	if interaction_manager:
		interaction_manager.register_area(self)
	connect("area_exited", Callable(self, "_on_area_exited"))


func _on_area_exited(_area):
	# If player leaves, unregister the area
	if interaction_manager:
		interaction_manager.unregister_area(self)


func interact():
	if not player:
		return
	
	if is_hiding:
		# Player comes out of hiding
		player.show()
		is_hiding = false
		print("Player came out of hiding.")
	else:
		# Player hides in the object
		player.hide()
		is_hiding = true
		print("Player is hiding now!")

	# Optional: You can also move the player to the hiding spot's position
	if hiding_spot and not is_hiding:
		player.global_position = get_node(hiding_spot).global_position
