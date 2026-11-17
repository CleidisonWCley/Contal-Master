extends SceneTree
# godot --headless --path <proj> -s touch_test.gd -- <scene|control|control_panel_buttons> [w h]
var inst: Node
var frames := 0
var scroll: ScrollContainer
var start_y := 0
var pressed_count := 0
var scene_path := ""
var P0 := Vector2.ZERO
var tap_mode := false

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	scene_path = args[0]
	var vs := Vector2i(int(args[1]), int(args[2])) if args.size() > 2 else Vector2i(1280, 592)
	root.content_scale_size = vs
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	if scene_path.begins_with("control"):
		inst = Control.new(); inst.set_anchors_preset(Control.PRESET_FULL_RECT)
		var sc := ScrollContainer.new(); sc.set_anchors_preset(Control.PRESET_FULL_RECT)
		sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		inst.add_child(sc)
		var vb := VBoxContainer.new(); vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL; sc.add_child(vb)
		for i in 40:
			if scene_path == "control_panel_buttons":
				var pc := PanelContainer.new(); var b := Button.new(); b.text = "btn %d" % i; b.custom_minimum_size = Vector2(0, 50); pc.add_child(b); vb.add_child(pc)
			else:
				var l := Label.new(); l.text = "linha %d" % i; l.custom_minimum_size = Vector2(0, 40); vb.add_child(l)
	else:
		inst = load(scene_path).instantiate()
	root.add_child(inst)

func _find_scroll(n: Node) -> ScrollContainer:
	if n is ScrollContainer and (n as ScrollContainer).is_visible_in_tree():
		return n
	for c in n.get_children():
		var r := _find_scroll(c)
		if r: return r
	return null

func _all_buttons(n: Node, out: Array) -> void:
	if n is BaseButton: out.append(n)
	for c in n.get_children(): _all_buttons(c, out)

func _tr(p: Vector2) -> Vector2:
	return root.get_final_transform() * p
func _touch(p: Vector2, pressed: bool) -> void:
	var e := InputEventScreenTouch.new(); e.index = 0; e.position = _tr(p); e.pressed = pressed
	Input.parse_input_event(e)
func _drag(p: Vector2, rel: Vector2) -> void:
	var e := InputEventScreenDrag.new(); e.index = 0; e.position = _tr(p)
	e.relative = root.get_final_transform().basis_xform(rel)
	Input.parse_input_event(e)

func _process(_d: float) -> bool:
	frames += 1
	if frames == 15:
		scroll = _find_scroll(inst)
		if scroll == null:
			print("RESULT no_scroll_found"); quit(2); return true
		var bar := scroll.get_v_scroll_bar()
		print("visible=", root.get_visible_rect().size, " scroll rect=", scroll.get_global_rect(), " max=", bar.max_value, " page=", bar.page)
		var btns := []
		_all_buttons(inst, btns)
		for b in btns: (b as BaseButton).pressed.connect(func(): pressed_count += 1)
		start_y = scroll.scroll_vertical
		if OS.get_cmdline_user_args().size() > 3 and OS.get_cmdline_user_args()[3] == "tap":
			var target: BaseButton = null
			for b in btns:
				var bb := b as BaseButton
				if scroll.is_ancestor_of(bb) and bb.is_visible_in_tree() and scroll.get_global_rect().encloses(bb.get_global_rect()):
					target = bb; break
			if target == null: print("RESULT tap_no_button"); quit(3); return true
			var c := target.get_global_rect().get_center()
			print("tap on ", target.name, " at ", c)
			_touch(c, true)
			P0 = c
			tap_mode = true
			return false
		var r := scroll.get_global_rect()
		P0 = Vector2(r.position.x + r.size.x * 0.3, r.position.y + r.size.y * 0.75)
		print("touch at ", P0, " hit=", root.gui_get_hovered_control() if false else "?")
		_touch(P0, true)
	elif tap_mode and frames == 20:
		_touch(P0, false)
	elif tap_mode and frames == 40:
		print("RESULT tap pressed_signals=", pressed_count); quit(0)
	elif tap_mode:
		pass
	elif frames > 15 and frames <= 35:
		_drag(P0 + Vector2(0, -(frames - 15) * 6.0), Vector2(0, -6.0))
	elif frames == 36:
		_touch(P0 + Vector2(0, -120), false)
	elif frames == 70:
		print("RESULT scroll_before=", start_y, " scroll_after=", scroll.scroll_vertical, " pressed_signals_during_drag=", pressed_count)
		quit(0)
	return false
