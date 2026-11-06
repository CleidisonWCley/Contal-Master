extends Control
## Tela "Conquistas" (UI/UX v4.2): painel de progresso com meta de rank + filtros + grade de cartoes.
## - Cartoes bloqueados mostram o titulo (apagado) e o icone em silhueta; so as secretas mostram "???".
## - Selo "NOVA" e animacao de rank SO para o que foi desbloqueado desde a ultima visita.
## - Cartoes recebem foco (teclado/controle) e a lista rola junto com o foco.
## Sem emojis: icones de UiIcons. Cores sempre de UiPalette.

const BACKGROUND_PATH := Paths.BG_MENU_MAIN
const UNLOCKED_ICON_PATH := Paths.ICON_TROPHY
const INSIGNIA_PATHS := {
	"Bronze": Paths.INSIGNIA_BRONZE,
	"Prata": Paths.INSIGNIA_SILVER,
	"Ouro": Paths.INSIGNIA_GOLD,
	"Platina": Paths.INSIGNIA_PLATINUM
}
const LOCKED_TINT := Color("#D8CCEE")          # lilas bem claro: cadeado legivel sobre o cartao escuro
const SILHOUETTE_TINT := Color(0.46, 0.41, 0.60, 0.92)   # icone da conquista bloqueada (apagado)
const MARKER_ICON := 22.0
const MARKER_TICK := 6.0

const FILTER_ALL := "all"
const FILTER_UNLOCKED := "unlocked"
const FILTER_LOCKED := "locked"
const FILTERS := [
	{"id": FILTER_ALL, "label": "Todas"},
	{"id": FILTER_UNLOCKED, "label": "Desbloqueadas"},
	{"id": FILTER_LOCKED, "label": "Bloqueadas"}
]

var safe_area: MarginContainer
var scroll: ScrollContainer
var grid: GridContainer
var progress_label: Label
var progress_bar: ProgressBar
var insignia_texture_rect: TextureRect
var insignia_name_label: Label
var goal_label: Label
var completion_label: Label
var back_button: Button

var _title_label: Label
var _track: Control
var _markers: Array[Dictionary] = []     # {"count", "holder", "icon"}
var _filter_box: FlowContainer
var _filter_buttons: Dictionary = {}     # id -> Button
var _empty_label: Label
var _filter: String = FILTER_ALL
var _progress_tween: Tween
var _intro_done: bool = false
var _shown_insignia: String = ""
var unlocked_texture: Texture2D
var insignia_textures: Dictionary = {}
var achievement_icon_textures: Dictionary = {}

func _ready() -> void:
	unlocked_texture = load(UNLOCKED_ICON_PATH) as Texture2D
	_load_insignia_textures()
	_load_achievement_icon_textures()
	UiBackdrop.attach(self)
	_build_ui()
	_connect_achievement_signal()
	_refresh_view()
	if has_node("/root/AudioManager"):
		AudioManager.play_music("menu")
	(_filter_buttons[_filter] as Button).call_deferred("grab_focus")

## Ao sair da tela, tudo que estava desbloqueado passa a contar como "visto":
## na proxima visita nao ha selo NOVA nem animacao de rank, a menos que algo novo tenha sido conquistado.
func _exit_tree() -> void:
	if has_node("/root/AchievementManager"):
		AchievementManager.mark_all_seen()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_responsive_layout()

