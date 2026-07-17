extends Control

const STORY_PATH := "res://data/chapters/chapter_01.json"
const SAVE_PATH := "user://ashen_oath_save.json"
const SAVE_VERSION := 1
const START_NODE_ID := "checkpoint_arrival"

@onready var panel_text: Label = $Margin/Layout/Panel/PanelText
@onready var speaker: Label = $Margin/Layout/Speaker
@onready var narrative: Label = $Margin/Layout/Narrative
@onready var choices: VBoxContainer = $Margin/Layout/Choices
@onready var restart_button: Button = $Margin/Layout/Footer/Restart

var nodes: Dictionary = {}
var state := {"flags": {}, "stats": {}}
var current_node_id := START_NODE_ID

func _ready() -> void:
	restart_button.pressed.connect(restart)
	if not load_story():
		return
	load_progress()
	show_node(current_node_id)

func load_story() -> bool:
	var file := FileAccess.open(STORY_PATH, FileAccess.READ)
	if file == null:
		show_error("The story file could not be opened.")
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary) or not parsed.has("nodes") or not (parsed["nodes"] is Array):
		show_error("The story file is invalid.")
		return false
	for node in parsed.get("nodes", []):
		if not (node is Dictionary) or not node.has("id"):
			show_error("The story contains a node without an ID.")
			return false
		nodes[node["id"]] = node
	if not nodes.has(START_NODE_ID):
		show_error("The opening story node is missing.")
		return false
	return true

func show_node(node_id: String) -> void:
	if not nodes.has(node_id):
		show_error("Story node not found: " + node_id)
		return
	current_node_id = node_id
	var node: Dictionary = nodes[node_id]
	panel_text.text = node.get("panel_description", "Artwork placeholder")
	speaker.text = node.get("speaker", "")
	narrative.text = node.get("text", "")
	for child in choices.get_children():
		child.queue_free()
	for choice in node.get("choices", []):
		if conditions_met(choice.get("requires", {})):
			var button := Button.new()
			button.text = choice["text"]
			button.custom_minimum_size.y = 72
			button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			button.pressed.connect(select_choice.bind(choice))
			choices.add_child(button)
	if node.has("ending"):
		var ending := Label.new()
		ending.text = "ENDING — " + str(node["ending"])
		ending.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		choices.add_child(ending)
	save_progress()

func select_choice(choice: Dictionary) -> void:
	apply_effects(choice.get("effects", {}))
	show_node(choice["next"])

func apply_effects(effects: Dictionary) -> void:
	for key in effects:
		var value = effects[key]
		if value is int or value is float:
			state["stats"][key] = state["stats"].get(key, 0) + value
		else:
			state["flags"][key] = value

func conditions_met(required: Dictionary) -> bool:
	for key in required:
		if state["flags"].get(key, state["stats"].get(key)) != required[key]:
			return false
	return true

func save_progress() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify({"version": SAVE_VERSION, "node": current_node_id, "state": state}))

func load_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var saved = JSON.parse_string(file.get_as_text())
	if saved is Dictionary and saved.get("version", 0) == SAVE_VERSION and nodes.has(saved.get("node", "")):
		current_node_id = saved["node"]
		state = saved.get("state", state)

func restart() -> void:
	state = {"flags": {}, "stats": {}}
	current_node_id = START_NODE_ID
	show_node(current_node_id)

func show_error(message: String) -> void:
	speaker.text = "PROJECT ERROR"
	narrative.text = message
	panel_text.text = "Unable to load this chapter."
	push_error(message)
