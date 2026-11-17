extends Control
## V0.15 - Ficha completa de um personagem ("char:<id>"), aberta a partir de "Perfis da Equipe".
## V0.15.2: o cabecalho ganhou o cenario do minigame do personagem; os capitulos da firma agora sao lidos em FirmaArchive.
## Personagem: cabecalho (retrato, nome, cargo, confianca) + abas Perfil / Gostos e forcas / Origem e motivacao /
##   Relacoes / Momento marcante / Lembrancas. Abas fechadas mostram cadeado e como abrir (LoreManager.DOSSIER_TABS).
## Dados: scripts/data/lore/dossiers.json e firma.json. Nada de medidas do corpo: so altura.
## Uma unica rolagem para a pagina inteira (cabecalho + abas + texto), pensada para celular em pe.

var entry_kind: String = "char"
var entry_id: String = ""

var _safe: MarginContainer
var _box: VBoxContainer
var _tab_flow: HFlowContainer
var _body: VBoxContainer
var _tab_buttons: Dictionary = {}
var _current_tab: String = ""
var _back_button: Button


func _ready() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_music("menu")
	var parts: PackedStringArray = GameManager.archive_entry.split(":")
	entry_kind = parts[0] if parts.size() > 0 else "char"
	entry_id = parts[1] if parts.size() > 1 else ""
	if entry_kind == "firma":
		# compatibilidade: atalhos antigos "firma:<capitulo>" abrem a tela nova
		GameManager.firma_selected_chapter = entry_id
		GameManager.call_deferred("open_firma_archive")
		return
	UiBackdrop.attach(self)
	_build()
	_apply_layout()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_layout()


func _build() -> void:
	_safe = MarginContainer.new()
	_safe.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_safe)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_safe.add_child(scroll)
	TouchScroll.attach(scroll)   # V0.15.6: rolar com o dedo (celular/tablet)
	var pad: MarginContainer = UiKit.margin(10, 10, 10, 10)
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(pad)
	_box = VBoxContainer.new()
	_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_box.add_theme_constant_override("separation", 12)
	pad.add_child(_box)

	var tabs: Array = []
	_box.add_child(_character_header())
	for tab in LoreManager.DOSSIER_TABS:
		tabs.append({"id": str(tab.get("id", "")), "title": str(tab.get("title", "")),
			"locked": not LoreManager.is_tab_unlocked(entry_id, tab)})
	# abre na primeira aba liberada (ou em "Lembrancas" se nada abriu)
	_current_tab = "lembrancas"
	for tab_info in tabs:
		if not bool((tab_info as Dictionary).get("locked", false)):
			_current_tab = str((tab_info as Dictionary).get("id", ""))
			break

	_tab_flow = HFlowContainer.new()
	_tab_flow.add_theme_constant_override("h_separation", 8)
	_tab_flow.add_theme_constant_override("v_separation", 8)
	_tab_flow.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_box.add_child(_tab_flow)
	for tab_info in tabs:
		var info: Dictionary = tab_info as Dictionary
		var button: Button = Button.new()
		button.text = str(info.get("title", ""))
		if bool(info.get("locked", false)):
			button.icon = UiIcons.texture("lock")
			button.expand_icon = true
			button.add_theme_constant_override("icon_max_width", 18)
		button.pressed.connect(_select_tab.bind(str(info.get("id", ""))))
		_tab_flow.add_child(button)
		_tab_buttons[str(info.get("id", ""))] = {"button": button, "locked": bool(info.get("locked", false))}

	var card: PanelContainer = PanelContainer.new()
	card.add_theme_stylebox_override("panel", UiKit.card_style(18))
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_box.add_child(card)
	var inner: MarginContainer = UiKit.margin(16, 16, 14, 14)
	card.add_child(inner)
	_body = VBoxContainer.new()
	_body.add_theme_constant_override("separation", 8)
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inner.add_child(_body)

	var holder: CenterContainer = CenterContainer.new()
	_box.add_child(holder)
	_back_button = UiKit.back_button()
	_back_button.pressed.connect(_on_back_pressed)
	holder.add_child(_back_button)
	_select_tab(_current_tab)