# ---------------------------------------------------------------- construcao
func _build_ui() -> void:
	safe_area = MarginContainer.new()
	safe_area.name = "SafeArea"
	safe_area.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(safe_area)

	var main_box := VBoxContainer.new()
	main_box.name = "MainBox"
	main_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_box.add_theme_constant_override("separation", 10)
	safe_area.add_child(main_box)

	# ---- cabecalho: degrade escuro sutil (UiScrim) atras do titulo, da insignia e da barra.
	var header_panel := PanelContainer.new()
	header_panel.name = "HeaderPanel"
	header_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	main_box.add_child(header_panel)

	var scrim := UiScrim.new()
	scrim.name = "Scrim"
	scrim.top_color = UiPalette.with_alpha(UiPalette.BG, 0.80)
	scrim.bottom_color = UiPalette.with_alpha(UiPalette.BG, 0.52)
	scrim.border_color = UiPalette.with_alpha(UiPalette.ACCENT_ACHIEVEMENTS, 0.45)
	scrim.radius = 20.0
	header_panel.add_child(scrim)

	var header_margin := UiKit.margin(24, 24, 6, 12)
	header_panel.add_child(header_margin)

	var header_box := VBoxContainer.new()
	header_box.add_theme_constant_override("separation", 4)
	header_margin.add_child(header_box)

	var title_row: HBoxContainer = UiKit.screen_title("CONQUISTAS", 32, "medal", UiPalette.ACCENT_ACHIEVEMENTS)
	_title_label = title_row.get_node("TitleLabel") as Label
	header_box.add_child(title_row)

	# insignia atual + meta do proximo rank ("Faltam 3 para Prata")
	var rank_row := HBoxContainer.new()
	rank_row.alignment = BoxContainer.ALIGNMENT_CENTER
	rank_row.add_theme_constant_override("separation", 14)
	header_box.add_child(rank_row)

	insignia_texture_rect = TextureRect.new()
	insignia_texture_rect.name = "ProgressInsignia"
	insignia_texture_rect.custom_minimum_size = Vector2(56, 56)
	insignia_texture_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	insignia_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	insignia_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rank_row.add_child(insignia_texture_rect)

	var rank_texts := VBoxContainer.new()
	rank_texts.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	rank_texts.add_theme_constant_override("separation", 0)
	rank_row.add_child(rank_texts)

	insignia_name_label = UiKit.label("", 19, UiPalette.TEXT_ON_DARK)
	insignia_name_label.name = "InsigniaName"
	rank_texts.add_child(insignia_name_label)

	goal_label = UiKit.label("", 15, UiPalette.TEXT_MUTED)
	goal_label.name = "GoalLabel"
	rank_texts.add_child(goal_label)

	completion_label = UiKit.label("", 16, UiPalette.TEXT_ON_DARK, HORIZONTAL_ALIGNMENT_CENTER)
	completion_label.name = "CompletionLabel"
	completion_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	completion_label.visible = false
	header_box.add_child(completion_label)

	progress_label = UiKit.label("Progresso: 0/15", 16, UiPalette.TEXT_ON_DARK, HORIZONTAL_ALIGNMENT_CENTER)
	progress_label.name = "ProgressLabel"
	header_box.add_child(progress_label)

	var track_holder := CenterContainer.new()
	header_box.add_child(track_holder)
	track_holder.add_child(_build_rank_track())

	# ---- filtros
	_filter_box = HFlowContainer.new()
	_filter_box.name = "Filters"
	_filter_box.alignment = FlowContainer.ALIGNMENT_CENTER
	_filter_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_filter_box.add_theme_constant_override("h_separation", 10)
	_filter_box.add_theme_constant_override("v_separation", 8)
	main_box.add_child(_filter_box)
	for entry in FILTERS:
		var filter_id: String = str((entry as Dictionary)["id"])
		var filter_button := Button.new()
		filter_button.name = "Filter_%s" % filter_id
		filter_button.pressed.connect(_on_filter_pressed.bind(filter_id))
		_filter_box.add_child(filter_button)
		_filter_buttons[filter_id] = filter_button

	# ---- grade rolavel (follow_focus: a lista acompanha o cartao focado por teclado/controle)
	scroll = ScrollContainer.new()
	scroll.name = "AchievementsScroll"
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	main_box.add_child(scroll)
	_style_scrollbar(scroll)

	# folga interna para o contorno/foco dos cartoes nao ser cortado pelo scroll
	var grid_pad := UiKit.margin(4, 8, 4, 4)
	grid_pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(grid_pad)

	var grid_box := VBoxContainer.new()
	grid_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_box.add_theme_constant_override("separation", 12)
	grid_pad.add_child(grid_box)

	grid = GridContainer.new()
	grid.name = "AchievementsGrid"
	grid.columns = 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	grid_box.add_child(grid)

	_empty_label = UiKit.label("", 17, UiPalette.TEXT_MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	_empty_label.name = "EmptyLabel"
	_empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_empty_label.visible = false
	grid_box.add_child(_empty_label)

	var back_holder := CenterContainer.new()
	back_holder.name = "BackButtonWrap"
	main_box.add_child(back_holder)
	back_button = UiKit.back_button()
	back_button.pressed.connect(_on_back_pressed)
	back_holder.add_child(back_button)

	_apply_responsive_layout()

## Barra de progresso com os pontos de rank (Prata / Ouro / Platina) marcados por mini insignias.
func _build_rank_track() -> Control:
	_track = Control.new()
	_track.name = "RankTrack"
	_track.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_track.custom_minimum_size = Vector2(490, MARKER_ICON + MARKER_TICK + 14.0)

	progress_bar = ProgressBar.new()
	progress_bar.name = "ProgressBar"
	progress_bar.min_value = 0.0
	progress_bar.max_value = 15.0
	progress_bar.value = 0.0
	progress_bar.show_percentage = false
	progress_bar.custom_minimum_size = Vector2(0, 14)
	progress_bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	progress_bar.grow_vertical = Control.GROW_DIRECTION_BEGIN
	progress_bar.offset_left = 0.0
	progress_bar.offset_right = 0.0
	progress_bar.offset_top = -14.0
	progress_bar.offset_bottom = 0.0
	_track.add_child(progress_bar)

	_markers.clear()
	for item in AchievementManager.get_rank_thresholds():
		var data: Dictionary = item as Dictionary
		var holder := Control.new()
		holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.custom_minimum_size = Vector2(MARKER_ICON, MARKER_ICON + MARKER_TICK)
		var icon := TextureRect.new()
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.texture = insignia_textures.get(str(data["name"]), null) as Texture2D
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.position = Vector2.ZERO
		icon.size = Vector2(MARKER_ICON, MARKER_ICON)
		holder.add_child(icon)
		var tick := Panel.new()
		tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var tick_style := StyleBoxFlat.new()
		tick_style.bg_color = UiPalette.with_alpha(UiPalette.TEXT_ON_DARK, 0.85)
		tick.add_theme_stylebox_override("panel", tick_style)
		tick.position = Vector2(MARKER_ICON * 0.5 - 1.0, MARKER_ICON)
		tick.size = Vector2(2.0, MARKER_TICK)
		holder.add_child(tick)
		_track.add_child(holder)
		_markers.append({"count": int(data["count"]), "holder": holder, "icon": icon, "tick": tick})
	_track.resized.connect(_layout_markers)
	return _track

## Posiciona cada mini insignia na fracao certa da barra (count / total).
func _layout_markers() -> void:
	if _track == null or progress_bar == null:
		return
	var width: float = _track.size.x
	var total: float = maxf(progress_bar.max_value, 1.0)
	for marker in _markers:
		var fraction: float = clampf(float(marker["count"]) / total, 0.0, 1.0)
		var x: float = width * fraction
		var left: float = clampf(x - MARKER_ICON * 0.5, 0.0, maxf(width - MARKER_ICON, 0.0))
		var holder: Control = marker["holder"] as Control
		holder.position = Vector2(left, 0.0)
		holder.size = Vector2(MARKER_ICON, MARKER_ICON + MARKER_TICK)
		# o tracinho aponta para o ponto exato da barra, mesmo quando a insignia e deslocada nas pontas
		(marker["tick"] as Control).position = Vector2(clampf(x - left - 1.0, 0.0, MARKER_ICON - 2.0), MARKER_ICON)

## Barra de rolagem fina, em lilas translucido (combina com o restante do menu).
func _style_scrollbar(target: ScrollContainer) -> void:
	var bar: VScrollBar = target.get_v_scroll_bar()
	var track := StyleBoxFlat.new()
	track.bg_color = UiPalette.with_alpha(UiPalette.BG, 0.0)
	track.content_margin_left = 5   # sem margem o StyleBoxFlat tem largura 0 e a barra some
	track.content_margin_right = 5
	var grabber := StyleBoxFlat.new()
	grabber.bg_color = UiPalette.with_alpha(UiPalette.TEXT_MUTED, 0.55)
	grabber.set_corner_radius_all(4)
	var grabber_hover := StyleBoxFlat.new()
	grabber_hover.bg_color = UiPalette.with_alpha(UiPalette.TEXT_ON_DARK, 0.85)
	grabber_hover.set_corner_radius_all(4)
	bar.add_theme_stylebox_override("scroll", track)
	bar.add_theme_stylebox_override("grabber", grabber)
	bar.add_theme_stylebox_override("grabber_highlight", grabber_hover)
	bar.add_theme_stylebox_override("grabber_pressed", grabber_hover)

# ---------------------------------------------------------------- dados
func _refresh_view() -> void:
	if not has_node("/root/AchievementManager"):
		return
	var unlocked_count: int = AchievementManager.get_unlocked_count()
	var total_count: int = AchievementManager.get_total_count()
	var insignia_name: String = AchievementManager.get_insignia_name()
	progress_bar.max_value = float(maxi(total_count, 1))
	progress_bar.add_theme_stylebox_override("background", _bar_style(UiPalette.with_alpha(UiPalette.BG, 0.95), UiPalette.with_alpha(Color.WHITE, 0.14), 1))
	completion_label.text = "Parabéns, todas as conquistas foram desbloqueadas!"
	completion_label.visible = false
	if _progress_tween != null and _progress_tween.is_valid():
		_progress_tween.kill()

	# A animacao de rank so roda quando ha conquistas NOVAS (desbloqueadas depois da ultima visita)
	# e parte do que o jogador ja tinha visto, nunca de zero. Sem novidade: mostra o estado atual direto.
	var seen_count: int = mini(AchievementManager.get_seen_count(), unlocked_count)
	if not _intro_done and unlocked_count > seen_count and _animations_enabled():
		_intro_done = true
		_play_progress_animation(seen_count, unlocked_count, total_count)
	else:
		_intro_done = true
		_show_progress_state(float(unlocked_count), total_count, insignia_name, false)
		completion_label.visible = unlocked_count >= total_count and total_count > 0

	_refresh_filter_buttons()
	_populate_grid()
	_layout_markers()

func _populate_grid() -> void:
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()
	var shown: int = 0
	for item in AchievementManager.get_all_achievements():
		if not item is Dictionary:
			continue
		var achievement: Dictionary = item as Dictionary
		var unlocked: bool = AchievementManager.is_unlocked(str(achievement.get("id", "")))
		if _filter == FILTER_UNLOCKED and not unlocked:
			continue
		if _filter == FILTER_LOCKED and unlocked:
			continue
		grid.add_child(_make_achievement_card(achievement))
		shown += 1
	_empty_label.visible = shown == 0
	if shown == 0:
		_empty_label.text = "Nenhuma conquista bloqueada: você completou tudo!" if _filter == FILTER_LOCKED else "Nenhuma conquista desbloqueada ainda. Jogue para ganhar a primeira!"
	_apply_responsive_layout()

func _make_achievement_card(achievement: Dictionary) -> PanelContainer:
	var id: String = str(achievement.get("id", ""))
	var unlocked: bool = AchievementManager.is_unlocked(id)
	var secret: bool = AchievementManager.is_secret(id) and not unlocked
	var is_new: bool = AchievementManager.is_new(id)

	var card := PanelContainer.new()
	card.name = "Achievement_%s" % (id if id != "" else "item")
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size = Vector2(300, 120)
	# Foco por teclado/controle/clique. PASS: o arrastar do dedo ainda rola a lista no celular.
	card.focus_mode = Control.FOCUS_ALL
	card.mouse_filter = Control.MOUSE_FILTER_PASS
	card.tooltip_text = "Conquista secreta" if secret else str(achievement.get("description", ""))

	var normal_style: StyleBoxFlat
	if unlocked:
		normal_style = UiKit.panel_style(UiPalette.CARD_RAISED, UiPalette.ACCENT_ACHIEVEMENTS, 17, 2, 8)
	else:
		normal_style = UiKit.panel_style(UiPalette.with_alpha(UiPalette.CARD.darkened(0.12), 0.96), UiPalette.with_alpha(UiPalette.HIGHLIGHT, 0.28), 17, 1, 0)
	var focus_style: StyleBoxFlat = normal_style.duplicate() as StyleBoxFlat
	focus_style.border_color = UiPalette.TEXT_ON_DARK
	focus_style.set_border_width_all(3)
	card.add_theme_stylebox_override("panel", normal_style)
	card.focus_entered.connect(_set_card_style.bind(card, focus_style))
	card.focus_exited.connect(_set_card_style.bind(card, normal_style))

	var margin := UiKit.margin(16, 14, 12, 12)
	card.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	margin.add_child(row)

	row.add_child(_make_icon_holder(achievement, unlocked, secret))

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	text_box.add_theme_constant_override("separation", 4)
	row.add_child(text_box)

	# titulo (+ selo NOVA)
	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 8)
	text_box.add_child(title_row)
	var title_text: String = "???" if secret else str(achievement.get("title", "Conquista"))
	var title: Label = UiKit.label(title_text, 19, UiPalette.TEXT_ON_DARK if unlocked else UiPalette.TEXT_MUTED)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_row.add_child(title)
	if is_new:
		title_row.add_child(_make_new_badge())

	var description_text: String = "Conquista secreta. Continue jogando para descobrir." if secret else str(achievement.get("description", ""))
	var description: Label = UiKit.label(description_text, 15, UiPalette.TEXT_MUTED)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_box.add_child(description)

	# rodape: data (desbloqueada) | barra de andamento (se houver) | "Bloqueada"
	if unlocked:
		var date_text: String = _format_unlocked_date(AchievementManager.get_unlocked_at(id))
		var state_text: String = "Desbloqueada em %s" % date_text if date_text != "" else "Desbloqueada"
		text_box.add_child(UiKit.label(state_text, 13, UiPalette.ACCENT_ACHIEVEMENTS))
	else:
		var progress: Dictionary = {} if secret else AchievementManager.get_progress(id)
		if progress.is_empty():
			text_box.add_child(UiKit.label("Bloqueada", 13, UiPalette.TEXT_MUTED))
		else:
			text_box.add_child(_make_mini_progress(progress))
	return card

