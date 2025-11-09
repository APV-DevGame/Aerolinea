extends Control
class_name Aerolinea

@export var precio_normal: int = 0
@export var precio_VIP: int = 0
@export var pasajeros_num: Dictionary = {
	Horario.MAÑANA: 129,
	Horario.TARDE: 30,
	Horario.NOCHE: 50
}

@onready var aviones_container: VBoxContainer = %Aviones
@onready var pasajeros_container: GridContainer = %Pasajeros
@onready var boletos_container: VBoxContainer = %Boletos

@onready var bar_horario: ProgressBar = %BarHorario

const AVION = preload("uid://n81ll22o6la7")
const PASAJERO = preload("uid://wfr82hnwltb2")
const BOLETO = preload("uid://y7otwl2babdt")

enum Horario { MAÑANA, TARDE, NOCHE }
enum Destino { COLOMBIA, CUBA, PERU }
enum Type { VIP, NORMAL, EMPTY }

# -> { "avion": Avion, "asiento": Asiento, "pasajero": Pasajero } 
var boletos_vendidos: Dictionary = {}
var tiempo_despegue: float = 0
var aviones: Array = []
var pasajeros: Array = []
var horario: Horario = Horario.MAÑANA

func init() -> void:
	pass

func _on_timer_horario_timeout() -> void:
	restart_day()
	if horario < 1:
		horario = (horario + 1) as Horario
	var tween = get_tree().create_tween()
	tween.tween_property(bar_horario, "value", 100, 3)

func restart_day() -> void:
	aviones = create_aviones()
	pasajeros = create_passengers()

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
		pasajero.queue_free()
	
	var arr: Array = []
	for i in range(pasajeros_num[horario]):
		var passenger_inst = PASAJERO.instantiate()
		passenger_inst.aerolinea = self
		passenger_inst.id_pasajero = str(i)
		pasajeros_container.add_child(passenger_inst)
		
		arr.append(passenger_inst)
	return arr

func request_seat(pasajero: Pasajero, asiento: Asiento) -> void:
	asiento.set_pasajero(pasajero)
	call_deferred("create_boleto", str(pasajero.id_pasajero), Destino.keys()[int(pasajero.boletos["avion"].id_avion)], asiento.id_asiento)
	
func create_boleto(id_pasajero: String, id_avion: String, id_asiento: String) -> void:
	var boleto = BOLETO.instantiate()
	boletos_container.add_child(boleto)
	boleto.set_data(id_pasajero, id_avion, id_asiento, Horario.keys()[horario])
	
func plane_takeoff(destino: Destino) -> void:
	pass

func get_plane(destino: Destino) -> Avion:
	for avion in aviones:
		if avion.destino == destino and avion.disponible:
			return avion
	return null
	
