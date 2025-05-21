extends PanelContainer
class_name UIElement

func _show():
	self.visible = true 
	
func _hide():
	self.visible = false
	
func _set_visibility(value: bool):
	self.visible = value