func _set_card_style(card: PanelContainer, style: StyleBoxFlat) -> void:
	if is_instance_valid(card):
		card.add_theme_stylebox_override("panel", style)

## Icone da conquista. Desbloqueada: colorido. Bloqueada: silhueta apagada + cadeadinho no canto.
## Secreta: so o cadeado (nao entrega qual e a conquista).
func _make_icon_holder(achievement: Dictionary, unlocked: bool, secret: bool) -> Control:
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(54, 54)
	holder.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var icon_rect := TextureRect.new()
	icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_rect.position = Vector2(0, 0)
	icon_rect.size = Vector2(46, 46)
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var achievement_texture: Texture2D = _get_achievement_icon_texture(achievement)
	if unlocked:
		icon_rect.texture = achievement_texture if achievement_texture != null else unlocked_texture
	elif secret or achievement_texture == null:
		icon_rect.texture = UiIcons.texture("lock")
		icon_rect.modulate = LOCKED_TINT
	else:
		icon_rect.texture = achievement_texture
		icon_rect.modulate = SILHOUETTE_TINT
	holder.add_child(icon_rect)

	if not unlocked and not secret and achievement_texture != null:
		var backing := Panel.new()
		backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var backing_style := StyleBoxFlat.new()
		backing_style.bg_color = UiPalette.with_alpha(UiPalette.BG, 0.94)
		backing_style.set_corner_radius_all(11)
		backing.add_theme_stylebox_override("panel", backing_style)
		backing.position = Vector2(30, 30)
		backing.size = Vector2(22, 22)
		holder.add_child(backing)
		var lock_icon: TextureRect = UiIcons.make_rect("lock", 14, LOCKED_TINT)
		lock_icon.position = Vector2(34, 34)
		lock_icon.size = Vector2(14, 14)
		holder.add_child(lock_icon)
	return holder

