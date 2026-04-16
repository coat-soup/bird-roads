class_name ActorData
extends Resource

enum Profession {TRADER, MERCENARY, FREELANCER, MILITARY}
enum Faction {FREE, PIRATE, PEOPLE, CROWN, RADICALS, CHURCH, MERCHANTS}

@export var profession : Profession
@export var faction : Faction

@export var speed : float = 50
@export var cargo_capacity : int = 5
@export var combat_power : int = 2

@export var ship_name : String


func _init(premade : bool = false) -> void:
	if ship_name == "": ship_name = random_ship_name()
	
	speed += randf_range(-10,10)
	cargo_capacity += randi_range(-3,3)
	
	const faction_weights : Dictionary[Faction, float] = {
		Faction.FREE: 2.0,
		Faction.PIRATE: 1.0,
		Faction.PEOPLE: 1.0,
		Faction.CROWN: 1.0,
		Faction.RADICALS: 1.0,
		Faction.CHURCH: 1.0,
		Faction.MERCHANTS: 1.0
	}
	
	faction = RandomNumberGenerator.new().rand_weighted(faction_weights.values())
	print(ship_name, " is of faction " , Faction.keys()[faction])


static func random_ship_name():
	var a : Array[String] = ["Radiant", "Swift", "Majestic", "Vigilant", "Ethereal", "Cerulean", "Stalwart", "Nebulous", "Sapphire", "Fierce", "Celestial", "Resolute", "Infinite", "Luminous", "Gallant", "Phantom", "Sovereign", "Vivid", "Enigmatic", "Peregrine", "Vortex", "Epic", "Astral", "Blazing", "Nautical", "Eclipsed", "Daring", "Serene", "Thunderous", "Pristine", "Zenith", "Cascade", "Harmony", "Illustrious", "Velvet", "Roaring", "Ethereal", "Prowling", "Valiant", "Umbra", "Zephyr", "Halcyon", "Vesper", "Crimson", "Azure", "Quicksilver", "Inferno", "Radiant", "Adventurous", "Aureate", "Lustrous", "Vivid", "Dusky", "Solar", "Stellar", "Ethereal", "Dazzling", "Vibrant", "Sable", "Mystic", "Glorious", "Sculpted", "Iridescent", "Noble", "Epic", "Silent", "Rapid", "Eternal", "Obsidian", "Dynamic", "Celestial", "Harmonic", "Grand", "Reverent", "Whispering", "Illuminated", "Abyssal", "Marine", "Ornate", "Ephemeral", "Pendulum", "Radiant", "Galactic", "Cerulean", "Crimson", "Gossamer", "Sonorous", "Vorpal", "Ineffable", "Zephyrian", "Weeping", "Storm", "Spirit", "Widow's"]
	var b : Array[String] = ["Horizon", "Tempest", "Aegis", "Crest", "Rhapsody", "Vanguard", "Serenity", "Cynosure", "Harbinger", "Pinnacle", "Labyrinth", "Quasar", "Sentinel", "Monolith", "Tranquility", "Eclipse", "Chronicle", "Odyssey", "Nebula", "Arcadia", "Citadel", "Aurora", "Oracle", "Zephyr", "Ephemera", "Oblivion", "Vortex", "Paragon", "Cascade", "Equinox", "Labyrinth", "Prelude", "Veracity", "Fathom", "Infinity", "Voyage", "Elysium", "Tempest", "Apex", "Halcyon", "Celestia", "Genesis", "Oasis", "Allegro", "Nimbus", "Echelon", "Pantheon", "Spectra", "Solitude", "Scepter", "Apogee", "Radiance", "Chalice", "Chronicle", "Abyss", "Aether", "Mirage", "Quintessence", "Peregrine", "Paradigm", "Harmony", "Nautica", "Aegis", "Epoch", "Luminosity", "Equilibrium", "Pinnacle", "Ephemeron", "Inception", "Vigil", "Provenance", "Resonance", "Scepter", "Myriad", "Silhouette", "Aegis", "Oblivion", "Ascendant", "Serenade", "Sculpture", "Zephyr", "Ethereality", "Synchrony", "Panorama", "Eclipse", "Phantom", "Talisman", "Storm", "Spirit", "Somnambulist", "Widow"]
	return "%s %s" % [a.pick_random(), b.pick_random()]