func _character_header() -> Control:
	var dossier: Dictionary = LoreManager.get_dossier(entry_id)
	var level: int = LoreManager.get_character_level(entry_id)
	var wrapper: VBoxContainer = VBoxContainer.new()
	wrapper.add_theme_constant_override("separation", 10)
	# V0.15.2: cenario do minigame do personagem no topo da ficha
	wrapper.add_child(ArchiveArt.make_banner(entry_id, 110.0 if ScreenTools.is_compact(self) else 150.0, level < 1))
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	var portrait: FaceAvatar = FaceAvatar.create(entry_id, 104.0, level < 1)
	portrait.backdrop = UiPalette.with_alpha(UiPalette.CARD, 0.9)
	row.add_child(portrait)
	var column: VBoxContainer = VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 3)
	row.add_child(column)
	var shown_name: String = str(dossier.get("name", entry_id.capitalize()))
	column.add_child(UiKit.label(shown_name if level >= 1 else "???", 30, UiPalette.TEXT_ON_DARK))
	var role: Label = UiKit.label(str(dossier.get("role", "")) if level >= 1 else "Ainda não nos conhecemos bem.", 15, UiPalette.TEXT_MUTED)
	role.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(role)
	column.add_child(UiKit.label("Confiança: %s  %s" % ["★".repeat(level) + "☆".repeat(3 - level), LoreManager.get_level_name(level)], 15, UiPalette.DIFF_NORMAL))
	wrapper.add_child(row)
	return wrapper


# ---------------------------------------------------------------- abas

func _select_tab(tab_id: String) -> void:
	_current_tab = tab_id
	for key in _tab_buttons.keys():
		var entry: Dictionary = _tab_buttons[key] as Dictionary
		var button: Button = entry["button"] as Button
		var active: bool = str(key) == tab_id
		ButtonStyles.apply(button, "ui_toggle_on" if active else "ui_ghost", Vector2(0, 42), 15)
	for child in _body.get_children():
		child.queue_free()
	_fill_character_tab(tab_id)


func _para(text: String, muted: bool = false, size_px: int = 16) -> Label:
	var label: Label = UiKit.label(text, size_px, UiPalette.TEXT_MUTED if muted else UiPalette.TEXT_ON_DARK)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label


## V0.15.5 - Uma fala da lembranca: "Nome:" na cor do personagem + o texto. Aceita o quadro {"s","t"} (e texto simples,
## por seguranca). Antes o quadro inteiro virava texto e aparecia { "s": ..., "t": ... } na tela.
func _speech(frame: Variant, size_px: int = 16) -> RichTextLabel:
	var speaker: String = ""
	var text: String = ""
	if frame is Dictionary:
		speaker = str((frame as Dictionary).get("s", ""))
		text = str((frame as Dictionary).get("t", ""))
	else:
		text = str(frame)
	var line: RichTextLabel = RichTextLabel.new()
	line.bbcode_enabled = true
	line.fit_content = true
	line.scroll_active = false
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE   # a rolagem da pagina continua funcionando
	line.add_theme_font_size_override("normal_font_size", size_px)
	line.add_theme_font_size_override("bold_font_size", size_px)
	line.add_theme_color_override("default_color", UiPalette.TEXT_ON_DARK)
	var safe_text: String = text.replace("[", "[lb]")
	if speaker == "":
		line.text = safe_text
	else:
		var who: String = str(LoreManager.CHARACTER_NAMES.get(speaker, speaker.capitalize()))
		line.text = "[b][color=#%s]%s:[/color][/b] %s" % [LoreManager.character_color(speaker).to_html(false), who, safe_text]
	return line


func _heading(text: String) -> Label:
	return UiKit.label(text, 19, UiPalette.ACCENT_REWARDS)


func _bullets(items: Array) -> void:
	for item in items:
		_body.add_child(_para("•  " + str(item)))


func _locked_message(hint: String) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.add_child(UiIcons.make_rect("lock", 26, UiPalette.TEXT_MUTED))
	row.add_child(_para(hint, true))
	_body.add_child(row)


