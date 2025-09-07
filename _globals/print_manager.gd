extends Node

@export var log_to_file_enabled: bool = false

var console: Console = null
var log_file: FileAccess = null  # Declare a File variable

# NOTE: Saving logs to "res://" is not recommended as it becomes read-only in exported projects.
# For better compatibility, consider changing log_dir to "user://log/".
var log_dir := "res://console/log/"
var log_file_path := ""

func _ready():
	if not log_to_file_enabled:
		return

	# Ensure the log directory exists.
	DirAccess.make_dir_recursive_absolute(log_dir)

	# Generate a filename with the current date and time.
	var dt_string = Time.get_datetime_string_from_system(false).replace(":", "-").replace("T", "_")
	log_file_path = log_dir.path_join(dt_string + ".log")

	# Initialize the log file
	log_file = FileAccess.open(log_file_path, FileAccess.WRITE)
	if log_file == null:
		var err_msg = "Could not open log file for writing: " + log_file_path
		push_error(err_msg)
		# Also print to console in case file logging is the only output
		print(err_msg)
		return  # Exit if we can't open the file

	var datetime_string = Time.get_datetime_string_from_system().replace("T", " ")
	log_file.store_string("--- Session Start: " + datetime_string + " ---\n") # Write a header to the log

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if log_file and log_to_file_enabled:
			log_file.close()

func _print(message):
	if console:
		console.update_label(message)
	print(message)
	if log_to_file_enabled:
		_log_to_file(message)  # Call the logging function

func _log_to_file(message):
	if log_file:
		var time_string = Time.get_time_string_from_system()
		log_file.store_string(time_string + " " + message + "\n")  # Add a timestamp to the message
