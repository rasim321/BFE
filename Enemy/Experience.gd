extends Node

const FILE_NAME = "res://experience_data.json"

var experience = {
	"Mizan" : {
		"level" : 2,
		"experience" : 90
	},
	"Sonru" : {
		"level" : 2,
		"experience" : 0
	},
	"Boltu" : {
		"level" : 2,
		"experience" : 0
	},
	"Basel" : {
		"level" : 3,
		"experience" : 0
	},
	"Chowdhury" : {
		"level" : 3,
		"experience" : 0
	},
	"Arlo" : {
		"level" : 3,
		"experience" : 0
	}
}


func save():
	var file = File.new()
	file.open(FILE_NAME, File.WRITE)
	file.store_string(to_json(experience))
	file.close()


func load():
	var file = File.new()
	if file.file_exists(FILE_NAME):
		file.open(FILE_NAME, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			experience = data
		else:
			printerr("Corrupted data!")
	else:
		printerr("No saved data!")
