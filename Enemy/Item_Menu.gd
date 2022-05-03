extends Control

#onready var items = preload("res://Enemy/Inventory.tres")

onready var items = $"/root/GlobalInventory".inventory
onready var health_potion = preload("res://Enemy/health_potion.tres")
onready var item_action = $Item_Action_Bg
onready var weapon_action = $Weapon_Action_Bg
onready var discard = $Discard

const item_holder = preload("res://Enemy/Item_Display.tscn")
# Called when the node enters the scene tree for the first time.

#signals
signal item_connect
signal item_action
signal item_discarded

#Staged
var staged_item : String
var staged_position : int

#Position Dictionary
var position_dict = {
	"Item_One": 0,
	"Item_Two": 1,
	"Item_Three" : 2, 
	"Item_Four" : 3,
	 "Item_Five" : 4}

func _ready():
	self.visible = false
	item_action.visible = false
	weapon_action.visible = false
	discard.visible = false
	
	
	if items.has(get_parent().get_parent().char_name):
		
		# if so, store the info in my_items
		var my_items = items[get_parent().get_parent().char_name]
		# increase the size of the texture_rect according to the number of items
		$Item_Bg.rect_size.y = len(my_items["items"]) * 48 + 10
		
		# the list holds the names that will be given to the child nodes
		var item_positions = ["Item_One", "Item_Two", "Item_Three", "Item_Four", "Item_Five"]
		
		# for each item in the items list
		for i in range(len(my_items["items"])):
			# a new child node is instanced
			var item_instance : Button = item_holder.instance()
			# the name is assigned from the item_positions list
			item_instance.name = item_positions[i]
			# the child node is added in the grid_container
			self.get_node("Item_Bg/Item_Container").add_child(item_instance)
			
			# the correct picture is loaded and displayed
			item_instance.get_node("TextureRect").texture = my_items["items"][i].texture
			# the correct name is loaded and displayed
			item_instance.get_node("VBoxContainer/RichTextLabel").text = my_items["items"][i].name
			# the quantity is loaded and displayed
			item_instance.get_node("TextureRect/RichTextLabel").text = str(my_items["quantity"][i])
			
			# connect the item_instance click to the enemy
			# sends the type and name of the consumable item
			item_instance.connect("pressed", self,"_send_item_signal",
			 [my_items["items"][i].type, my_items["items"][i].name, item_positions[i]])
	
	

func item_list():
	self.visible = true

func item_refresh():
	
	if items.has(get_parent().get_parent().char_name):
		
		var my_items = items[get_parent().get_parent().char_name]
		
		
		$Item_Bg.rect_size.y = len(my_items["items"]) * 48 + 10
		var item_positions = ["Item_One", "Item_Two", "Item_Three", "Item_Four", "Item_Five"]
		
		#Remove all items
		for child in $Item_Bg/Item_Container.get_children():
			$Item_Bg/Item_Container.remove_child(child)
			child.queue_free()
		
		#Remove item from the data if its quantity is less than 1
		for item_q in range(len(my_items["quantity"])):
			if item_q in range(len(my_items["quantity"])):
				if my_items["quantity"][item_q] < 1:
					my_items["items"].pop_at(item_q)
					my_items["quantity"].pop_at(item_q)
	
		#Add back all items from the refreshed data
		for i in range(len(my_items["items"])):
				# a new child node is instanced
				var item_instance : Button = item_holder.instance()
				# the name is assigned from the item_positions list
				item_instance.name = item_positions[i]
				# the child node is added in the grid_container
				self.get_node("Item_Bg/Item_Container").add_child(item_instance)
				
				item_instance.get_node("TextureRect").texture = my_items["items"][i].texture
				# the correct name is loaded and displayed
				item_instance.get_node("VBoxContainer/RichTextLabel").text = my_items["items"][i].name
				# the quantity is loaded and displayed
				item_instance.get_node("TextureRect/RichTextLabel").text = str(my_items["quantity"][i])
				
				# connect the item_instance click to the enemy
				# sends the type and name of the consumable item
				item_instance.connect("pressed", self,"_send_item_signal",
				 [my_items["items"][i].type, my_items["items"][i].name, item_positions[i]])


func _send_item_signal(type, name, position):
	
	$Item_Action_Bg.rect_position.y = 48 * position_dict[position] + 10
	$Weapon_Action_Bg.rect_position.y = 48 * position_dict[position] + 10
	$Discard.rect_position.y = 48 * position_dict[position] + 10
	
	match type:
		#For general one cell attack units:
		"Consumable":
			item_action.visible = true
			weapon_action.visible = false
			
		"Weapon":
			weapon_action.visible = true
			item_action.visible = false
	
	staged_item = name
	staged_position = position_dict[position]
	emit_signal("item_connect", type, staged_item, staged_position)
	
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		item_action.visible = false
		weapon_action.visible = false



func _on_Use_pressed():
	emit_signal("item_action", staged_item, staged_position, "use")


## These functions handle the item discard system

func discard_confirm(value):
	emit_signal("item_discarded", value)
	
func _on_Discard_pressed():
	item_action.visible = false
	discard.visible = true
	emit_signal("item_action", staged_item, staged_position, "discard")

func _on_Yes_pressed():
#	function will emit signal item_discarded with true
	discard_confirm(true)
	pass # Replace with function body.

func _on_No_pressed():
#	function will revert to the item action menu with item_discared signal saying false
	item_action.visible = true
	discard.visible = false
	discard_confirm(false)
	pass # Replace with function body.
