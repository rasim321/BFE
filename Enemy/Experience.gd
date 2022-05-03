extends Node

const FILE_NAME = "res://experience_data.json"

var experience = {
	"Mizan" : {
		"level" : 2,
		"experience" : 90,
		"hp" : 100,
		"str" : 10,
		"mag" : 12,
		"skill" : 10,
		"speed" : 10,
		"move" : 6,
		"def" : 10, 
		"res": 6,
		"notice" : 6
	},
	"Sonru" : {
		"level" : 2,
		"experience" : 0,
		"hp" : 90,
		"str" : 8,
		"mag" : 2,
		"skill" : 10,
		"speed" : 12,
		"move" : 6,
		"def" : 7, 
		"res": 6,
		"notice" : 6
	},
	"Boltu" : {
		"level" : 2,
		"experience" : 0,
		"hp" : 150,
		"str" : 12,
		"mag" : 1,
		"skill" : 6,
		"speed" : 8,
		"move" : 6,
		"def" : 12, 
		"res": 6,
		"notice" : 6
	},
	"Basel" : {
		"level" : 3,
		"experience" : 0,
		"hp" : 100,
		"str" : 10,
		"mag" : 12,
		"skill" : 10,
		"speed" : 10,
		"move" : 6,
		"def" : 10, 
		"res": 6,
		"notice" : 6
	},
	"Chowdhury" : {
		"level" : 3,
		"experience" : 0,
		"hp" : 150,
		"str" : 12,
		"mag" : 1,
		"skill" : 6,
		"speed" : 8,
		"move" : 6,
		"def" : 12, 
		"res": 6,
		"notice" : 6
	},
	"Arlo" : {
		"level" : 3,
		"experience" : 0,
		"hp" : 100,
		"str" : 10,
		"mag" : 12,
		"skill" : 10,
		"speed" : 10,
		"move" : 6,
		"def" : 10, 
		"res": 6,
		"notice" : 6
	}
}

var growth = {
	"Mizan" : {
		"hp" : 0.5,
		"str" : 0.5,
		"mag" : 0.5,
		"skill" : 0.5,
		"speed" : 0.5,
		"move" : 0.5,
		"def" : 0.5, 
		"res": 0.5,
	},
	"Sonru" : {
		"hp" : 0.5,
		"str" : 0.5,
		"mag" : 0.5,
		"skill" : 0.5,
		"speed" : 0.5,
		"move" : 0.5,
		"def" : 0.5, 
		"res": 0.5,
	},
	"Boltu" : {
		"hp" : 0.5,
		"str" : 0.5,
		"mag" : 0.5,
		"skill" : 0.5,
		"speed" : 0.5,
		"move" : 0.5,
		"def" : 0.5, 
		"res": 0.5,
	},
	"Basel" : {
		"hp" : 0.5,
		"str" : 0.5,
		"mag" : 0.5,
		"skill" : 0.5,
		"speed" : 0.5,
		"move" : 0.5,
		"def" : 0.5, 
		"res": 0.5,
	},
	"Chowdhury" : {
		"hp" : 0.5,
		"str" : 0.5,
		"mag" : 0.5,
		"skill" : 0.5,
		"speed" : 0.5,
		"move" : 0.5,
		"def" : 0.5, 
		"res": 0.5,
	},
	"Arlo" : {
		"hp" : 0.5,
		"str" : 0.5,
		"mag" : 0.5,
		"skill" : 0.5,
		"speed" : 0.5,
		"move" : 0.5,
		"def" : 0.5, 
		"res": 0.5,
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
