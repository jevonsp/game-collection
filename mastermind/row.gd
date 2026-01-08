extends HBoxContainer

@onready var guesses_0: ColorRect = $Guesses/ColorRect0
@onready var guesses_1: ColorRect = $Guesses/ColorRect1
@onready var guesses_2: ColorRect = $Guesses/ColorRect2
@onready var guesses_3: ColorRect = $Guesses/ColorRect3
var guesses:Array[ColorRect] = []
@onready var results_0: ColorRect = $Results/ColorRect0
@onready var results_1: ColorRect = $Results/ColorRect1
@onready var results_2: ColorRect = $Results/ColorRect2
@onready var results_3: ColorRect = $Results/ColorRect3

func _ready() -> void:
	for rect in [guesses_0, guesses_1, guesses_2, guesses_3]:
		guesses.append(rect)
