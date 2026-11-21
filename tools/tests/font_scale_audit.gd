extends Node
## V0.16.3 - Auditoria automatica do tamanho de fonte (acessibilidade).
## Abre cada tela em cada nivel (Pequena/Media/Grande/Extra grande), tira print e procura:
##   - texto cortado/estourando o proprio controle (Label, Button, RichTextLabel, LineEdit);
##   - controle com texto fora da area visivel da tela.
## Uso (precisa de display; em servidor use xvfb):
##   xvfb-run -a godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tools/tests/font_scale_audit.tscn -- out=/tmp/shots only=Settings levels=pequena,media
## Argumentos: out=PASTA  only=trecho_do_nome  levels=a,b,c  wait=frames

const LEVELS_ALL: Array[String] = ["pequena", "media", "grande", "extra_grande"]

var _out_dir: String = "/tmp/font_shots"
var _only: String = ""
var _levels: Array[String] = LEVELS_ALL
var _wait_frames: int = 14
var _report: Array[String] = []
var _pause_settings: bool = false
var _debug_geo: bool = false
var _drive_only: bool = false
var _drive_frames: int = 90
var _tutorial_on: bool = false
var _desvio_feedback: bool = false

func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("out="):
			_out_dir = arg.substr(4)
		elif arg.begins_with("only="):
			_only = arg.substr(5)
		elif arg.begins_with("levels="):
			_levels = []
			for l in arg.substr(7).split(","):
				_levels.append(l)
		elif arg.begins_with("drive="):
			_drive_only = true
			_drive_frames = int(arg.substr(6))
		elif arg == "feedback":
			_desvio_feedback = true
		elif arg == "tutorial":
			_tutorial_on = true
		elif arg == "pause":
			_pause_settings = true
		elif arg.begins_with("wait="):
			_wait_frames = int(arg.substr(5))
	DirAccess.make_dir_recursive_absolute(_out_dir)
	_run.call_deferred()

func _targets() -> Array:
	# [nome, caminho, preparo]  preparo = Callable opcional chamado ANTES de instanciar
	return [
		["MainMenu", Paths.SCENE_MAIN_MENU, ""],
		["ModeSelect", Paths.SCENE_MODE_SELECT, ""],
		["MenuMinigames", Paths.SCENE_FREE_MENU, "free"],
		["Settings", Paths.SCENE_SETTINGS, ""],
		["QuestionSettings", Paths.SCENE_QUESTION_SETTINGS, ""],
		["ScoreMenu", Paths.SCENE_SCORE, ""],
		["AchievementsMenu", Paths.SCENE_ACHIEVEMENTS, ""],
		["TeamArchive", Paths.SCENE_TEAM_ARCHIVE, ""],
		["TeamProfiles", Paths.SCENE_TEAM_PROFILES, ""],
		["FirmaArchive", Paths.SCENE_FIRMA_ARCHIVE, ""],
		["ShowDoBilhao", Paths.SCENE_SHOW_DO_BILHAO, "free:show_do_bilhao"],
		["BatalhaNaval", Paths.SCENE_BATALHA_NAVAL, "free:batalha_naval"],
		["MaletaCerta", Paths.SCENE_MALETA_CERTA, "free:maleta_certa"],
		["RoletaRisco", Paths.SCENE_ROLETA_RISCO, "free:roleta_risco"],
		["Perseguicao", Paths.SCENE_PERSEGUICAO, "free:perseguicao"],
		["ForcaTecnica", Paths.SCENE_FORCA_TECNICA, "free:forca_tecnica"],
		["Stop", Paths.SCENE_STOP, "free:stop"],
		["DesvioLogico", Paths.SCENE_DESVIO_LOGICO, "free:desvio_logico"],
		["CutsceneIntro", Paths.SCENE_CUTSCENE_INTRO, "campaign"],
		["StageTransition", Paths.SCENE_STAGE_TRANSITION, "campaign:show_do_bilhao"],
		["CutsceneFinal", Paths.SCENE_CUTSCENE_FINAL, "campaign:final"],
		["StageDebrief", Paths.SCENE_STAGE_DEBRIEF, "campaign:show_do_bilhao"],
	]

