extends Node

var console : Console = null
var message : String = ""

func _process(delta: float) -> void:
	if console == null: return
	else:
		_print(message)

func _print(message):
		console.update_label(message)
		print(message)






















#extends Node
#@onready var console: Console = $Console
#
#
#
#func _process(delta: float) -> void:
	#console = $Console
	#print(console)
#
#func _print(message):
	#print(message)
	#
	#if console == null:
		#print("ERROR: my_node is NULL right before calling update_label()!")
		#return  # VERY IMPORTANT: Stop the function if the node is null
	#console.update_label(message)  # This line is causing the error

#
#extends Node
#var console: Console
#
#
#func _ready():
	#call_deferred("setup_console")
	#
#
#func _process(delta: float) -> void:
	#console = $console
	#print(console)
#
#func setup_console():
	##console = 
	#console = get_node("World/Player/Console") # Replace with the correct path
#
	#if console == null:
		#print("Console node not found! Check the path.")
		#return
#
#func _print(message):
	#print(message)
	#
#
	#if console == null:
		#print("ERROR: console is NULL right before calling update_label()!")
		#return
#
	#console.update_label(message)
