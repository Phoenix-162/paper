extends PanelContainer
const max_icon_width = 20
const fallback_icon = "uid://ch11sian14j3n"
#region variables
var root_item:TreeItem
var selceted_obj:Array[TreeItem]
var insert_window:Window = preload("uid://c27wqcr1yijhf").instantiate()
var copy_buffer:Array = []: #the first item is the parent item
	set(val):
		if val.is_empty():
			context_disabled[3] = true
			context_disabled[4] = true
		else:
			context_disabled[3] = false
			context_disabled[4] = false
		copy_buffer = val
var context_menu_option:PackedStringArray = PackedStringArray([
	"insert new object",
	"rename",
	"copy",
	"paste",
	"paste as sibling",
	"delete",])
var context_disabled:Array[bool]  = [false,false,false,true,true]
var context_menu_func:Array[Callable] = [
	func ():
		insert_window.popup_centered(),
	func (): #remane fuction
		var rename = func(select:Array[TreeItem],new_name,_self):
			for item in select:
				if not item.is_selected(0):
					continue
				var obj:PaperObject = item.get_metadata(0).object
				if obj.has_method("on_renamed") and obj != null:
					obj = item.get_metadata(0).object
					if obj.on_renamed.get_argument_count() == 1:
						obj.on_renamed(new_name)
				if item.get_child_count() != 0:
					_self.call(item.get_children(),new_name,_self)
					obj.display_name = new_name
					item.set_text(0,new_name)
				else :
					obj.display_name = new_name
					item.set_text(0,new_name)
		var rename_win:AcceptDialog = AcceptDialog.new()
		var text_edit = LineEdit.new()
		add_child(rename_win)
		rename_win.title = "rename"
		rename_win.add_child(text_edit)
		rename_win.register_text_enter(text_edit)
		rename_win.close_requested.connect(func ():
			rename_win.queue_free()
			)
		rename_win.confirmed.connect(func ():
			if not text_edit.text.is_empty():
				rename.call(selceted_obj,text_edit.text,rename)
			rename_win.queue_free()
			)
		rename_win.popup_centered(Vector2i(500,100)),
	func (): #copy function
		copy_buffer = copy(selceted_obj),
	func (): #paste function
		paste(copy_buffer,selceted_obj[-1]),
	func (): #paste as sibling function
		paste(copy_buffer,selceted_obj[-1].get_parent()),
	func ():
		#object.on_delete()
		var delete = func(select:Array[TreeItem],_self):
			for item in select:
				var object:PaperObject = item.get_metadata(0).object
				if object.has_method("on_delete") and object != null:
					object.on_delete()
				if item.get_child_count() != 0:
					await _self.call(item.get_children(),_self)
					item.free()
				else :
					item.free()
				
		var seletced:TreeItem = %Tree.get_selected()
		var confirmation:ConfirmationDialog = ConfirmationDialog.new()
		#var object:PaperObject = seletced.get_metadata(0).object
		add_child(confirmation)
		confirmation.dialog_text = "delete object \""+ seletced.get_text(0) + "\" and its child"
		confirmation.confirmed.connect(func ():
			delete.call(selceted_obj,delete)
			selceted_obj.clear()
			confirmation.queue_free()
				)
		confirmation.canceled.connect(func (): confirmation.queue_free())
		confirmation.popup_centered()]
#endregion
#region function
func copy (select:Array[TreeItem]): #copy function
		var copy_tmp = []
		var copy_obj = func (tree:Array[TreeItem],buffer:Array,_self):
			for item:TreeItem in tree:
				if item.get_parent() == select[0].get_parent():
					buffer.append("root")
				if item.get_child_count() != 0:
					buffer.append([])
					buffer[-1].append(item.get_metadata(0).object)
					_self.call(item.get_children(),buffer[-1],_self)
				else :
					buffer.append(item.get_metadata(0).object)
		copy_obj.call(select,copy_tmp,copy_obj)
		return copy_tmp