func _prepare(mode: String) -> void:
	GameManager.current_mode = GameManager.GameMode.NONE
	if mode == "":
		return
	var parts: PackedStringArray = mode.split(":")
	GameManager.current_mode = GameManager.GameMode.FREE if parts[0] == "free" else GameManager.GameMode.CAMPAIGN
	if parts.size() > 1:
		GameManager.current_phase_key = parts[1]
		for i in range(GameManager.PHASES.size()):
			if str(GameManager.PHASES[i].get("key", "")) == parts[1]:
				GameManager.campaign_index = i

func _run() -> void:
	SettingsManager.set_setting("animations_enabled", _drive_only)
	SettingsManager.set_setting("tutorials_enabled", _tutorial_on)
	for target in _targets():
		var tname: String = target[0]
		if _only != "" and not tname.contains(_only):
			continue
		for level in _levels:
			await _audit_scene(tname, str(target[1]), str(target[2]), level)
	SettingsManager.set_font_level("media")
	SettingsManager.set_setting("animations_enabled", true)
	SettingsManager.set_setting("tutorials_enabled", true)
	SettingsManager.flush_pending_save()
	var report_path: String = _out_dir.path_join("_report.txt")
	var f := FileAccess.open(report_path, FileAccess.WRITE)
	f.store_string("\n".join(_report))
	f.close()
	print("AUDIT_DONE problemas=%d" % _count_issues())
	get_tree().quit()

func _count_issues() -> int:
	var n: int = 0
	for line in _report:
		if line.begins_with("  !"):
			n += 1
	return n

func _audit_scene(tname: String, path: String, mode: String, level: String) -> void:
	SettingsManager.set_font_level(level)
	await get_tree().process_frame
	_prepare(mode)
	var packed: PackedScene = load(path) as PackedScene
	if packed == null:
		_report.append("[%s/%s] ERRO: cena nao carregou" % [tname, level])
		return
	var scene: Node = packed.instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	for i in range(_wait_frames):
		await get_tree().process_frame
	await _extra_setup(tname, scene)
	for i in range(6):
		await get_tree().process_frame
	var issues: Array[String] = _audit_controls(scene)
	_report.append("[%s/%s] %s" % [tname, level, "OK" if issues.is_empty() else "%d problema(s)" % issues.size()])
	for it in issues:
		_report.append("  ! " + it)
	await RenderingServer.frame_post_draw
	var img: Image = get_tree().root.get_texture().get_image()
	img.save_png(_out_dir.path_join("%s__%s.png" % [tname, level]))
	scene.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame

## Gancho para abrir estados especificos (ex.: pause/configuracoes aberto, feedback visivel).
func _extra_setup(tname: String, scene: Node) -> void:
	# Maleta Certa: respostas LONGAS (2+ linhas em Extra grande), como no print do usuario.
	if tname == "MaletaCerta":
		var texts: Array = ["Aceitar com o aval de um cliente que ja revisa a propria firma", "Aceitar e ser revisada depois da proxima revisao pelos pares", "Recusar: ainda nao pode revisar nenhuma outra firma"]
		var btns: Array = scene.get("option_buttons")
		for i in range(mini(btns.size(), 3)):
			(btns[i] as Button).text = "MALETA %d\n%s" % [i + 1, texts[i]]
		scene.call("_refit_options")
		for i in range(8):
			await get_tree().process_frame
	# Desvio Logico: forca a fase de DECISAO com pergunta/respostas LONGAS (pior caso, igual ao print do usuario).
	if tname == "DesvioLogico" and _drive_only:
		scene.set("state", DLConfig.STATE_DRIVE)
		for i in range(_drive_frames):
			await get_tree().process_frame
		return
	if tname == "DesvioLogico":
		scene.set("state", DLConfig.STATE_DRIVE)
		scene.call("_enter_decision_phase")
		for i in range(4):
			await get_tree().process_frame
		(scene.get("question_label") as Label).text = "A firma Sol não auditou nada no ano anterior à indicação. Qual ano será o ano-base da revisão dela?"
		(scene.get("option_a_button") as Button).text = "ROTA A\nO ano antecedente ao anterior"
		(scene.get("option_b_button") as Button).text = "ROTA B\nO ano da própria indicação"
		scene.call("_schedule_decision_layout")
		for i in range(6):
			await get_tree().process_frame
		if _desvio_feedback:
			# mostra o feedback de "ROTA CORRETA" (pior caso: texto longo) por cima do HUD
			var q: Dictionary = scene.call("_current_question")
			scene.call("_show_feedback", true, str(q.get("resposta", "A")), q)
			for i in range(8):
				await get_tree().process_frame
	if tname == "Perseguicao" and _debug_geo:
		var mb: Control = scene.find_child("MainLayout", true, false)
		var rm: Control = mb.get_parent()
		print("GEO rm pos=%s size=%s min=%s | mb pos=%s size=%s min=%s align=%s | scene pos=%s size=%s" % [rm.position, rm.size, rm.get_combined_minimum_size(), mb.position, mb.size, mb.get_combined_minimum_size(), (mb as BoxContainer).alignment, (scene as Control).position, (scene as Control).size])
	# Pause aberto na tela de configuracoes (seletor "Fonte" dentro do pause).
	if tname == "ShowDoBilhao" and _pause_settings:
		var pause: Node = scene.get("pause_menu")
		if pause != null:
			pause.call("open")
			await get_tree().process_frame
			pause.call("_show_settings", true)
			for i in range(6):
				await get_tree().process_frame

