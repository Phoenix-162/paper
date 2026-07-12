extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var project_panel:PackedScene = load("uid://5ej4x3m3lnx2")
	DisplayServer.window_set_min_size(Vector2(600,600))
	PanelManager.add_panel("project list","uid://5ej4x3m3lnx2",PanelManager.DockSlot.main,{uncloseable= true})
	for node_path:NodePath in PanelManager.tab_bars:
		if node_path == ^"":
			continue
		var tab_bar:TabBar = get_node(node_path)
		tab_bar.gui_input.connect(tabbar_gui_input.bind(tab_bar.get_parent().get_meta("dock")))
		tab_bar.tab_selected.connect(tab_selected.bind(tab_bar.get_parent().get_meta("dock")))
		tab_bar.tab_close_pressed.connect(tab_close.bind(tab_bar.get_parent().get_meta("dock")))
		tab_bar.tab_rmb_clicked.connect(tab_rmb_clicked.bind(tab_bar.get_parent().get_meta("dock")))

func tab_selected(tab: int,dock:PanelManager.DockSlot) -> void:
	var tab_bar:TabBar = get_node(PanelManager.tab_bars[dock])
	#var tab_page = get_node(PanelManager.tab_pages[dock])
	if tab_bar.get_tab_metadata(tab) is Dictionary and tab_bar.get_tab_metadata(tab).has(&"connect_tab"):
		var current_tab = tab_bar.get_tab_metadata(tab).connect_tab
		var prev_tab = tab_bar.get_tab_metadata(tab_bar.get_previous_tab()).connect_tab
		current_tab.visible = true
		if current_tab.has_method("tab_enterd") and tab_bar.get_previous_tab() != tab:
			current_tab.tab_enterd(tab)
		if prev_tab.has_method("tab_exited") and tab_bar.get_previous_tab() != tab:
			prev_tab.tab_exited(tab)

func tab_close(tab: int,dock:PanelManager.DockSlot) -> void:
	var tab_bar:TabBar = get_node(PanelManager.tab_bars[dock])
	var tab_metadata:Dictionary = tab_bar.get_tab_metadata(tab)
	if tab_bar.tab_count != 1 or dock != PanelManager.DockSlot.main:
		if tab_metadata.has(&"uncloseable"):
			return
		if tab_metadata.has(&"unique"):
			PanelManager.remove_meta(tab_bar.get_tab_title(tab))
		PanelManager.remove_panel(tab,dock)
	else :
		if tab_metadata.has(&"uncloseable"):
			return
		if dock == PanelManager.DockSlot.main:
			get_tree().quit()


func tab_rmb_clicked(tab: int,dock:PanelManager.DockSlot) -> void:
	PanelManager.show_contex(%popup,tab,dock)


func tabbar_gui_input(event: InputEvent,dock:PanelManager.DockSlot) -> void:
	var tab_bar:TabBar = get_node(PanelManager.tab_bars[dock])
	if event is InputEventMouseButton:
		if event.pressed and event.button_mask == MouseButtonMask.MOUSE_BUTTON_MASK_RIGHT and tab_bar.get_tab_idx_at_point(tab_bar.get_local_mouse_position()) == -1:
			PanelManager.show_contex(%popup,-1,dock)

#region window button

func _on_minimize_pressed() -> void:
	get_tree().root.mode = Window.MODE_MINIMIZED


func _on_maximaize_pressed() -> void:
	if get_tree().root.mode == Window.MODE_MAXIMIZED:
		get_tree().root.mode = Window.MODE_WINDOWED
	else :
		get_tree().root.mode = Window.MODE_MAXIMIZED
	pass # Replace with function body.


func _on_close_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.
#endregion
