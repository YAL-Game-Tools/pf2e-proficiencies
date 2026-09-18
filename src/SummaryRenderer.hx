import ProficiencyData;
import js.html.TableCellElement;
import js.html.TableRowElement;
import js.html.Element;

class SummaryRenderer {
	static function setText(el:Element, snip:String) {
		if (snip == null) return;
		var text, title;
		var pos = snip.indexOf("|");
		if (pos >= 0) {
			text = StringTools.rtrim(snip.substring(0, pos));
			title = StringTools.ltrim(snip.substring(pos + 1));
		} else {
			text = snip;
			title = null;
		}
		el.append(text);
		if (title != null) el.title = title;
	}
	static function appendScale(td:Element, cl:ProficiencyData, t:ProficiencyType) {
		var scale = td.appendSimple("div");
		//td.classList.add("has-scale");
		td.classList.add("prof", "untrained", "scale");
		function levelToPercent(level) {
			return (cast (level / 20 * 100)).toFixed(2) + "%";
		}
		var lines = [cl.name + ": " + t.name];
		var current = -1;
		for (beforeLevel => byLevel in cl.perLevel) {
			var tier = t.getter(byLevel);
			if (current != tier) {
				current = tier;
				lines.push(Renderer.proficiencyNames[tier] + " at level " + (beforeLevel + 1));
				var fill = scale.appendSimple("div");
				fill.classList.add("fill", "prof", Renderer.proficiencyClassNames[tier]);
				fill.style.left = levelToPercent(beforeLevel);
			}
		}
		if (current == -1) lines.push("Untrained");
		td.title = lines.join("\n");
		//
		function addBar(level:Int) {
			var bar = td.appendSimple("div");
			bar.classList.add("bar");
			bar.style.left = levelToPercent(level - 1);
		}
		addBar(5);
		addBar(10);
		addBar(15);
		addBar(20);
		return scale;
	}
	public static function run(chosenClasses:Array<ProficiencyData>, chosenProfs:Array<ProficiencyType>) {
		var table = document.createTableElement();
		//
		var columnGroup:Array<Array<SummaryItem>> = [
			[
				SiCustom("KAS|Key Attribute Score", p -> {
					var long = p.kas.map(a -> switch (a) {
						case "str": "Strength";
						case "dex": "Dexterity";
						case "con": "Constitution";
						case "wis": "Wisdom";
						case "int": "Intelligence";
						case "cha": "Charisma";
						default: a.capitalize();
					}).join(" or ");
					var short = p.kas.join("/");
					switch (short) {
						case "dex/str": short = "dx/st";
						case "int/cha": short = "int/ch";
					}
					return '$short|$long';
				}),
				SiProficiency(ProficiencyType.classDC),
			], [
				SiCustom("W1|Weapon categories", p -> p.weapons),
				SiProficiency(ProficiencyType.weapons),
				SiCustom("S#|Spell slots", p -> p.spells),
				SiProficiency(ProficiencyType.spells),
			], [
				SiCustom("S1|Skill training", p -> {
					var t = p.skills;
					if (t == null) return null;
					var snip = '${t.value.length}+${t.additional}';
					if (t.value.length > 0) {
						snip += '|${t.value.map(s -> s.capitalize()).join(", ")} and ${t.additional}+INT more skills';
					}
					return snip;
				}),
				SiProficiency(ProficiencyType.perception),
			], [
				SiCustom("A1|Armor training", p -> {
					var first = p.perLevel[0];
					if (first.heavyArmor > 0) return "H";
					if (first.mediumArmor > 0) return "M";
					if (first.lightArmor > 0) return "L";
					return "U";
				}),
				SiProficiency(ProficiencyType.armor),
			], [
				SiCustom("HP", p -> "" + p.hp),
				SiProficiency(ProficiencyType.fortitude),
				SiProficiency(ProficiencyType.reflex),
				SiProficiency(ProficiencyType.will),
			]
		];
		//
		var header = table.appendSimple("tr");
		header.appendSimple("th", "Class");
		for (group in columnGroup) {
			for (i => item in group) {
				var text = switch (item) {
					case SiProficiency(t): t.name;
					case SiCustom(name, getter): name;
				}
				var th = header.appendSimple("th");
				setText(th, text);
				if (i == 0) th.classList.add("sep-left");
			}
		}
		//
		for (cl in chosenClasses) {
			var tr = table.appendSimple("tr");
			tr.appendSimple("td", cl.name);
			for (group in columnGroup) {
				for (i => item in group) {
					var td:Element = tr.appendSimple("td");
					if (i == 0) td.classList.add("sep-left");
					switch (item) {
						case SiProficiency(t): {
							var byLevel = cl.perLevel.map(t.getter);
							appendScale(td, cl, t);
						};
						case SiCustom(name, getter): {
							setText(td, getter(cl));
						};
					}
				}
			}
		}
		//
		return table;
	}
}
enum SummaryItem {
	SiProficiency(t:ProficiencyType);
	SiCustom(name:String, getter:ProficiencyData->String);
}