func paste(buffer:Array,parent:TreeItem): 
		var paste_obj = func (arr:Array,tree:TreeItem,_self):
			var index = 0
			for item in arr:
				if index != 0:
					if item is PaperObject:
						var item_obj = tree.create_child()
						var obj_copy = item.duplicate()
						obj_copy.user_data = item.user_data.duplicate(true)
						obj_copy.display_name = item.display_name
						obj_copy.property = item.property.duplicate(true)
						item_obj.set_text(0,item.display_name)
						if ResourceLoader.exists(item.icon):
							item_obj.set_icon(0,load(item.icon))
						else :
							item_obj.set_icon(0,preload(fallback_icon))
						item_obj.set_icon_max_width(0,max_icon_width)
						item_obj.set_metadata(0,{
							object_name = item.object_name, 
							plugin_name = item.user_data.plugin,
							object = obj_copy,
							})
					if item is Array:
						var obj:PaperObject = item[0]
						var folder = tree.create_child()
						var obj_copy = obj.duplicate()
						obj_copy.user_data = obj.user_data.duplicate(true)
						obj_copy.display_name = obj.display_name
						obj_copy.property = obj.property.duplicate(true)
						folder.set_text(0,obj.display_name)
						if ResourceLoader.exists(obj.icon):
							folder.set_icon(0,load(obj.icon))
						else :
							folder.set_icon(0,preload(fallback_icon))
						folder.set_icon_max_width(0,max_icon_width)
						folder.set_metadata(0,{
							object_name = obj.object_name, 
							plugin_name = obj.user_data.plugin,
							object = obj_copy,
							})
						_self.call(item,folder,_self)
						print(obj.display_name)
				index = index +1
		for i in buffer:
			if i is PaperObject:
				var item = parent.create_child()
				var obj_copy = i.duplicate()
				obj_copy.user_data = i.user_data.duplicate(true)
				obj_copy.display_name = i.display_name
				obj_copy.property = i.property.duplicate(true)
				item.set_text(0,i.display_name)
				if ResourceLoader.exists(i.icon):
					item.set_icon(0,load(i.icon))
				else:
					item.set_icon(0,preload(fallback_icon))
				item.set_icon_max_width(0,max_icon_width)
				item.set_metadata(0,{
					object_name = i.object_name, 
					plugin_name = i.user_data.plugin,
					object = obj_copy,
					})
			if i is Array:
				var item = parent.create_child()
				var obj:PaperObject = i[0]
				var obj_copy = obj.duplicate()
				obj_copy.user_data = obj.user_data.duplicate(true)
				obj_copy.display_name = obj.display_name
				obj_copy.property = obj.property.duplicate(true)
				item.set_text(0,obj.display_name)
				if ResourceLoader.exists(obj.icon):
					item.set_icon(0,load(obj.icon))
				else:
					item.set_icon(0,preload(fallback_icon))
				item.set_icon_max_width(0,max_icon_width)
				item.set_metadata(0,{
					object_name = obj.object_name, 
					plugin_name = obj.user_data.plugin,
					object = obj_copy,
					})
				paste_obj.call(i,item,paste_obj)

func save (target:TreeItem): #save function
		#copy_buffer.append(%Tree.get_selected().get_metadata(0).object)
		var map = func (val,obj:PaperObject):
			if val is String:
				var meta = "meta/"+val
				return {name = meta, value = obj.get_meta(val)}
			if val.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
				var prop = val
				prop["value"] = obj.get(val.name)
				return prop
			else :
				return null
		var filter = func (val):
			if val is Dictionary:
				return val.usage & PROPERTY_USAGE_SCRIPT_VARIABLE
		var filter_amd_map = func (arr:Array,filter_func:Callable,map_func:Callable):
			var tmp = []
			for item in arr:
				if filter_func.call(item):
					tmp.append(map_func.call(item))
			return tmp
		var save_tmp = []
		var start:TreeItem = target
		var copy_obj = func (tree:TreeItem,buffer:Array,_self):
			if tree.get_metadata(0).has(&"root"):
				buffer.append("root")
			else:
				var obj:PaperObject = tree.get_metadata(0).object
				var list = obj.get_property_list()
				buffer.append(filter_amd_map.call(list,filter,map.bind(obj)))
			if target.get_child_count() != 0:
				#var index = 0
				for item:TreeItem in tree.get_children():
					if item.get_metadata(0).has("ignore"):
						continue
					if item.get_child_count() == 0:
						var obj:PaperObject = item.get_metadata(0).object
						var list = obj.get_property_list()
						buffer.append(filter_amd_map.call(list,filter,map.bind(obj)))
					else:
						buffer.append([])
						_self.call(item,buffer[-1],_self)
		copy_obj.call(start,save_tmp,copy_obj)
		return save_tmp

