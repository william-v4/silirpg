extends Node
class_name food
# food properties
enum type {
	COFFEE,
	SALAD,
	NOODLES
}
const prices = {
	type.COFFEE: 50,
	type.SALAD: 100,
	type.NOODLES: 150
}
const energies = {
	type.COFFEE: 10,
	type.SALAD: 30,
	type.NOODLES: 40
}
## store the type of food (modified in GUI editor)
@export var foodtype : type