func _make_new_badge() -> PanelContainer:
	var badge := PanelContainer.new()
	badge.name = "NewBadge"
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var style: StyleBoxFlat = UiKit.panel_style(UiPalette.ACCENT_ACHIEVEMENTS, UiPalette.ACCENT_ACHIEVEMENTS, 10, 0, 0)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 1
	style.content_margin_bottom = 1
	badge.add_theme_stylebox_override("panel", style)
	var label: Label = UiKit.label("NOVA", 12, UiPalette.TEXT_ON_BRIGHT, HORIZONTAL_ALIGNMENT_CENTER)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.add_child(label)
	return badge

## Mini barra de andamento do cartao ("3/21", "1.200 / 4.350 pts").
func _make_mini_progress(progress: Dictionary) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.min_value = 0.0
	bar.max_value = float(maxi(int(progress.get("target", 1)), 1))
	bar.value = float(int(progress.get("current", 0)))
	bar.custom_minimum_size = Vector2(0, 8)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_theme_stylebox_override("background", _bar_style(UiPalette.with_alpha(UiPalette.BG, 0.9), UiPalette.with_alpha(Color.WHITE, 0.12), 1))
	bar.add_theme_stylebox_override("fill", _bar_style(UiPalette.HIGHLIGHT, Color(0, 0, 0, 0), 0))
	row.add_child(bar)
	var label: Label = UiKit.label(str(progress.get("text", "")), 13, UiPalette.TEXT_MUTED, HORIZONTAL_ALIGNMENT_RIGHT)
	row.add_child(label)
	return row

