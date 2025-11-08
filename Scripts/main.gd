extends Node

const N_CLIENTS = 50
const FLIGHTS = 3
var flights = [] # cada vuelo: {id:int, vip_left:int, norm_left:int, sold:Array}
var flight_mutexes = [] # Mutex por vuelo

func _ready():
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	# crear vuelos reducidos para notar la carrera
	for i in range(FLIGHTS):
		flights.append({
			"id": i,
			"vip_left": 5,
			"norm_left": 10,
			"sold": []
		})
		flight_mutexes.append(Mutex.new())

	# lanzar hilos clientes usando la versión con mutex
	for i in range(N_CLIENTS):
		var th := Thread.new()
		th.start(_client_thread_with_lock.bind(i))

	# timer para imprimir resultado
	var t := Timer.new()
	t.wait_time = 1.0
	t.one_shot = true
	add_child(t)
	t.start()
	t.connect("timeout", Callable(self, "_on_timer_timeout"))

func _client_thread_with_lock(client_id):
	var rnd := RandomNumberGenerator.new()
	rnd.randomize()

	# elegir vuelo y tipo
	var fidx := rnd.randi_range(0, FLIGHTS - 1)
	var want_vip := rnd.randf() < 0.2
	var want := 0
	if want_vip:
		want = rnd.randi_range(1, 3)
	else:
		want = rnd.randi_range(1, 5)

	var m = flight_mutexes[fidx]
	m.lock()

	var avail := 0
	if want_vip:
		avail = flights[fidx]["vip_left"]
	else:
		avail = flights[fidx]["norm_left"]

	var sold = min(want, avail)

	if want_vip:
		flights[fidx]["vip_left"] -= sold
	else:
		flights[fidx]["norm_left"] -= sold

	flights[fidx]["sold"].append({
		"client": client_id,
		"vip": (sold if want_vip else 0),
		"norm": (0 if want_vip else sold)
	})

	m.unlock()
	return

func _on_timer_timeout():
	print("=== RESULTADOS (con Mutex) ===")
	for f in flights:
		print("Vuelo %d -> VIP left: %d | NORM left: %d | Ventas: %s" % [
			f["id"], f["vip_left"], f["norm_left"], str(f["sold"])
		])
