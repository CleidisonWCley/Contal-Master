extends Control
## V0.15 - Arquivo da Equipe: os 9 personagens que orbitam a ContalMaster.
## Mostra nivel de confianca (0..3), perfil e trechos de lore JA LIBERADOS; o resto aparece bloqueado com a dica de
## como liberar. Tambem lista os finais secretos (so dados por enquanto). Conteudo: LoreManager + scripts/data/lore/*.json.
## Entrada: botao "Arquivo da Equipe" no Modo Livre (GameManager.open_team_archive()). Voltar -> Modo Livre.

var _main_box: VBoxContainer
var _back_button: Button


func _ready() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_music("menu")
	UiBackdrop.attach(self)
	_build_ui()
	if _back_button != null:
		_back_button.call_deferred("grab_focus")


func _build_ui() -> void:
	var safe: MarginContainer = UiKit.margin(24, 24, 20, 20)
	safe.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(safe)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	safe.add_child(scroll)
	_main_box = VBoxContainer.new()
	_main_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_main_box.add_theme_constant_override("separation", 12)
	scroll.add_child(_main_box)

	_main_box.add_child(UiKit.screen_title("ARQUIVO DA EQUIPE", UiPalette.FONT_TITLE.x))
	var counts: Dictionary = LoreManager.count_items()
	var endings: Array = LoreManager.get_secret_endings()
	var summary: Label = UiKit.label("Perfis e trechos liberados: %d/%d  ·  Finais secretos liberados: %d/%d\nJogue e volte às estações (campanha ou Modo Livre) para conhecer melhor cada pessoa da equipe."
		% [int(counts.get("unlocked", 0)), int(counts.get("total", 0)), LoreManager.get_unlocked_secret_endings().size(), endings.size()],
		16, UiPalette.TEXT_MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_main_box.add_child(summary)

	for character_id in LoreManager.CHARACTER_ORDER:
		_main_box.add_child(_character_card(str(character_id)))
	_main_box.add_child(_endings_card(endings))

	var holder: CenterContainer = CenterContainer.new()
	_main_box.add_child(holder)
	_back_button = UiKit.back_button()
	_back_button.pressed.connect(_on_back_pressed)
	holder.add_child(_back_button)


func _station_of(character_id: String) -> String:
	for key in LoreManager.STATION_ORDER:
		if str(LoreManager.HOST_BY_STATION.get(key, "")) == character_id:
			return str(key)
	return ""


func _character_card(character_id: String) -> Control:
	var card: PanelContainer = PanelContainer.new()
	card.add_theme_stylebox_override("panel", UiKit.card_style(18))
	var pad: MarginContainer = UiKit.margin(16, 16, 14, 14)
	card.add_child(pad)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	pad.add_child(row)

	var level: int = LoreManager.get_character_level(character_id)
	var portrait: TextureRect = TextureRect.new()
	portrait.custom_minimum_size = Vector2(104, 104)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	portrait.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var texture: Texture2D = TutorialManager.sprite_texture(character_id, "v3")
	if texture != null:
		var atlas: AtlasTexture = AtlasTexture.new()
		atlas.atlas = texture
		var size: Vector2 = texture.get_size()
		var side: float = minf(size.x, size.y) * 0.62
		atlas.region = Rect2((size.x - side) * 0.5, 0.0, side, side)
		portrait.texture = atlas
	# Quem ainda nao foi conhecido aparece como silhueta.
	portrait.modulate = Color.WHITE if level >= 1 or LoreManager.has_seen_profile(character_id) else Color(0.0, 0.0, 0.0, 0.85)
	row.add_child(portrait)

	var column: VBoxContainer = VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 6)
	row.add_child(column)

	var profile: Dictionary = LoreManager.get_profile(character_id)
	var shown_name: String = str(LoreManager.CHARACTER_NAMES.get(character_id, character_id.capitalize()))
	var known: bool = LoreManager.is_profile_unlocked(character_id)
	var title: String = "%s  ·  %s" % [shown_name, LoreManager.get_level_name(level)] if known else "%s  ·  ???" % shown_name
	column.add_child(UiKit.label(title, 22, UiPalette.TEXT_ON_DARK))
	var stars: String = "★".repeat(level) + "☆".repeat(3 - level)
	column.add_child(UiKit.label("Confiança %s" % stars, 15, UiPalette.DIFF_NORMAL))

	if known:
		column.add_child(_body("%s\n%s" % [str(profile.get("role", "")), "\n".join(PackedStringArray(profile.get("frames", []) as Array))]))
	else:
		var station: String = _station_of(character_id)
		var hint: String = "Conclua a estação deste personagem para conhecê-lo." if station != "" else "Conclua 3 estações diferentes para conhecer o Jales."
		column.add_child(_body("Ainda não nos conhecemos tão bem. " + hint, true))

	for item in LoreManager.get_fragments():
		var fragment: Dictionary = item as Dictionary
		if str(fragment.get("owner", "")) != character_id:
			continue
		if LoreManager.is_fragment_unlocked(fragment) and LoreManager.has_seen_fragment(str(fragment.get("id", ""))):
			column.add_child(_body("«%s»\n%s" % [str(fragment.get("title", "")), "\n".join(PackedStringArray(fragment.get("frames", []) as Array))]))
		elif LoreManager.is_fragment_unlocked(fragment):
			column.add_child(_body("Trecho novo à espera: jogue o Modo Livre para ouvi-lo.", true))
		else:
			column.add_child(_body("Trecho bloqueado. %s" % str(fragment.get("hint", "")), true))
	return card


func _endings_card(endings: Array) -> Control:
	var card: PanelContainer = PanelContainer.new()
	card.add_theme_stylebox_override("panel", UiKit.card_style(18))
	var pad: MarginContainer = UiKit.margin(16, 16, 14, 14)
	card.add_child(pad)
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	pad.add_child(column)
	column.add_child(UiKit.label("Finais secretos", 22, UiPalette.TEXT_ON_DARK))
	for item in endings:
		var ending: Dictionary = item as Dictionary
		if LoreManager.is_secret_ending_unlocked(str(ending.get("id", ""))):
			column.add_child(_body("%s: liberado (a cena chega em breve).\n%s" % [str(ending.get("title", "")), str(ending.get("summary", ""))]))
		else:
			column.add_child(_body("??? Continue conhecendo a equipe para liberar.", true))
	return card


func _body(text: String, muted: bool = false) -> Label:
	var label: Label = UiKit.label(text, 15, UiPalette.TEXT_MUTED if muted else UiPalette.TEXT_ON_DARK)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label


func _on_back_pressed() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	GameManager.open_free_menu()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()