## "2026-11-05 14:30:00" -> "05/11" (com o ano quando nao e o ano atual: "05/11/2025").
func _format_unlocked_date(raw: String) -> String:
	var date_part: String = raw.replace("T", " ").split(" ")[0]
	var pieces: PackedStringArray = date_part.split("-")
	if pieces.size() != 3:
		return ""
	var text: String = "%s/%s" % [pieces[2], pieces[1]]
	if pieces[0] != str(Time.get_date_dict_from_system().get("year", "")):
		text += "/%s" % pieces[0]
	return text

# ---------------------------------------------------------------- filtros
func _refresh_filter_buttons() -> void:
	var total: int = AchievementManager.get_total_count()
	var unlocked: int = AchievementManager.get_unlocked_count()
	var counts: Dictionary = {FILTER_ALL: total, FILTER_UNLOCKED: unlocked, FILTER_LOCKED: total - unlocked}
	var compact: bool = _is_compact()
	for entry in FILTERS:
		var filter_id: String = str((entry as Dictionary)["id"])
		var button: Button = _filter_buttons[filter_id] as Button
		button.text = "%s (%d)" % [str((entry as Dictionary)["label"]), int(counts[filter_id])]
		ButtonStyles.apply(button, "ui_toggle_on" if filter_id == _filter else "ui_ghost", Vector2(0, 40 if compact else 46), 15 if compact else 17)

