class_name  Console
extends Label

@onready var print_manager: PrintManager = get_node("/root/PrintManager")

func _ready() -> void:
	print_manager.console = self

func  update_label(message):
	text = message
