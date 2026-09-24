import js.Browser;

class ProficiencyData {
	public static var list:Array<ProficiencyData>;
	public static inline function pf2e():Array<ProficiencyData> {
		return (cast Browser.window).pf2eProficiencies;
	}
	public static inline function sf2e():Array<ProficiencyData> {
		return (cast Browser.window).sf2eProficiencies;
	}
	//
	public var name:String;
	public var midName:String;
	public var shortName:String;
	public var id:String;
	public var perLevel:Array<ProficiencyPerLevel>;
	//
	public var hp:Int;
	public var kas:Array<String>;
	public var skills:{ value:Array<String>, additional:Int };
	public var weapons:String;
	public var spells:String;
}

typedef ProficiencyPerLevel = {
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