func _on_filter_pressed(filter_id: String) -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	if filter_id == _filter:
		return
	_filter = filter_id
	_refresh_filter_buttons()
	_populate_grid()
	scroll.scroll_vertical = 0

# ---------------------------------------------------------------- layout
func _is_compact() -> bool:
	var view: Vector2 = ScreenTools.get_viewport_size(self)
	return view.x < 900.0 or ScreenTools.is_short(self)

func _apply_responsive_layout() -> void:
	if safe_area == null or back_button == null or _track == null:
		return
	var view: Vector2 = ScreenTools.get_viewport_size(self)
	var compact: bool = _is_compact()
	var narrow: bool = view.x < 620.0
	var margin_x: int = 16 if compact else 32
	safe_area.add_theme_constant_override("margin_left", margin_x)
	safe_area.add_theme_constant_override("margin_right", margin_x)
	safe_area.add_theme_constant_override("margin_top", 12 if compact else 20)
	safe_area.add_theme_constant_override("margin_bottom", 14 if compact else 28)
	ScreenTools.apply_label_font(_title_label, self, 32, 26)
	insignia_texture_rect.custom_minimum_size = Vector2(48, 48) if compact else Vector2(56, 56)
	var bar_width: float = minf(360.0, view.x - 90.0) if compact else 520.0
	var bar_height: float = 12.0 if compact else 14.0
	progress_bar.custom_minimum_size = Vector2(0, bar_height)
	progress_bar.offset_top = -bar_height
	_track.custom_minimum_size = Vector2(bar_width, MARKER_ICON + MARKER_TICK + bar_height)
	if grid != null:
		grid.columns = 1 if narrow else (2 if view.x < 900.0 else 3)
		var h_gap: float = 10.0 if compact else 14.0
		grid.add_theme_constant_override("h_separation", int(h_gap))
		grid.add_theme_constant_override("v_separation", int(h_gap))
		var available: float = maxf(240.0, view.x - 2.0 * margin_x - 24.0)
		var card_width: float = floor((available - h_gap * float(grid.columns - 1)) / float(grid.columns))
		for child in grid.get_children():
			if child is Control:
				(child as Control).custom_minimum_size = Vector2(card_width, 112 if compact else 120)
	if not _filter_buttons.is_empty() and has_node("/root/AchievementManager"):
		_refresh_filter_buttons()
	ButtonStyles.apply(back_button, "ui_ghost", Vector2(222, 46 if compact else 52), 18)

