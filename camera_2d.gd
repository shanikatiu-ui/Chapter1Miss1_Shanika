extends Camera2D

@export var player_path: NodePath
@export var follow_speed: float = 5.0

var player: Node2D = null

func _ready() -> void:
	make_current()
	if player_path != NodePath(""):
		player = get_node_or_null(player_path) as Node2D
	if not player:
		push_warning("Camera2D: player not found. Set player_path in the Inspector.")
	if player and player.is_ancestor_of(self):
		push_warning("Camera2D is a child of the player. Move it outside the player node.")

	limit_left = 0
	limit_top = 0
	limit_right = 2000
	limit_bottom = 1000
	limit_smoothed = true  # optional: makes limit transitions smoother

func _process(delta: float) -> void:
	if not player:
		return
	var t := follow_speed * delta
	if t > 1.0:
		t = 1.0
	global_position = global_position.lerp(player.global_position, t)
