extends PanelContainer
@export var tes:VisualShaderNodeCubemap
func _ready() -> void:
	HooksManager.add_hook("object_selected",_on_select)
	$storage.visible = false
func _on_select(selected:PaperObject):
	var wraper:Array[Control] = [%wraper]
	for child in %wraper.get_children():
		child.queue_free()
	for property in selected.property:
		var hints:PackedStringArray = property.hint.remove_chars("\n").split(";")
		if "#IsArray" in hints:
			#region type int
			if property.type == TYPE_INT:
				var range_info = {
					allow_greater = true,
					allow_lesser = true,
					min_value = 0,
					max_value = 0,
					step = 1
				}
				if not property.value is Array:
					property.original = property.value
				var prop = VBoxContainer.new()
				var array_wraper = VBoxContainer.new()
				var label = Label.new()
				var fold = FoldableContainer.new()
				var button:Button = Button.new()
				var set_item = func (val,idx):
					property.value[idx] = val
				var remove_item = func (item_wrap):
						item_wrap.queue_free()
						property.value.remove_at(item_wrap.get_index())
						fold.title = "array (size "+ str(property.value.size()) + ")"
				button.text = "new item"
				button.name = "new"
				fold.title = "array (size 0)"
				fold.fold()
				label.label_settings = LabelSettings.new()
				label.name = "text"
				label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				array_wraper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				label.text = property.name.replace("_"," ")
				for hint in hints:
					if hint.begins_with("#MinValue"):
						var param = hint.split(",")
						if param.size() > 1:
							range_info.allow_lesser = false
							range_info.min_value = int(param[1])
						continue
					if hint.begins_with("#MaxValue"):
						var param = hint.split(",")
						if param.size() > 1:
							range_info.allow_greater = false
							range_info.max_value = int(param[1])
						continue
					if hint.begins_with("#Step"):
						var param = hint.split(",")
						if param.size() > 1 :
							if int(param[1]) > 0:
								range_info.step = int(param[1])
							else :
								range_info.step = 1
						continue
					if hint.begins_with("#DisplayName"):
						var param = hint.split(",")
						if param.size() > 1:
							label.text = param[1]
					if hint.begins_with("#Values"):
						var param = hint.split(",")
						if param.size() < 1:
							continue
						if property.value is Array:
							continue
						property.value = []
						var i = 0
						for item in param:
							if i != 0:
								property.value.append(int(item))
							i = i +1
				#TODO make this code bellow shorter
				for idx in property.value.size():
					var item_wrap = HBoxContainer.new()
					var value:SpinBox = SpinBox.new()
					var remove_btn:Button = Button.new()
					var number:LineEdit = value.get_child(0,true)
					item_wrap.custom_minimum_size.y = theme.get_constant("height","Array")
					value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					value.min_value = range_info.min_value
					value.allow_lesser = range_info.allow_lesser
					value.max_value = range_info.max_value
					value.allow_greater = range_info.allow_greater
					value.step = range_info.step
					value.value = property.value[idx]
					remove_btn.custom_minimum_size.x = theme.get_constant("remove_width","Array")
					remove_btn.text = "X"
					remove_btn.pressed.connect(remove_item.bind(item_wrap))
					value.value_changed.connect(set_item.bind(item_wrap.get_index()))
					number.add_theme_stylebox_override("normal",theme.get_stylebox("panel","int"))
					item_wrap.add_child(value)
					item_wrap.add_child(remove_btn)
					array_wraper.add_child(item_wrap)
				button.pressed.connect(func ():
					property.value.append(property.original)
					var item_wrap = HBoxContainer.new()
					var value:SpinBox = SpinBox.new()
					var remove_btn:Button = Button.new()
					var number:LineEdit = value.get_child(0,true)
					item_wrap.custom_minimum_size.y = theme.get_constant("height","Array")
					value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					value.min_value = range_info.min_value
					value.allow_lesser = range_info.allow_lesser
					value.max_value = range_info.max_value
					value.allow_greater = range_info.allow_greater
					value.step = range_info.step
					value.value = property.value[-1]
					fold.title = "array (size "+ str(property.value.size()) + ")"
					remove_btn.custom_minimum_size.x = theme.get_constant("remove_width","Array")
					remove_btn.text = "X"
					remove_btn.pressed.connect(remove_item.bind(item_wrap))
					value.value_changed.connect(set_item.bind(item_wrap.get_index()))
					number.add_theme_stylebox_override("normal",theme.get_stylebox("panel","int"))
					item_wrap.add_child(value)
					item_wrap.add_child(remove_btn)
					array_wraper.add_child(item_wrap)
					button.move_to_front()
					)
				button.tree_exiting.connect(func ():
					property.value = property.value
					)
				fold.title = "array (size "+ str(property.value.size()) + ")"
				prop.add_child(label)
				prop.add_child(fold)
				fold.add_child(array_wraper)
				array_wraper.add_child(button)
				wraper[-1].add_child(prop)
				continue
				#endregion
			#region type color
			if property.type == TYPE_COLOR:
				var property_info = {
					edit_alpha = true,
					edit_intensity = true,
					presets_visible = true,
					hex_visible = true,
					sliders_visible = true,
					color_modes_visible = true,
					sampler_visible = true,
					centered = false,
					offset = null,
					position = null,
					title = null
				}
				var prop = VBoxContainer.new()
				var array_wraper = VBoxContainer.new()
				var label = Label.new()
				var fold = FoldableContainer.new()
				var button:Button = Button.new()
				var include_alpha = false
				label.text = property.name.replace("_"," ")
				label.label_settings = LabelSettings.new()
				fold.title = "array (size 0)"
				button.text = "new item"
				fold.fold()
				if not property.value is Array:
					property.original = property.value
				var add_item = func (target:VBoxContainer,val:Color,index,add:bool):
					if add:
						property.value.append(val)
					var item_wraper = HBoxContainer.new()
					var value:ColorPickerButton = ColorPickerButton.new()
					var remove:Button = Button.new()
					var picker:ColorPicker = value.get_picker()
					var popup:Popup = value.get_popup()
					remove.text = "X"
					remove.custom_minimum_size.x = theme.get_constant("remove_width","Array")
					value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					value.color = val
					value.custom_minimum_size.y = theme.get_constant("height","Array")
					value.edit_alpha = property_info.edit_alpha
					value.edit_intensity = property_info.edit_intensity
					picker.presets_visible = property_info.presets_visible
					picker.hex_visible = property_info.hex_visible
					picker.sliders_visible = property_info.sliders_visible
					picker.color_modes_visible = property_info.color_modes_visible
					picker.sampler_visible = property_info.sampler_visible
					if property_info.title is String:
						popup.borderless = false
						popup.title = property_info.title
					popup.about_to_popup.connect(func ():
						if property_info.centered:
							@warning_ignore("integer_division")
							popup.position.x = int(get_tree().root.position.x + float(get_tree().root.size.x) / 2 - (popup.size.x / 2))
							@warning_ignore("integer_division")
							popup.position.y = int(get_tree().root.position.y + float(get_tree().root.size.y) / 2 - (popup.size.y / 2))
						if property_info.offset is Vector2i:
							popup.position = popup.position + property_info.offset
						)
					popup.add_theme_stylebox_override("panel",theme.get_stylebox("picker_panel","Color"))
					remove.pressed.connect(func ():
						property.value.remove_at(item_wraper.get_index())
						item_wraper.queue_free()
						fold.title = "array (size "+str(property.value.size())+")"
						)
					value.color_changed.connect(func (col):
						property.value[index] = col
						)
					item_wraper.add_child(value)
					item_wraper.add_child(remove)
					target.add_child(item_wraper)
					if add:
						button.move_to_front()
						fold.title = "array (size "+str(property.value.size())+")"
				for hint in hints:
					if hint == "#NoAlpha":
						property_info.edit_alpha = false
					elif hint == "#NoIntensity":
						property_info.edit_intensity = false
					elif hint == "#NoPreset":
						property_info.presets_visible = false
					elif hint == "#NoHex":
						property_info.hex_visible = false
					elif hint == "#NoSlider":
						property_info.sliders_visible = false
					elif hint == "#NoColorMode":
						property_info.color_modes_visible = false
					elif hint == "#NoSampler":
						property_info.sampler_visible = false
					elif hint == "#IncludeAlpha":
						include_alpha = true
					elif hint =="#Centerd":
						property_info.centered = true
					elif hint.begins_with("#DisplayName"):
						var param = hint.split(",",false)
						if param.size() < 1:
							continue
						label.text = param[1]
					if hint.begins_with("#Title"):
						var param = hint.split(",")
						if param.size() > 1:
							property_info.title = param[1]
					if hint.begins_with("#Offset"):
						var param = hint.split(",")
						if param.size() > 2:
							property_info.offset = Vector2i(int(param[1]),int(param[2]))
					elif hint.begins_with("#Values"):
						var param = hint.split(",",false)
						if param.size() < 1:
							continue
						if property.value is Array:
							continue
						property.value = []
						var idx = 0
						var color:Color
						for item in param:
							if idx != 0:
								if include_alpha:
									if idx%4 == 1:
										color.r8 = int(param[idx])
									if idx%4 == 2:
										color.g8 = int(param[idx])
									if idx%4 == 3:
										color.b8 = int(param[idx])
									if idx%4 == 0:
										color.a8 = int(param[idx])
										property.value.append(color)
								else :
									if idx%3 == 1:
										color.r8 = int(param[idx])
									if idx%3 == 2:
										color.g8 = int(param[idx])
									if idx%3 == 0:
										color.b8 = int(param[idx])
										property.value.append(color)
										
							idx = idx +1
				var i = 0
				for color in property.value:
					fold.title = "array (size "+str(property.value.size())+")"
					add_item.call(array_wraper,color,i,false)
					i = i + 1
				button.pressed.connect(add_item.bind(array_wraper,property.original,property.value.size(),true))
				prop.add_child(label)
				prop.add_child(fold)
				fold.add_child(array_wraper)
				array_wraper.add_child(button)
				wraper[-1].add_child(prop)
				pass
			continue
