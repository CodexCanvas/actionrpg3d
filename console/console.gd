class_name  Console
extends Label

@onready var print_manager: PrintManager = get_node("/root/PrintManager")

const MAX_MESSAGES = 40
var message_history: Array[String] = []

func _ready() -> void:
	print_manager.console = self

func  update_label(message: String) -> void:
	message_history.insert(0, message)
	if message_history.size() > MAX_MESSAGES:
		message_history.pop_back()
	
	text = "\n".join(message_history)
