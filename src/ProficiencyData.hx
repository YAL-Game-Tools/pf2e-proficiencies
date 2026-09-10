import js.Browser;

extern class ProficiencyData {
	public static inline function get():Array<ProficiencyData> {
		return (cast Browser.window).proficienciesPerClass;
	}
	
	public var name:String;
	public var shortName:String;
	public var perLevel:Array<ProficiencyPerLevel>;
}
extern class ProficiencyPerLevel {
	var classDC:Int;
	var perception:Int;
	var weapons:Int;
	var lightArmor:Int;
	var mediumArmor:Int;
	var heavyArmor:Int;
	var unarmored:Int;
	var armor:Int;
	var spells:Int;
	var fortitude:Int;
	var reflex:Int;
	var will:Int;
}