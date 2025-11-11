extends Control
class_name Aerolinea

@export var precio_normal: int = 0
@export var precio_VIP: int = 0
@export var pasajeros_num: Dictionary = {
	Horario.MAÑANA: 100,
	Horario.TARDE: 120,
	Horario.NOCHE: 180
}

# Referencias a contenedores (parte de la lógica, no de la UI visual)
@onready var aviones_container: VBoxContainer = %Aviones
@onready var pasajeros_container: GridContainer = %Pasajeros
@onready var boletos_container: VBoxContainer = %Boletos
@onready var ui_sounds = %UI_Sounds
@onready var boletos_container_smooth_scroll = %SmoothScrollContainer
@onready var asiento_hover = %AsientoHover

# Timer (parte de la lógica)
@onready var horario_timer = %TimerHorario

const AVION = preload("uid://n81ll22o6la7")
const PASAJERO = preload("uid://wfr82hnwltb2")
const BOLETO = preload("uid://y7otwl2babdt")

enum Horario { MAÑANA, TARDE, NOCHE }
enum Destino { COLOMBIA, CUBA, PERU }
enum Type { VIP, NORMAL, EMPTY }

# Variables de control de la simulación
var is_playing: bool = false
var current_horario_index: int = 0
var simulation_threads: Array[Thread] = []

# Datos de la simulación
var aviones: Array = []
var pasajeros: Array = []
var boletos: Dictionary = {}
var horario: Horario = Horario.MAÑANA
var total_requests: int = 0

var data_ui: Data

func _ready() -> void:
	# Buscar el componente Data entre los hijos
	data_ui = find_child("Data")
	if data_ui:
		data_ui.set_aerolinea(self)
	
	init()

func _on_reset_pressed() -> void:
	is_playing = false
	horario_timer.stop()
	current_horario_index = 0
	horario = Horario.MAÑANA
	
	cleanup_threads()
	if data_ui:
		data_ui.set_bar_horario(0)
	restart_day()

func _on_play_stop_pressed() -> void:
	if is_playing:
		is_playing = false
		horario_timer.stop()
	else:
		is_playing = true
		horario_timer.start()
		
		if data_ui:
			restart_day()
	
	# Actualizar UI
	if data_ui:
		data_ui.update_ui()

func _on_next_pressed() -> void:
	advance_to_next_horario()

func _on_timer_horario_timeout() -> void:
	if horario == Horario.NOCHE:
		is_playing = false
		horario_timer.stop()
		return
	advance_to_next_horario()

func advance_to_next_horario() -> void:
	current_horario_index = (current_horario_index + 1) % Horario.size()
	horario = Horario.values()[current_horario_index]
	
	if data_ui:
		data_ui.set_bar_horario(0)
	
	restart_day()
	
	if is_playing:
		horario_timer.start()

func init() -> void:
	is_playing = false
	current_horario_index = 0
	horario = Horario.MAÑANA
	restart_day()

func restart_day() -> void:
	cleanup_threads()
	
	# Limpiar boletos anteriores
	for boleto in boletos_container.get_children():
		boleto.queue_free()
	boletos.clear()
	total_requests = 0
	
	# Crear nuevos aviones y pasajeros
	aviones = create_aviones()
	pasajeros = create_passengers()
	
	# Actualizar UI
	if data_ui:
		data_ui.update_ui()

func create_aviones() -> Array:
	for avion in aviones_container.get_children():
		avion.queue_free()
	
	var arr: Array = []
	for i in range(Destino.size()):
		var avion_inst = AVION.instantiate()
		aviones_container.add_child(avion_inst)
		avion_inst.set_data({ "horario": horario, "destino": i, "id": i })
		arr.append(avion_inst)
	return arr

func create_passengers() -> Array:
	for pasajero in pasajeros_container.get_children():
		if pasajero.thread and pasajero.thread.is_alive():
			pasajero.thread.wait_to_finish()
		pasajero.queue_free()
	
	var arr: Array = []
	var total_pasajeros = pasajeros_num.get(horario, 0)
	
	for i in range(total_pasajeros):
		var passenger_inst = PASAJERO.instantiate()
		passenger_inst.aerolinea = self
		passenger_inst.id_pasajero = str(i)
		pasajeros_container.add_child(passenger_inst)
		
		arr.append(passenger_inst)
	return arr

func request_seat(pasajero: Pasajero, asiento: Asiento) -> void:
	if not is_playing:
		return
	
	asiento.set_pasajero(pasajero)
	call_deferred("create_boleto", (pasajero), Destino.keys()[int(pasajero.boletos["avion"].id_avion)], asiento)
	
func create_boleto(pasajero: Pasajero, id_avion: String, asiento: Asiento) -> void:
	if not boletos.has(pasajero.id_pasajero):
		var boleto = BOLETO.instantiate()
		boletos_container.add_child(boleto)
		boleto.set_data(pasajero.id_pasajero, id_avion, asiento.id_asiento, Horario.keys()[horario], asiento)
		boletos[pasajero.id_pasajero] = (boleto)
		asiento.boleto = boleto
	else:
		boletos[pasajero.id_pasajero].add_boleto(asiento)
	
	total_requests += 1
	# Actualizar UI después de crear boleto
	if data_ui: data_ui.update_ui()
	
	ui_sounds.animate_hover(asiento)

func get_plane(destino: Destino) -> Avion:
	for avion in aviones:
		if avion.destino == destino and avion.disponible:
			return avion
	return null

func cleanup_threads() -> void:
	for thread in simulation_threads:
		if thread and thread.is_alive():
			thread.wait_to_finish()
	simulation_threads.clear()

func _exit_tree() -> void:
	cleanup_threads()
	if horario_timer:
		horario_timer.stop()

# En Aerolinea.gd
func mover_boletos_al_frente_por_asiento(asiento: Asiento) -> void:
	# Para cada pasajero en el asiento, mover su boleto al frente
	for pasajero_id in asiento.pasajeros_id:
		if boletos.has(pasajero_id):
			var boleto = boletos[pasajero_id]
			# Mover el boleto a la primera posición en el contenedor
			boletos_container.move_child(boleto, 0)