func _fill_character_tab(tab_id: String) -> void:
	var dossier: Dictionary = LoreManager.get_dossier(entry_id)
	var tab: Dictionary = {}
	for candidate in LoreManager.DOSSIER_TABS:
		if str(candidate.get("id", "")) == tab_id:
			tab = candidate
	if dossier.is_empty() or tab.is_empty():
		_body.add_child(_para("Ficha indisponível.", true))
		return
	if not LoreManager.is_tab_unlocked(entry_id, tab):
		_locked_message("Bloqueado até o nível %d (%s). %s" % [int(tab.get("min_level", 1)),
			LoreManager.get_level_name(int(tab.get("min_level", 1))), LoreManager.unlock_hint_for_character(entry_id)])
		return
	match tab_id:
		"perfil":
			for pair in dossier.get("info", []) as Array:
				var row: Array = pair as Array
				var line: HBoxContainer = HBoxContainer.new()
				line.add_theme_constant_override("separation", 10)
				var key_label: Label = UiKit.label(str(row[0]), 15, UiPalette.TEXT_MUTED)
				key_label.custom_minimum_size = Vector2(120, 0)
				key_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				line.add_child(key_label)
				line.add_child(_para(str(row[1]), false, 16))
				_body.add_child(line)
			_body.add_child(_heading("Personalidade"))
			for text in dossier.get("personality", []) as Array:
				_body.add_child(_para(str(text)))
			_body.add_child(_heading("Hobbies"))
			_bullets(dossier.get("hobbies", []) as Array)
		"gostos":
			_body.add_child(_heading("Mais gosta de fazer"))
			_bullets(dossier.get("likes", []) as Array)
			_body.add_child(_heading("Menos gosta de fazer"))
			_bullets(dossier.get("dislikes", []) as Array)
			_body.add_child(_heading("Pontos fortes"))
			_bullets(dossier.get("strengths", []) as Array)
			_body.add_child(_heading("Pontos fracos"))
			_bullets(dossier.get("weaknesses", []) as Array)
		"origem":
			_body.add_child(_heading("O que o move"))
			for text in dossier.get("motivation", []) as Array:
				_body.add_child(_para(str(text)))
			_body.add_child(_heading("Na Ilha Faroleira"))
			for text in dossier.get("island", []) as Array:
				_body.add_child(_para(str(text)))
		"relacoes":
			for pair in dossier.get("relations", []) as Array:
				var row2: Array = pair as Array
				_body.add_child(_heading(str(row2[0])))
				_body.add_child(_para(str(row2[1])))
		"momento":
			_body.add_child(_heading("Momento marcante"))
			_body.add_child(_para(str(dossier.get("moment", ""))))
			_body.add_child(_heading("O que quer"))
			_body.add_child(_para(str(dossier.get("wants", ""))))
			_body.add_child(_heading("O que teme"))
			_body.add_child(_para(str(dossier.get("fears", ""))))
		"lembrancas":
			var seen: Array = LoreManager.seen_fragments_of(entry_id)
			if seen.is_empty():
				_body.add_child(_para("Nenhuma conversa guardada ainda. No Modo Livre, depois do minigame dele, o personagem conversa com você e conta a própria história.", true))
			for item in seen:
				var fragment: Dictionary = item as Dictionary
				_body.add_child(_heading(str(fragment.get("title", ""))))
				for frame in fragment.get("frames", []) as Array:
					_body.add_child(_speech(frame))


func _apply_layout() -> void:
	if _safe == null:
		return
	var view: Vector2 = ScreenTools.get_viewport_size(self)
	var compact: bool = ScreenTools.is_compact(self)
	var margin_x: int = 8 if view.x < 560.0 else (16 if compact else 28)
	_safe.add_theme_constant_override("margin_left", margin_x)
	_safe.add_theme_constant_override("margin_right", margin_x)
	_safe.add_theme_constant_override("margin_top", 6 if compact else 24)
	_safe.add_theme_constant_override("margin_bottom", 6 if compact else 24)
	# coluna de leitura com largura confortavel no desktop
	_box.custom_minimum_size = Vector2(minf(view.x - 2.0 * margin_x - 20.0, 860.0), 0)
	_box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	ButtonStyles.apply(_back_button, "ui_ghost", Vector2(222, 46 if compact else 52), 18)


func _on_back_pressed() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	GameManager.profile_selected_character = entry_id
	GameManager.open_team_profiles()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()