func load_obj(buffer:Array,tree:TreeItem= null):
	var index = 0 
	if buffer[0] is String:
		for i in tree.get_children():
			i.free()
	for item in buffer:
		if index != 0 :
			if item[0] is Dictionary:
				if not PluginManager.validate(item[5].value.plugin,item[0].value):
					continue
				var tree_item = tree.create_child()
				var obj:PaperObject = PluginManager.get_objects(item[5].value.plugin)[item[0].value].duplicate(true)
				obj.display_name = item[1].value
				obj.property = item[4].value
				obj.user_data = item[5].value
				tree_item.set_text(0,item[1].value)
				tree_item.set_icon_max_width(0,max_icon_width)
				if ResourceLoader.exists(item[6].value):
					tree_item.set_icon(0,load(item[6].value))
				else:
					tree_item.set_icon(0,preload(fallback_icon))
				tree_item.set_metadata(0,{
					object_name = item[1],
					plugin_name = obj.user_data.plugin,
					object = obj
				})
				#print(item,"\n")
		if item[0] is Array:
			var head = item[0]
			if not PluginManager.validate(head[5].value.plugin,head[0].value):
					continue
			var tree_item = tree.create_child()
			var obj:PaperObject = PluginManager.get_objects(head[5].value.plugin)[head[0].value].duplicate(true)
			obj.display_name = head[1].value
			obj.property = head[4].value
			obj.user_data = head[5].value
			tree_item.set_text(0,head[1].value)
			tree_item.set_icon_max_width(0,max_icon_width)
			if ResourceLoader.exists(head[6].value):
				tree_item.set_icon(0,load(head[6].value))
			else:
				tree_item.set_icon(0,preload(fallback_icon))
			tree_item.set_metadata(0,{
				object_name = head[1],
				plugin_name = obj.user_data.plugin,
				object = obj
			})
			load_obj(item,tree_item)
		index = index + 1

func add_object(plugin:String,object:StringName,show_item:bool=true,parent:TreeItem=null) -> TreeItem:
	if not PluginManager.validate(plugin,object):
		return null
	if parent == null:
		var item = root_item.create_child()
		var obj = PluginManager.get_objects(plugin)[object].duplicate()
		obj.user_data.plugin = plugin
		item.collapsed = true
		item.set_text(0,PluginManager.get_objects(plugin)[object].display_name)
		item.set_icon_max_width(0,max_icon_width)
		if ResourceLoader.exists(obj.icon):
			item.set_icon(0,load(obj.icon))
		else:
			item.set_icon(0,preload(fallback_icon))
		item.set_tooltip_text(0,"")
		item.visible = show_item
		item.set_metadata(0,{
			object_name = object, 
			plugin_name = plugin,
			object = obj,
			})
		if obj.has_method("on_create"):
			obj.on_create()
		return item
	else :
		var item = parent.create_child()
		var obj = PluginManager.get_objects(plugin)[object].duplicate()
		obj.user_data.plugin = plugin
		item.collapsed = true
		item.set_text(0,PluginManager.get_objects(plugin)[object].display_name)
		item.set_icon_max_width(0,max_icon_width)
		if ResourceLoader.exists(obj.icon):
			item.set_icon(0,load(obj.icon))
		else:
			item.set_icon(0,preload(fallback_icon))
		item.visible = show_item
		item.set_metadata(0,{
			object_name = object, 
			plugin_name = plugin,
			object = obj,
			})
		if obj.has_method("on_create"):
			obj.on_create()
		return item

#endregion
#region signals and events

func _init() -> void:
	add_child(insert_window)
	insert_window.hide()
	insert_window.insert.connect(_on_insert)

func _ready() -> void:
	root_item = %Tree.create_item()
	root_item.set_metadata(0,{root = true})
	get_tree().root.title = "new project"
	pass


func _exit_tree() -> void:
	get_tree().root.title = "paper"

func _on_insert(obj:PaperObject):
	if selceted_obj == null or insert_window.has_meta("on_root"):
		add_object(obj.get_meta("plugin"),obj.object_name)
		insert_window.remove_meta("on_root")
	else :
		add_object(obj.get_meta("plugin"),obj.object_name,true,selceted_obj[-1])
	for i in selceted_obj:
		i.deselect(0)
	selceted_obj.clear()
