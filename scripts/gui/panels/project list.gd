extends PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	pass # Replace with function body.
func tab_enterd(tab):
	prints("tess",tab)

func tab_exited(_tab):
	pass

func _on_new_pressed() -> void:
	PanelManager.add_panel("outliner","uid://bad0r5w20bvxt",PanelManager.DockSlot.left,{unique = true})
	PanelManager.add_panel("inspector","uid://dpjufnn834qka",PanelManager.DockSlot.right,{unique = true})


func _on_load_pressed() -> void:
	%FileDialog.current_dir = ProjectSettings.globalize_path(SaveManager.save_path+"/")
	%FileDialog.exclusive = true
	%FileDialog.get_vbox().get_child(1).get_child(0).visible = false
	%FileDialog.popup_centered()

func _on_file_dialog_file_selected(path: String) -> void:
	SaveManager.load_project(path)
