extends Control

@export var games: Array[PackedScene] = []
@onready var scroll_container: ScrollContainer = $ScrollContainer

var game_datas: Dictionary = {}

func _ready() -> void:
	var buttons = get_tree().get_nodes_in_group("buttons")
	for b:Button in buttons:
		var pressed = Callable(self, "_on_pressed").bind(b)
		b.pressed.connect(pressed)
		
func _on_pressed(which: Button) -> void:
	print("which=%s" % [which])
	match which.name:
		"Button0":
			scroll_container.visible = false
			which.release_focus()
			var game = games[0].instantiate()
			game.set_vars(game_datas["snake"])
			game.game_data_sent.connect(_on_game_data_recieved)
			game.game_quit.connect(_on_quit)
			add_child(game)

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
	
