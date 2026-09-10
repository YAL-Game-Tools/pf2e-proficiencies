import js.html.URLSearchParams;
import js.html.UListElement;
import haxe.rtti.CType.Classdef;
import js.html.TableCellElement;
import js.html.TableRowElement;
import js.html.TableElement;
import js.html.InputElement;
import js.html.DivElement;
import js.html.Element;
import js.Browser;
import js.Browser.document;
import js.html.SelectElement;
import js.html.Console;
import ProficiencyData;

class ProficiencyTable {
	static function find<T:Element>(query:String, ?c:Class<T>):T {
		return cast document.querySelector(query);
	}
	static function addRemovable(target:Element, text:String) {
		var button = document.createInputElement();
		button.type = "button";
		button.value = text;
		button.onclick = e -> {
			button.remove();
			render();
		};
		target.append(button);
		render();
		return button;
	}
	static function createRemovableFactory(select:SelectElement, add:InputElement, clear:InputElement, out:Element) {
		add.onclick = e -> {
			var snip = select.value;
			if (snip != "" && snip != null) addRemovable(out, snip);
		};
		clear.onclick = e -> {
			out.innerHTML = "";
			render();
		}
	}
	//
	static var profData:Array<{ name:String, getter:ProficiencyPerLevel->Int, opt:Bool }> = [];
	static var profPicker:SelectElement = find("#prof-picker");
	static var profList:DivElement = find("#prof-list");
	static function addProf(name, getter, opt = false) {
		profData.push({ name: name, getter: getter, opt: opt });
		var option = document.createOptionElement();
		option.text = name;
		profPicker.append(option);
	}
	//
	static var classData:Array<ProficiencyData>;
	static var classPicker:SelectElement = find("#class-picker");
	static var classList:DivElement = find("#class-list");
	//
	static var sideways:InputElement = find("#sideways");
	static var out:TableElement = find("#out");
	static var legend:UListElement = find("#legend");
	static var canRender = true;
	static function render() {
		if (!canRender) return;
		function getPicks<T:{name:String}>(div:Element, arr:Array<T>) {
			var out = [];
			for (node in div.querySelectorAll('input[type="button"]')) {
				var button:InputElement = cast node;
				var name = button.value;
				var thing = arr.filter(q -> q.name == name)[0];
				if (thing != null) out.push(thing);
			}
			return out;
		}
		//
		var chosenClasses = getPicks(classList, classData);
		var chosenProfs = getPicks(profList, profData);
		//
		legend.innerHTML = "";
		out.innerHTML = "";
		function appendTD(row:TableRowElement, text:String, isHeader = false) {
			var th:TableCellElement = isHeader ? cast document.createElement("th") : document.createTableCellElement();
			th.append(text);
			row.append(th);
			return th;
		}
		function appendTH(row:TableRowElement, text:String, colSpan = 1) {
			var th = appendTD(row, text, true);
			if (colSpan != 1) th.colSpan = colSpan;
			return th;
		}
		inline function wantLevelSep(level:Int) {
			return (level == 1 || level % 5 == 0);
		}
		static var proficiencyNames = ["Untrained", "Trained", "Expert", "Master", "Legendary"];
		static var proficiencyShortNames = ["U", "T", "E", "M", "L"];
		function addProficiencyTD(tr:TableRowElement, cl, prof, level:Int, tier:Int) {
			var td = appendTD(tr, proficiencyShortNames[tier]);
			td.title = [
				'Level $level',
				cl.name,
				prof.name + ": " + proficiencyNames[tier],
			].join("\n");
			td.classList.add("prof-" + proficiencyNames[tier].toLowerCase());
			return td;
		}
		if (sideways.checked) { // Name > Class > Level
			var th1 = document.createTableRowElement();
			appendTH(th1, "Name").classList.add("align-right");
			appendTH(th1, "Class").classList.add("align-right");
			for (level in 1 ... 21) {
				var th = appendTH(th1, "" + level);
				if (wantLevelSep(level)) th.classList.add("sep-left");
			}
			out.append(th1);
			//
			for (prof in chosenProfs) {
				var first = true;
				for (cl in chosenClasses) {
					var row = document.createTableRowElement();
					if (first) {
						first = false;
						row.classList.add("sep-top");
						var th = appendTH(row, prof.name);
						th.classList.add("align-right");
						th.rowSpan = chosenClasses.length;
					}
					appendTH(row, cl.name).classList.add("align-right");
					//
					for (level in 1 ... 21) {
						var tier = prof.getter(cl.perLevel[level - 1]);
						var td = addProficiencyTD(row, cl, prof, level, tier);
						if (wantLevelSep(level)) {
							td.classList.add("sep-left");
						}
					}
					//
					out.append(row);
				}
			}
		} else { // Name > Weapons > Spells
			//
			var th1 = document.createTableRowElement();
			appendTH(th1, "Name").classList.add("align-right");
			for (prof in chosenProfs) {
				appendTH(th1, prof.name, chosenClasses.length).classList.add("sep-left");
			}
			out.append(th1);
			//
			var th2 = document.createTableRowElement();
			appendTH(th2, "Class").classList.add("align-right");
			for (prof in chosenProfs) {
				var first = true;
				for (cl in chosenClasses) {
					var th = appendTH(th2, cl.shortName);
					th.title = cl.name;
					if (first) {
						first = false;
						th.classList.add("sep-left");
					}
				}
			}
			out.append(th2);
			// add legends:
			for (cl in chosenClasses) {
				var li = document.createLIElement();
				li.append('${cl.shortName}: ${cl.name}');
				legend.append(li);
			}
			//
			for (level in 1 ... 21) {
				var tr = document.createTableRowElement();
				if (level == 1 || (level % 5 == 0)) {
					tr.classList.add("sep-top");
				}
				appendTD(tr, "" + level).classList.add("align-right");
				for (prof in chosenProfs) {
					var first = true;
					for (cl in chosenClasses) {
						var tier = prof.getter(cl.perLevel[level - 1]);
						var td = addProficiencyTD(tr, cl, prof, level, tier);
						if (first) {
							first = false;
							td.classList.add("sep-left");
						}
					}
				}
				out.append(tr);
			}
		}
	}
	//
	public static function main() {
		//
		addProf("Weapons", p -> p.weapons);
		addProf("Spells", p -> p.spells);
		addProf("Class DC", p -> p.classDC);
		addProf("Armor", p -> p.armor);
		addProf("Light Armor", p -> p.lightArmor, true);
		addProf("Medium Armor", p -> p.mediumArmor, true);
		addProf("Heavy Armor", p -> p.heavyArmor, true);
		addProf("Unarmored", p -> p.unarmored, true);
		addProf("Fortitude", p -> p.fortitude);
		addProf("Reflex", p -> p.reflex);
		addProf("Will", p -> p.will);
		addProf("Perception", p -> p.perception);
		createRemovableFactory(profPicker, find("#prof-add"), find("#prof-clear"), profList);
		//
		{
			var search = new URLSearchParams(document.location.search);
			classData = [];
			if (!search.has("sf2e")) {
				classData = classData.concat(ProficiencyData.pf2e());
			}
			if (search.has("sf2e") || search.has("both")) {
				classData = classData.concat(ProficiencyData.sf2e());
			}
		}
		//
		var sortedClassNames = classData.map(c -> c.name);
		sortedClassNames.sort((a, b) -> (a < b ? -1 : 1));
		for (name in sortedClassNames) {
			var option = document.createOptionElement();
			option.text = name;
			classPicker.append(option);
		}
		createRemovableFactory(classPicker, find("#class-add"), find("#class-clear"), classList);
		//
		sideways.onchange = e -> { render(); };
		// demo
		canRender = false;
		for (cl in classData) {
			addRemovable(classList, cl.name);
		}
		for (prof in profData) if (!prof.opt) {
			addRemovable(profList, prof.name);
		}
		canRender = true;
		render();
	}
}