func _on_context(id:int):
	var file_dialog: FileDialog = $FileDialog
	var path = SaveManager.save_path+"/new project.paper"
	file_dialog.get_vbox().get_child(1).get_child(0).visible = false
	if id == 0:
		file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		file_dialog.current_path = path.get_base_dir()+"/"
		file_dialog.popup_centered()
	if id == 1:
		PanelManager.add_panel("inspector","uid://dpjufnn834qka",PanelManager.DockSlot.right,{unique = true})
	if id == 2:
		if not FileAccess.file_exists(file_dialog.current_path):
			var file_index = 1
			if FileAccess.file_exists(path):
				while FileAccess.file_exists(path):
					path = SaveManager.save_path+"/new project("+str(file_index)+").paper"
					file_index = file_index + 1
			file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			file_dialog.current_path = path
			file_dialog.popup_centered()
		else :
			SaveManager.data[&"object"] = save(root_item)
			SaveManager.save_project(file_dialog.current_path)
	if id == 3:
		var file_index = 1
		if FileAccess.file_exists(path):
			while FileAccess.file_exists(path):
				path = SaveManager.save_path+"/new project("+str(file_index)+").paper"
				file_index = file_index + 1
		file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		file_dialog.current_path = path
		file_dialog.set_meta("save_as",true)
		file_dialog.popup_centered()
	pass


func _on_file_dialog_file_selected(path: String) -> void:
	var file_dialog: FileDialog = $FileDialog
	if file_dialog.file_mode == FileDialog.FILE_MODE_SAVE_FILE:
		SaveManager.data[&"object"] = save(root_item)
		if file_dialog.has_meta("save_as"):
			file_dialog.remove_meta("save_as")
		SaveManager.save_project(path)
	if file_dialog.file_mode == FileDialog.FILE_MODE_OPEN_FILE:
		SaveManager.load_project(path)
		load_obj(SaveManager.data.object,root_item)
		get_tree().root.title = path.get_file().get_slice(".",0)
		pass

func _on_tree_item_mouse_selected(_mouse_position: Vector2, mouse_button_index: int) -> void:
	if selceted_obj[0] == root_item:
		return
	if mouse_button_index != 2:
		return
	var object:PaperObject = selceted_obj[0].get_metadata(0).object
	var context_menu:PopupMenu = PopupMenu.new()
	var action_menu:PopupMenu = PopupMenu.new()
	context_menu.reset_size()
	add_child(context_menu)
	context_menu.position = DisplayServer.mouse_get_position()
	for id in context_menu_option.size():
		context_menu.add_item(context_menu_option[id])
		if id <= context_disabled.size() - 1:
			context_menu.set_item_disabled(id,context_disabled[id])
	for item in object.action_menu:
		action_menu.add_item(item)
	context_menu.id_pressed.connect(func (id:int): 
		context_menu_func[id].call(),CONNECT_ONE_SHOT)
	context_menu.popup_hide.connect(func ():
		context_menu.queue_free()
		context_menu.clear(true)
		if action_menu.has_meta("null"):
			action_menu.queue_free()
		,CONNECT_ONE_SHOT)
	if action_menu.item_count != 0:
		context_menu.add_submenu_node_item("actions",action_menu)
	else :
		action_menu.set_meta("null",true)
	if object.has_method("on_action_picked"):
		if object.on_action_picked.get_argument_count() == 1:
			action_menu.id_pressed.connect(object.on_action_picked,ConnectFlags.CONNECT_ONE_SHOT)
	context_menu.show()

func _on_insert_pressed() -> void:
	if insert_window.get_parent() == null:
		add_child(insert_window)
		insert_window.insert.connect(_on_insert)
	insert_window.set_meta("on_root",true)
	insert_window.popup_centered()

func _on_tree_exiting() -> void:
	insert_window.queue_free()

func _on_tree_multi_selected(item: TreeItem, _column: int, selected: bool) -> void:
	if item.get_parent().is_selected(0):
		return
	if selected:
		selceted_obj.append(item)
	else:
		var index = selceted_obj.find(item)
		if index != -1:
			selceted_obj.remove_at(index)
	if selceted_obj.size() >= 1:
		var meta = selceted_obj[-1].get_metadata(0)
		HooksManager.call_hook("object_selected",meta.object)
	pass # Replace with function body.
#endregion
