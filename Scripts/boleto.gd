extends Control
class_name Boleto

@onready var cliente_label: Label = %Cliente
@onready var vuelo_label: Label = %Vuelo
@onready var asiento_label: Label = %Asiento
@onready var horario_label: Label = %Horario

var cliente: String = ""
var vuelo: String = ""
var asiento: String = ""
var horario: String = ""

func set_data(n_cliente: String, n_vuelo: String, n_asiento: String, n_horario: String) -> void:
	cliente = n_cliente
	vuelo = n_vuelo
	asiento = n_asiento
	horario = n_horario
	cliente_label.text = cliente
	vuelo_label.text = vuelo
	asiento_label.text = asiento
	horario_label.text = horario
