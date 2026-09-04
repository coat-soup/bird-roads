class_name StatModifiers

## in general, these modifiers are a value addition per level of their relevant stat. stats go from -5 to +5
## value = base_value + base_value * modifier_value * stat_level
## eg base_speed = 5, agility_speed_modifier = 0.2, agility = -1: speed = 5 + 5 * 0.2 * -1 -> speed = 4


static var marksmanship_spread : float = -0.2
static var agility_speed : float = 0.1
static var patience_boredome : float = 0.2
