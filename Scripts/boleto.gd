extends Control
class_name Boleto

@onready var vuelo_label: Label = %Vuelo
@onready var asiento_label: Label = %Asiento
@onready var horario_label: Label = %Horario
@onready var cliente_label = %Cliente
@onready var ui_sounds = get_tree().get_first_node_in_group("Sound")

@onready var panel = $Panel

var cliente: String = ""
var vuelo: String = ""
var asientos: String = ""
var horario: String = ""

var asiento_obj: Array[Asiento] = []

func set_data(n_cliente: String, n_vuelo: String, n_asiento: String, n_horario: String, n_asiento_onj: Asiento) -> void:
	vuelo = n_vuelo
	cliente = n_cliente
	asientos = n_asiento
	horario = n_horario
	vuelo_label.text = vuelo.capitalize()
	cliente_label.text = cliente
	asiento_label.text = asientos
	horario_label.text = horario.capitalize()
	asiento_obj.append(n_asiento_onj)

func add_boleto(n_asiento: Asiento) -> void:
	asiento_obj.append(n_asiento)
	
	# Reconstruir la lista completa de asientos
	asientos = ""
	for i in range(asiento_obj.size()):
		if i > 0:
			asientos += ", "
		asientos += asiento_obj[i].id_asiento
	
	asiento_label.text = asientos

func _on_mouse_entered():
	for obj in asiento_obj:
		obj.update_border(true)
		ui_sounds.animate_hover(obj)
	panel.get_theme_stylebox("panel").bg_color = Color("4e4e4e99")
	
func _on_mouse_exited():
	for obj in asiento_obj:
		obj.update_border(false)
		ui_sounds.animate_hover(obj)
	panel.get_theme_stylebox("panel").bg_color = Color("1a1a1a99")
