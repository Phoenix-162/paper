extends Node
#region values

const tab_pages:Array[NodePath] = [
	^"/root/main/main panel/HSplit/Hsplit/Vsplit/main/tabs page",
	^"/root/main/main panel/HSplit/Hsplit/left/pages",
	^"/root/main/main panel/HSplit/right/pages",
	^"/root/main/main panel/HSplit/Hsplit/Vsplit/bottom/pages",
]

const tab_bars:Array[NodePath] = [
	^"/root/main/main panel/HSplit/Hsplit/Vsplit/main/tab bar",
	^"/root/main/main panel/HSplit/Hsplit/left/tab bar",
	^"/root/main/main panel/HSplit/right/tab bar",
	^"/root/main/main panel/HSplit/Hsplit/Vsplit/bottom/tab bar",
]

var active_tabs:Array
#var main_panel_count:int:
	#get:
		#return $"../main/main panel/HSplit/Hsplit/Vsplit/main/tab bar".tab_count 
var contex_menu:Dictionary[String,PackedStringArray] = {
	#"0 -1" = ["tes","aaaa"],
	"#outliner" = ["open","open inspector","save","save_as"],
	"* *" = ["123","12"]
	}
var contex_function:Dictionary[String,Callable] = {
	"#outliner" = func (idx,tab,dock):
		var tab_bar:TabBar = get_node(tab_bars[dock])
		var panel:PanelContainer = tab_bar.get_tab_metadata(tab).connect_tab
		panel._on_context(idx)
		,
	"* *" = func (idx,tab,dock):
		prints(idx,tab,dock)
}

enum DockSlot{
	main,
	left,
	right,
	bottom,
}
#endregion
#region functions

func add_panel(title:String,path:String,dock:DockSlot = DockSlot.main,metadata:Dictionary = {}) -> Error:
	if not ResourceLoader.exists(path):
		return Error.ERR_CANT_CREATE
	if has_meta(title):
		return Error.ERR_ALREADY_EXISTS
	var panel = load(path)
	if not panel is PackedScene:
		return Error.ERR_SKIP
	if metadata.has(&"unique"):
		set_meta(title,true)
	panel = panel.instantiate()
	if not panel is PanelContainer:
		panel.queue_free()
		return Error.ERR_SKIP
	var tab_bar:TabBar = get_node(tab_bars[dock])
	var tabs_page:TabContainer = get_node(tab_pages[dock])
	var meta = {connect_tab = panel}
	meta.merge(metadata)
	tab_bar.add_tab(title)
	tab_bar.set_tab_metadata(tab_bar.tab_count -1,meta)
	tabs_page.add_child(panel)
	if tab_bar.tab_count > 0:
		tab_bar.get_parent().show()
	return Error.OK

func add_toolbar_item():
	pass


func show_contex(popup:PopupMenu,tab:int,dock:DockSlot = DockSlot.main):
	var tab_bar:TabBar = get_node(tab_bars[dock])
	popup.position = DisplayServer.mouse_get_position()
	popup.id_pressed.connect(func (_val):
		popup.hide()
		)
	#if popup.position.y + popup.size.y > get_tree().root.size.y:
		#popup.position.y - popup.size.y 
	popup.clear(true)
	
	if  tab != -1 and tab_bar.tab_count >= tab and contex_menu.has("#"+tab_bar.get_tab_title(tab)):
		var contex_key:String = "#"+tab_bar.get_tab_title(tab)
		for item in contex_menu[contex_key]:
			popup.add_item(item)
		if contex_function.has(contex_key):
			if popup.id_pressed.is_connected(contex_function[contex_key]):
				popup.id_pressed.disconnect(contex_function[contex_key])
			popup.id_pressed.connect(contex_function[contex_key].bind(tab,dock),ConnectFlags.CONNECT_ONE_SHOT)
	elif contex_menu.has(str(dock)+" "+str(tab)):
		var contex_key:String = str(dock)+" "+str(tab)
		for item in contex_menu[contex_key]:
			popup.add_item(item)
		if contex_function.has(contex_key):
			if popup.id_pressed.is_connected(contex_function[contex_key]):
				popup.id_pressed.disconnect(contex_function[contex_key])
			popup.id_pressed.connect(contex_function[contex_key].bind(tab,dock),ConnectFlags.CONNECT_ONE_SHOT)
	elif contex_menu.has("* " + str(tab)):
		var contex_key:String = "* " + str(tab)
		for item in contex_menu[contex_key]:
			popup.add_item(item)
		if contex_function.has(contex_key):
			if popup.id_pressed.is_connected(contex_function[contex_key]):
				popup.id_pressed.disconnect(contex_function[contex_key])
			popup.id_pressed.connect(contex_function[contex_key].bind(tab,dock),ConnectFlags.CONNECT_ONE_SHOT)
	elif contex_menu.has(str(dock)+" *"):
		var contex_key:String = str(dock)+" *"
		for item in contex_menu[contex_key]:
			popup.add_item(item)
		if contex_function.has(str(dock)+" *"):
			if popup.id_pressed.is_connected(contex_function[contex_key]):
				popup.id_pressed.disconnect(contex_function[contex_key])
			popup.id_pressed.connect(contex_function[contex_key].bind(tab,dock),ConnectFlags.CONNECT_ONE_SHOT)
	elif contex_menu.has("* *"):
		for item in contex_menu["* *"]:
			popup.add_item(item)
		if contex_function.has("* *"):
			if popup.id_pressed.is_connected(contex_function["* *"]):
				popup.id_pressed.disconnect(contex_function["* *"])
			popup.id_pressed.connect(contex_function["* *"].bind(tab,dock),ConnectFlags.CONNECT_ONE_SHOT)
	if popup.item_count != 0:
		popup.reset_size()
		popup.show()
func remove_panel(tab:int,dock:DockSlot=DockSlot.main):
	var _tabs_page:TabContainer = get_node(tab_pages[dock])
	var tab_bar:TabBar = get_node(tab_bars[dock])
	var closed_tab = tab_bar.get_tab_metadata(tab).connect_tab
	closed_tab.queue_free()
	tab_bar.remove_tab(tab)
	if tab_bar.tab_count == 0:
		tab_bar.get_parent().hide()
#endregion