# ---------------------------------------------------------------- verificacoes
func _audit_controls(scene: Node) -> Array[String]:
	var out: Array[String] = []
	var vp: Vector2 = get_tree().root.get_visible_rect().size
	_walk(scene, vp, out)
	return out

func _in_scroll(node: Node) -> bool:
	var p: Node = node.get_parent()
	while p != null:
		if p is ScrollContainer:
			return true
		p = p.get_parent()
	return false

func _walk(node: Node, vp: Vector2, out: Array[String]) -> void:
	if node is CanvasItem and not (node as CanvasItem).is_visible_in_tree():
		return
	if node is Control:
		_check_control(node as Control, vp, out)
	for child in node.get_children():
		_walk(child, vp, out)

func _text_of(c: Control) -> String:
	if c is Label:
		return (c as Label).text
	if c is Button:
		return (c as Button).text
	if c is RichTextLabel:
		return (c as RichTextLabel).get_parsed_text()
	if c is LineEdit:
		return (c as LineEdit).text
	return ""

func _check_control(c: Control, vp: Vector2, out: Array[String]) -> void:
	var text: String = _text_of(c).strip_edges()
	if text == "" or c.modulate.a < 0.05 or c.size.x < 2.0:
		return
	if c.has_meta("_fs_skip"):
		return
	var label_name: String = "%s '%s'" % [c.get_path().get_concatenated_names().right(60), text.left(28).replace("\n", " ")]
	var rect: Rect2 = c.get_global_rect()
	var in_scroll: bool = _in_scroll(c)
	# 1) fora da tela (so fora de rolagem)
	if not in_scroll:
		if rect.end.x > vp.x + 3.0 or rect.end.y > vp.y + 3.0 or rect.position.x < -3.0 or rect.position.y < -3.0:
			if c.get_global_transform().get_scale().is_equal_approx(Vector2.ONE):
				out.append("FORA DA TELA %s rect=%s" % [label_name, rect])
	# 2) texto maior que o controle
	if c is Label:
		var l := c as Label
		var font: Font = l.get_theme_font("font")
		var fs: int = l.get_theme_font_size("font_size")
		if l.autowrap_mode == TextServer.AUTOWRAP_OFF:
			var w: float = font.get_string_size(l.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
			if w > l.size.x + 2.0 and l.text_overrun_behavior == TextServer.OVERRUN_NO_TRIMMING and not l.clip_text:
				out.append("TEXTO MAIS LARGO QUE O CONTROLE %s texto=%dpx controle=%dpx" % [label_name, int(w), int(l.size.x)])
		else:
			var lines: int = l.get_line_count()
			var need: float = float(lines) * (font.get_height(fs) + float(l.get_theme_constant("line_spacing")))
			if need > l.size.y + 3.0 and l.size.y > 0.0:
				out.append("TEXTO CORTADO (altura) %s precisa=%dpx tem=%dpx" % [label_name, int(need), int(l.size.y)])
	elif c is Button:
		var b := c as Button
		var min_size: Vector2 = b.get_minimum_size()
		if min_size.x > b.size.x + 2.0 or min_size.y > b.size.y + 2.0:
			out.append("BOTAO MENOR QUE O CONTEUDO %s min=%s tem=%s" % [label_name, min_size, b.size])
	elif c is RichTextLabel:
		var r := c as RichTextLabel
		if not r.fit_content and r.get_content_height() > r.size.y + 3.0 and not r.scroll_active:
			out.append("TEXTO RICO CORTADO %s precisa=%dpx tem=%dpx" % [label_name, r.get_content_height(), int(r.size.y)])