#endregion
		#region property
		elif property.type == 0:
			var prop = $storage/types/Nil.duplicate()
			var panel:PanelContainer = prop.get_node("panel")
			var label:Label = prop.get_node("panel/Label")
			if property.value is String:
				label.text = property.value
			else :
				label.text = property.name.replace("_"," ")
			for hint in hints:
				if hint == "#Fold":
					var fold_wraper = VBoxContainer.new()
					var fold = FoldableContainer.new()
					fold.folded = true
					if property.value is String:
						fold.title = property.value
					else :
						fold.title = property.name.replace("_"," ")
					fold.add_child(fold_wraper)
					prop.queue_free()
					wraper[-1].add_child(fold)
					wraper.append(fold_wraper)
					continue
				if hint == "#FoldBreak":
					if wraper[-1] != %wraper:
						wraper.pop_back()
						prop.queue_free()
			panel.add_theme_stylebox_override("panel",theme.get_stylebox("panel","Nil"))
			label.label_settings.font_color = theme.get_color("text_color","Nil")
			label.label_settings.font_size = theme.get_font_size("text_size","Nil")
			label.label_settings.font = theme.get_font("text_font","Nil")
			wraper[-1].add_child(prop)
		elif property.type == TYPE_BOOL:
			var prop = $storage/types/bool.duplicate()
			var label:Label = prop.get_node("Label")
			var value:CheckBox = prop.get_node("value")
			label.text =  property.name.replace("_"," ")
			if not "#Array" in hints:
				value.button_pressed = property.value
			value.toggled.connect(func (on:bool):
				if on:
					value.text = "on"
				else:
					value.text = "off"
				property.value = on)
			if value.button_pressed:
				value.text = "on"
			else:
				value.text = "off"
			for hint in hints:
				if hint.begins_with("#DisplayName"):
					var param = hint.split(",")
					if param.size() > 1:
						label.text = param[1]
				continue
			label.label_settings.font_size = theme.get_font_size("text_size","bool")
			label.label_settings.font = theme.get_font("text_font","bool")
			label.label_settings.font_color = theme.get_color("text_color","bool")
			value.add_theme_stylebox_override("normal",theme.get_stylebox("panel","bool"))
			value.add_theme_stylebox_override("focus",theme.get_stylebox("focus","bool"))
			value.add_theme_stylebox_override("disabled",theme.get_stylebox("disabled","bool"))
			value.add_theme_color_override("checkbox_checked_color",theme.get_color("true","bool"))
			value.add_theme_color_override("checkbox_unchecked_color",theme.get_color("false","bool"))
			wraper[-1].add_child(prop)
		elif property.type == TYPE_STRING:
			var prop:BoxContainer = $storage/types/String.duplicate()
			var label:Label = prop.get_node("Label")
			var value:Control = prop.get_node("value")
			label.text = property.name.replace("_"," ")
			if not "#Array" in hints:
				value.text = property.value
			value.text_submitted.connect(func (text:String):
				property.value = text
				)
			for hint in hints:
				if hint == "#Multiline":
					if not value is LineEdit:
						continue
					var btn:Button = Button.new()
					var multiline = TextEdit.new()
					var window:Window = $"storage/edit text window"
					var text_edit:TextEdit = $"storage/edit text window/wraper/TextEdit"
					multiline.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
					var text_changed = func ():
						multiline.text = text_edit.text
						property.value = text_edit.text
						pass
					var on_close = func ():
						window.hide()
					prop.vertical = true
					multiline.custom_minimum_size.x = value.custom_minimum_size.x
					multiline.custom_minimum_size.y = 200
					btn.custom_minimum_size = value.custom_minimum_size
					btn.text = "..."
					multiline.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					prop.add_child(multiline)
					prop.add_child(btn)
					multiline.text_changed.connect(func ():
						property.value = multiline.text
						)
					btn.pressed.connect(func ():
						text_edit.text = property.value
						window.popup_centered()
						)
					text_edit.text_changed.connect(text_changed)
					window.close_requested.connect(on_close)
					multiline.text = property.value
					prop.tree_exiting.connect(func ():
						text_edit.text_changed.disconnect(text_changed)
						window.close_requested.disconnect(on_close)
						)
					value.queue_free()
					value = multiline
				elif hint.begins_with("#PlaceHolder"):
					var param = hint.split(",")
					if param.size() > 1:
						value.placeholder_text = param[1]
				elif hint.begins_with("#DisplayName"):
					var param = hint.split(",")
					if param.size() > 1:
						label.set_meta("has_display",true)
						label.text = param[1]
				elif hint.begins_with("#CharLimit"):
					var param = hint.split(",")
					if value is LineEdit and param.size() > 1:
						value.max_length = int(param[1])
			label.label_settings.font_size = theme.get_font_size("text_size","String")
			label.label_settings.font = theme.get_font("text_font","String")
			label.label_settings.font_color = theme.get_color("text_color","String")
			value.add_theme_stylebox_override("normal",theme.get_stylebox("panel","String"))
			value.add_theme_stylebox_override("focus",theme.get_stylebox("focus","String"))
			wraper[-1].add_child(prop)
		elif property.type == TYPE_COLOR:
			var prop = $storage/types/Color.duplicate()
			var label:Label = prop.get_node("Label")
			var value:ColorPickerButton = prop.get_node("value")
			var popup:Popup = value.get_popup()
			value.color_changed.connect(func(col): property.value = col)
			label.label_settings.font_size = theme.get_font_size("text_size","Color")
			label.label_settings.font = theme.get_font("text_font","Color")
			label.label_settings.font_color = theme.get_color("text_color","Color")
			popup.add_theme_stylebox_override("panel",theme.get_stylebox("picker_panel","Color"))
			value.add_theme_stylebox_override("normal",theme.get_stylebox("panel","Color"))
			value.add_theme_stylebox_override("hover",theme.get_stylebox("hover","Color"))
			label.text = property.name.replace("_"," ")
			value.color = property.value
			for hint in hints:
				if hint == "#NoAlpha":
					value.edit_alpha = false
				elif hint == "#NoIntensity":
					value.edit_intensity = false
				elif hint == "#NoPreset":
					value.get_picker().presets_visible = false
				elif hint == "#NoHex":
					value.get_picker().hex_visible = false
				elif hint == "#NoSlider":
					value.get_picker().sliders_visible = false
				elif hint == "#NoColorMode":
					value.get_picker().color_modes_visible = false
				elif hint == "#NoSampler":
					value.get_picker().sampler_visible = false
				elif hint == "#Centerd":
					popup.about_to_popup.connect(func ():
						@warning_ignore("integer_division")
						popup.position.x = int(get_tree().root.position.x + get_tree().root.size.x / 2 - (popup.size.x / 2))
						@warning_ignore("integer_division")
						popup.position.y = int(get_tree().root.position.y + get_tree().root.size.y / 2 - (popup.size.y / 2))
						)
				elif hint.begins_with("#DisplayName"):
					var param = hint.split(",")
					if param.size() > 1:
						label.text = param[1]
				elif hint.begins_with("#Offset"):
					var param = hint.split(",")
					if param.size() > 2:
						popup.about_to_popup.connect(func ():
							popup.position.x += int(param[1])
							popup.position.x += int(param[2]))
				elif hint.begins_with("#Title"):
					var param = hint.split(",")
					if param.size() > 1:
						popup.borderless = false
						popup.title = param[1]
			wraper[-1].add_child(prop)
		elif property.type == TYPE_INT:
			var prop:BoxContainer = $storage/types/Int.duplicate()
			var label:Label = prop.get_node("Label")
			var value:Control = prop.get_node("value")
			var number:LineEdit = value.get_child(0,true)
			label.text = property.name.replace("_"," ")
			value.value_changed.connect(func (val):
				property.value = val
				)
			for hint in hints:
				if hint.begins_with("#DisplayName"):
					var param = hint.split(",")
					if param.size() > 1:
						label.text = param[1]
				elif hint.begins_with("#MinValue"):
					var param = hint.split(",")
					if param.size() > 1 and value is SpinBox:
						value.allow_lesser = false
						value.min_value = int(param[1])
				elif hint.begins_with("#MaxValue"):
					var param = hint.split(",")
					if param.size() > 1 and value is SpinBox:
						value.allow_greater = false
						value.max_value = int(param[1])
				elif hint.begins_with("#Step"):
					var param = hint.split(",")
					if param.size() > 1 and value is SpinBox:
						if int(param[1]) > 0:
							value.step = int(param[1])
						else :
							value.step = 1
				elif hint == "#BitFlags":
					if not value is SpinBox:
						continue
					value.queue_free()
					prop.vertical = true
					var mask = 1
					var panel_bg = PanelContainer.new()
					var grid = GridContainer.new()
					var fold = FoldableContainer.new()
					fold.title = "flags: (value: "+str(property.value)+")"
					fold.fold()
					fold.title_text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
					grid.columns = 8
					panel_bg.custom_minimum_size.y = theme.get_constant("v_bg_size","int_flag")
					panel_bg.add_theme_stylebox_override("panel",theme.get_stylebox("bg","int_flag"))
					for index in range(64):
						var panel:PanelContainer = PanelContainer.new()
						var text = Label.new()
						text.label_settings = LabelSettings.new()
						text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
						text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
						text.label_settings.font_color = theme.get_color("flag_text_color","int_flag")
						text.label_settings.font_size = theme.get_font_size("flag_text_size","int_flag")
						text.label_settings.font = theme.get_font("flag_text_font","int_flag")
						text.mouse_filter = Control.MOUSE_FILTER_PASS
						text.text = str(index+1)
						panel.custom_minimum_size = Vector2(30,30)
						if property.value & mask == 0:
							panel.add_theme_stylebox_override("panel",theme.get_stylebox("off","int_flag"))
						else :
							panel.add_theme_stylebox_override("panel",theme.get_stylebox("on","int_flag"))
						panel.gui_input.connect(func (event:InputEvent):
							if event is InputEventMouseButton:
								if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
									property.value = property.value^mask
									fold.title = "flags: (value: "+str(property.value)+")"
									if property.value & mask == 0:
										panel.add_theme_stylebox_override("panel",theme.get_stylebox("off","int_flag"))
									else:
										panel.add_theme_stylebox_override("panel",theme.get_stylebox("on","int_flag"))
							)
						panel.add_child(text)
						grid.add_child(panel)
						mask = mask << 1
					panel_bg.add_child(grid)
					fold.add_child(panel_bg)
					prop.add_child(fold)
				elif hint.begins_with("#Options"):
					var param = hint.split(",")
					if param.size() > 1 and value is SpinBox:
						value.queue_free()
						value = OptionButton.new()
						var popup:Popup = value.get_popup()
						value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
						prop.add_child(value)
						value.item_selected.connect(func (id): property.value = id)
						var idx = 0
						for item in param:
							if idx != 0:
								value.add_item(item)
							idx = idx + 1
						if value.item_count > property.value:
							value.selected = property.value
						else :
							value.selected = -1
						popup.visibility_changed.connect(func ():
							if popup.visible:
								popup.get_child(0,true).add_theme_stylebox_override("panel",theme.get_stylebox("popup_panel","int_option"))
							)
			label.label_settings.font_size = theme.get_font_size("text_size","int")
			label.label_settings.font = theme.get_font("text_font","int")
			label.label_settings.font_color = theme.get_color("text_color","int")
			if value is SpinBox:
				number.add_theme_stylebox_override("normal",theme.get_stylebox("panel","int"))
				value.value = property.value
			wraper[-1].add_child(prop)
		elif property.type == TYPE_CALLABLE:
			if not property.value.is_valid():
				continue
			var prop = $storage/types/callable.duplicate()
			var btn:Button = prop.get_node("Button")
			btn.text = property.name.replace("_"," ")
			if property.value.get_argument_count() == 0:
				btn.pressed.connect(property.value)
			else:
				btn.pressed.connect(property.value.bind(btn))
			for hint in hints:
				if hint.begins_with("#DisplayName"):
					var param = hint.split(",")
					if param.size() > 1:
						btn.text = param[1]
						
			wraper[-1].add_child(prop)
#endregion