# ---------------------------------------------------------------- acoes
func _connect_achievement_signal() -> void:
	if has_node("/root/AchievementManager"):
		var callable := Callable(self, "_refresh_view")
		if not AchievementManager.achievements_changed.is_connected(callable):
			AchievementManager.achievements_changed.connect(callable)

func _on_back_pressed() -> void:
	if has_node("/root/AudioManager"):
		AudioManager.play_click()
	GameManager.go_to_main_menu()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()

# ---------------------------------------------------------------- animacao de progresso
## Barra e contador sobem de `from_count` (o que o jogador ja tinha visto) ate `target`;
## so toca o "pop" da insignia nas trocas de rank que acontecem NESSE trecho (ex.: Bronze -> Prata).
func _play_progress_animation(from_count: int, target: int, total: int) -> void:
	_shown_insignia = ""
	_show_progress_state(float(from_count), total, AchievementManager.get_insignia_name_for_count(from_count), false)
	var duration: float = clampf(0.45 * float(target - from_count), 0.8, 2.2)
	_progress_tween = create_tween()
	_progress_tween.set_trans(Tween.TRANS_CUBIC)
	_progress_tween.set_ease(Tween.EASE_OUT)
	_progress_tween.tween_method(_on_progress_step.bind(total), float(from_count), float(target), duration)
	_progress_tween.tween_callback(_on_progress_finished.bind(target, total))

func _on_progress_step(value: float, total: int) -> void:
	var count: int = int(floor(value + 0.001))
	_show_progress_state(value, total, AchievementManager.get_insignia_name_for_count(count), true)

func _on_progress_finished(target: int, total: int) -> void:
	_show_progress_state(float(target), total, AchievementManager.get_insignia_name_for_count(target), true)
	completion_label.visible = target >= total and total > 0

## Atualiza barra, contador, meta, marcadores, nome e insignia. Se `animate_rank` e o rank mudou, toca o "pop".
func _show_progress_state(value: float, total: int, insignia_name: String, animate_rank: bool) -> void:
	var count: int = int(floor(value + 0.001))
	progress_bar.value = value
	progress_label.text = "Progresso: %d/%d" % [count, total]
	goal_label.text = _goal_text(count)
	progress_bar.add_theme_stylebox_override("fill", _bar_style(_get_insignia_fill_color(insignia_name), Color(0, 0, 0, 0), 0))
	_update_markers(count)
	var changed: bool = insignia_name != _shown_insignia
	if changed:
		var had_rank: bool = _shown_insignia != ""
		_shown_insignia = insignia_name
		insignia_name_label.text = insignia_name
		insignia_name_label.add_theme_color_override("font_color", _get_insignia_text_color(insignia_name))
		_apply_insignia_texture(insignia_name)
		if animate_rank and had_rank:
			_play_rank_change_effect()

## "Faltam 3 para Prata" / "Falta 1 para Bronze" / "Rank máximo alcançado!"
func _goal_text(count: int) -> String:
	var next_rank: Dictionary = AchievementManager.get_next_rank(count)
	if next_rank.is_empty():
		return "Rank máximo alcançado!"
	var remaining: int = int(next_rank.get("remaining", 0))
	return "%s %d para %s" % ["Falta" if remaining == 1 else "Faltam", remaining, str(next_rank.get("name", ""))]

## Marcadores ja alcancados ficam em cor cheia; os demais, apagados.
func _update_markers(count: int) -> void:
	for marker in _markers:
		var reached: bool = count >= int(marker["count"])
		(marker["holder"] as Control).modulate = Color.WHITE if reached else Color(1, 1, 1, 0.42)

