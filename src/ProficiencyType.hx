import ProficiencyData;

class ProficiencyType {
	public static var list:Array<ProficiencyType> = [];
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
		function add(name, getter, onByDefault = true) {
			list.push(new ProficiencyType(name, getter, onByDefault));
		}
		add("Weapons", p -> p.weapons);
		add("Spells", p -> p.spells);
		add("Class DC", p -> p.classDC);
		add("Armor", p -> p.armor);
		add("Light Armor", p -> p.lightArmor, false);
		add("Medium Armor", p -> p.mediumArmor, false);
		add("Heavy Armor", p -> p.heavyArmor, false);
		add("Unarmored", p -> p.unarmored, false);
		add("Fortitude", p -> p.fortitude);
		add("Reflex", p -> p.reflex);
		add("Will", p -> p.will);
		add("Perception", p -> p.perception);
	}
}