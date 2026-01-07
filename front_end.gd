extends Control

@export var games: Dictionary[String, PackedScene] = {}
@onready var scroll_container: ScrollContainer = $ScrollContainer

var game_datas: Dictionary = {}

func _ready() -> void:
	var buttons = get_tree().get_nodes_in_group("buttons")
	for b:Button in buttons:
		var pressed = Callable(self, "_on_pressed").bind(b)
		b.pressed.connect(pressed)
		
func _on_pressed(which: Button) -> void:
	scroll_container.visible = false
	which.release_focus()
	
	print("button: %s" % [which.name])
	print("games: %s" % [games.keys()])
	
	var game = games[which.name]
	var new_game = game.instantiate()
	if new_game.has_method("set_vars")and game_datas.has(which.name):
		new_game.set_vars(game_datas[which.name])
	if new_game.has_signal("game_data_sent") and new_game.has_signal("game_quit"):
		new_game.game_data_sent.connect(_on_game_data_recieved)
		new_game.game_quit.connect(_on_quit)
		
	add_child(new_game)

func _on_quit() -> void:
	var b:Button = get_tree().get_first_node_in_group("buttons")
	b.grab_focus()
	scroll_container.visible = true
	
func _on_game_data_recieved(gd: GameData):
	print(gd)
	print(gd.name)
	print(gd.hi_score)
	for game:GameData in game_datas:
		if game_datas.has(gd.name):
			if game.hi_score > gd.hi_score:
				game_datas[gd.name] = gd
				return
	game_datas[gd.name] = gd
	