func _play_rank_change_effect() -> void:
	insignia_texture_rect.pivot_offset = insignia_texture_rect.size * 0.5
	var pop: Tween = create_tween()
	pop.set_parallel(true)
	pop.tween_property(insignia_texture_rect, "scale", Vector2.ONE * 1.35, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop.tween_property(insignia_texture_rect, "modulate", Color(1.6, 1.6, 1.6, 1.0), 0.14)
	pop.chain().set_parallel(true)
	pop.tween_property(insignia_texture_rect, "scale", Vector2.ONE, 0.26).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
	pop.tween_property(insignia_texture_rect, "modulate", Color.WHITE, 0.30)
	insignia_name_label.modulate.a = 0.0
	create_tween().tween_property(insignia_name_label, "modulate:a", 1.0, 0.30)

func _animations_enabled() -> bool:
	return not has_node("/root/SettingsManager") or SettingsManager.animations_enabled()

# ---------------------------------------------------------------- recursos
func _load_insignia_textures() -> void:
	insignia_textures.clear()
	for key in INSIGNIA_PATHS.keys():
		var loaded_texture: Resource = load(str(INSIGNIA_PATHS[key]))
		if loaded_texture is Texture2D:
			insignia_textures[str(key)] = loaded_texture as Texture2D

func _load_achievement_icon_textures() -> void:
	achievement_icon_textures.clear()
	if not has_node("/root/AchievementManager"):
		return
	for item in AchievementManager.get_all_achievements():
		if not item is Dictionary:
			continue
		var achievement: Dictionary = item as Dictionary
		var achievement_id: String = str(achievement.get("id", ""))
		var icon_path: String = str(achievement.get("icon_path", ""))
		if achievement_id == "" or icon_path == "":
			continue
		var loaded_icon: Resource = load(icon_path)
		if loaded_icon is Texture2D:
			achievement_icon_textures[achievement_id] = loaded_icon as Texture2D

func _get_achievement_icon_texture(achievement: Dictionary) -> Texture2D:
	var texture_value: Variant = achievement_icon_textures.get(str(achievement.get("id", "")), null)
	if texture_value is Texture2D:
		return texture_value as Texture2D
	return null

func _apply_insignia_texture(insignia_name: String) -> void:
	if insignia_name == "Sem insígnia":
		insignia_texture_rect.texture = UiIcons.texture("lock")
		insignia_texture_rect.modulate = Color(LOCKED_TINT.r, LOCKED_TINT.g, LOCKED_TINT.b, 0.75)
		return
	var texture_value: Variant = insignia_textures.get(insignia_name, null)
	insignia_texture_rect.texture = texture_value as Texture2D if texture_value is Texture2D else null
	insignia_texture_rect.modulate = Color.WHITE

func _get_insignia_fill_color(insignia_name: String) -> Color:
	match insignia_name:
		"Bronze":
			return Color(0.86, 0.43, 0.14, 1.0)
		"Prata":
			return Color(0.78, 0.88, 0.96, 1.0)
		"Ouro":
			return Color(1.0, 0.78, 0.10, 1.0)
		"Platina":
			return Color(0.92, 0.96, 1.0, 1.0)
		_:
			return UiPalette.with_alpha(UiPalette.TEXT_MUTED, 0.55)

func _get_insignia_text_color(insignia_name: String) -> Color:
	match insignia_name:
		"Bronze":
			return Color(1.0, 0.66, 0.32, 1.0)
		"Prata":
			return Color(0.86, 0.95, 1.0, 1.0)
		"Ouro":
			return Color(1.0, 0.88, 0.24, 1.0)
		"Platina":
			return Color(0.96, 0.98, 1.0, 1.0)
		_:
			return UiPalette.TEXT_MUTED

func _bar_style(bg_color: Color, border_color: Color, border_width: int) -> StyleBoxFlat:
	var style := UiKit.panel_style(bg_color, border_color, 9, border_width, 0)
	style.content_margin_left = 0
	style.content_margin_right = 0
	style.content_margin_top = 0
	style.content_margin_bottom = 0
	return style
