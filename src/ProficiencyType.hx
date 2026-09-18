import ProficiencyData;

class ProficiencyType {
	public static var list:Array<ProficiencyType> = [];
	//
	static function register(name, getter, onByDefault = true) {
		var type = new ProficiencyType(name, getter, onByDefault);
		list.push(type);
		return type;
	}
	public static var weapons = register("Weapons", p -> p.weapons);
	public static var spells = register("Spells", p -> p.spells);
	public static var classDC = register("Class DC", p -> p.classDC);
	public static var armor = register("Armor", p -> p.armor);
	public static var lightArmor = register("Light Armor", p -> p.lightArmor, false);
	public static var mediumArmor = register("Medium Armor", p -> p.mediumArmor, false);
	public static var heavyArmor = register("Heavy Armor", p -> p.heavyArmor, false);
	public static var unarmored = register("Unarmored", p -> p.unarmored);
	public static var fortitude = register("Fortitude", p -> p.fortitude);
	public static var reflex = register("Reflex", p -> p.reflex);
	public static var will = register("Will", p -> p.will);
	public static var perception = register("Perception", p -> p.perception);
	//
	public var name:String;
	public var getter:ProficiencyPerLevel->Int;
	public var id:String;
	public var onByDefault:Bool;
	function new(name:String, getter:ProficiencyPerLevel->Int, onByDefault:Bool) {
		this.name = name;
		this.getter = getter;
		id = makeID(name);
		this.onByDefault = onByDefault;
	}
	
	public static function init() {
		//
	}
}