extends Control

signal force_phase_turn

func _ready():
	self.visible = false
	$Menu_Bg/End_Turn_Confirm.visible = false
	$Menu_Bg/Suspend_Confirm.visible = false
	pass # Replace with function body.

func activate_menu():
	$Menu_Bg.rect_position = get_global_mouse_position()
	self.set_process_input(true)
	self.visible = true

func deactivate_menu():
	self.visible = false
	get_parent().get_parent().set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		deactivate_menu()	


func _on_Units_pressed():
	print("UNITS HAS BEEN PRESSED")
	pass # Replace with function body.


func _on_End_Turn_pressed():
	$Menu_Bg/End_Turn_Confirm.visible = true
	pass # Replace with function body.


func _on_Suspend_Game_pressed():
	$Menu_Bg/Suspend_Confirm.visible = true
	pass # Replace with function body.


func _on_ET_Yes_pressed():
	emit_signal("force_phase_turn")
	self.visible = false
	$Menu_Bg/End_Turn_Confirm.visible = false
	pass # Replace with function body.


func _on_ET_No_pressed():
	$Menu_Bg/End_Turn_Confirm.visible = false
	pass # Replace with function body.


func _on_SUS_Yes_pressed():
	pass # Replace with function body.


func _on_SUS_No_pressed():
	$Menu_Bg/Suspend_Confirm.visible = false
	pass # Replace with function body.
