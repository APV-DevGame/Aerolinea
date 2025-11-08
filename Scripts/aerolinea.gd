extends Control
class_name Aerolinea

@export var precio_normal: int = 0
@export var precio_VIP: int = 0
@export var pasajeros: Dictionary = {
	Horario.MAÑANA: 10,
	Horario.TARDE: 30,
	Horario.NOCHE: 50
}

enum Horario { MAÑANA, TARDE, NOCHE }
enum Destino { COLOMBIA, CUBA, PERU }
enum Type { VIP, NORMAL }

# -> { "avion": Avion, "asiento": Asiento, "pasajero": Pasajero } 
var boletos_vendidos: Dictionary = {}
var tiempo_despegue: float = 0
var aviones: Array[Avion]
var horario: Horario = Horario.MAÑANA

func create_avion() -> Avion:
	return null

func create_passengers() -> Pasajero:
	return null

func sell_boleto(destino: Destino, people: int) -> Dictionary:
	var boleto: Dictionary = {}
	var avion: Avion = get_plane(destino)
	var asiento: Array = []

	
	return {}

func plane_takeoff(destino: Destino) -> void:
	pass

func get_plane(destino: Destino) -> Avion:
	for avion in aviones:
		if avion.destino == destino:
			return avion
	return null
	
func get_row_asientos(avion: Avion, n: int) -> Asiento:
	for seat: Asiento in avion.get_available_seats():
		if seat.pos:
			pass
	
	return null
