extends Node
var health_potion = preload("res://Enemy/health_potion.tres")
var iron_sword = preload("res://Enemy/iron_sword.tres")
var iron_axe = preload("res://Enemy/iron_axe.tres")
var iron_bow = preload("res://Enemy/iron_bow.tres")
var iron_katana = preload("res://Enemy/iron_katana.tres")


var inventory = {
	"Mizan" : {
		"items" : [health_potion, health_potion, health_potion, iron_sword, iron_axe],
		"quantity" : [2, 1, 3, 1, 1],
		"equipped" : iron_sword,
		"eq_position" : 3
	},
	"Sonru" : {
		"items" : [iron_bow, iron_sword],
		"quantity" : [1,1],
		"equipped" : iron_bow,
		"eq_position" : 0
	},
	"Boltu" : {
		"items" : [health_potion, iron_axe],
		"quantity" : [4,1],
		"equipped" : iron_axe,
		"eq_position" : 1
	},
	"Basel" : {
		"items" : [health_potion, iron_sword],
		"quantity" : [2,1],
		"equipped" : iron_sword,
		"eq_position" : 1
	},
	"Chowdhury" : {
		"items" : [iron_axe, health_potion],
		"quantity" : [1, 2],
		"equipped" : iron_axe,
		"eq_position" : 0
	},
	"Arlo" : {
		"items" : [iron_sword, health_potion, health_potion],
		"quantity" : [1, 3, 2],
		"equipped" : iron_sword,
		"eq_position" : 0
	},
	
	"Spiro" : {
		"items" : [iron_sword, health_potion],
		"quantity" : [1, 3],
		"equipped" : iron_sword,
		"eq_position" : 0
	},
	"Ryn" : {
		"items" : [iron_katana, health_potion, health_potion],
		"quantity" : [1, 3, 2],
		"equipped" : iron_katana,
		"eq_position" : 0
	}
}

func item_setter(char_name, _item, position, amount):
	inventory[char_name]["quantity"][position] += amount
	print("The amount changed to:", inventory[char_name]["quantity"][position])
	
func item_getter(char_name, item, position, amount):
	inventory[char_name]["quantity"][position] -= amount
	if inventory[char_name]["quantity"][position] < 1:
		inventory[char_name]["items"].pop_at(position)
		inventory[char_name]["quantity"].pop_at(position)
		return item
