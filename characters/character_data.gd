class_name CharacterData
extends Resource

@export var character_name : StringName


@export var stats : Dictionary[String, int] = {
	"marksmanship" : 0,
	"medecine" : 0,
	"engineering" : 0,
	"piloting" : 0,
	"fortitude" : 0,
	"agility" : 0,
}


@export var traits : Dictionary[String, int] = {
	"patience" : 0,
	"agression" : 0,
}


static func create() -> CharacterData:
	var char = CharacterData.new()
	 
	var rand = RandomNumberGenerator.new()
	char.character_name = first_names.pick_random() + " " + last_names.pick_random()
	
	for stat in char.stats.keys():
		char.stats[stat] = [0,1,2,3,4,5][rand.rand_weighted([10,5,3,2,1,0.5])]
		if rand.randf() > 0.5: char.stats[stat] *= -1
	
	print(char.character_name, " has stats ", char.stats)
	
	return char


static var first_names : Array[String] = ["James", "Games", "Ivan", "Jessie", "Widow", "Ash", "Sash", "Loomy", "Winnona", "Sigfreid", "Wilson", "Sonwil", "Willa", "Lune", "Jimothy", "Juan", "Maria"]
static var last_names : Array[String] = ["Mames", "Wilbert", "Don Juan", "O'Reily", "Reed", "The Third", "Jr", "Owenson", "Jams", "Paffa", "Carter", "Smith", "Baker", "Dartman", "Hearts", "Pillendon"]
