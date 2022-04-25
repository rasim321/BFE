extends Node
var health_potion = preload("res://Enemy/health_potion.tres")
var sword = preload("res://Enemy/sword.tres")

var inventory = {
	"Mizan" : {
		"items" : [health_potion, health_potion, health_potion, sword],
		"quantity" : [2, 1, 3, 1]
	},
	"Sonru" : {
		"items" : [sword, sword],
		"quantity" : [1,1]
	},
	"Boltu" : {
		"items" : [health_potion, sword],
		"quantity" : [4,1]
	}
}

func item_setter(char_name, item, position, amount):
	inventory[char_name]["quantity"][position] += amount
	print("The amount changed to:", inventory[char_name]["quantity"][position])
	
func item_getter(char_name, item, position, amount):
	inventory[char_name]["quantity"][position] -= amount
	if inventory[char_name]["quantity"][position] < 1:
		inventory[char_name]["items"].pop_at(position)
		inventory[char_name]["quantity"].pop_at(position)
		return item
