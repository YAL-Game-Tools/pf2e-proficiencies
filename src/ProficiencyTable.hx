import js.lib.RegExp;
import js.html.SpanElement;
import js.html.DragEvent;
import js.html.URLSearchParams;
import js.html.UListElement;
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
		var parentID = target.id;
		var parentKey = "text/parent-is-" + parentID;
		var id = text;
		id = (cast id).replaceAll(new RegExp("[^\\w+ ]", "g"), "");
		id = StringTools.replace(id, " ", "-");
		var fullID = parentID + ":" + id;
		var button = document.createSpanElement();
		button.classList.add("button");
		button.append(text);
		button.id = fullID;
		button.draggable = true;
		//button.type = "button";
		//button.value = text;
		button.onclick = e -> {
			button.remove();
			render();
		};
		button.ondragstart = (e:DragEvent) -> {
			e.dataTransfer.setData("text/element-id", fullID);
			e.dataTransfer.setData(parentKey, "true");
			e.dataTransfer.effectAllowed = "move";
			button.classList.add("dragged");
		};
		button.ondragend = (e:DragEvent) -> {
			button.classList.remove("dragged");
		}
		button.ondragover = (e:DragEvent) -> {
			if (button.classList.contains("dragged")) return;
			if (e.dataTransfer.types.contains(parentKey)) {
				e.dataTransfer.dropEffect = "move";
				e.preventDefault();
				if (e.offsetX < button.offsetWidth / 2) {
					button.classList.add("drop-before");
					button.classList.remove("drop-after");
				} else {
					button.classList.remove("drop-before");
					button.classList.add("drop-after");
				}
			}
		};
		button.ondragleave = (e:DragEvent) -> {
			button.classList.remove("drop-before");
			button.classList.remove("drop-after");
		}
		button.ondrop = (e:DragEvent) -> {
			var after = button.classList.contains("drop-after");
			button.classList.remove("drop-before");
			button.classList.remove("drop-after");
			var dropID = e.dataTransfer.getData("text/element-id");
			if (dropID == null) return;
			var thing = document.getElementById(dropID);
			if (thing == null) return;
			if (after) {
				button.after(thing);
			} else button.before(thing);
			render();
		}
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
	static var separate:InputElement = find("#separate");
	static var out:TableElement = find("#out");
	static var legend:UListElement = find("#legend");
	static var canRender = true;
	static function getPicks<T:{name:String}>(div:Element, arr:Array<T>) {
		var out = [];
		for (node in div.querySelectorAll('.button')) {
			var button:SpanElement = cast node;
			var name = button.innerText;
			var thing = arr.filter(q -> q.name == name)[0];
			if (thing != null) out.push(thing);
		}
		return out;
	}
	//
	static function render() {
		if (!canRender) return;
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
		//
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
		//
		var sep = separate.checked;
		var table:TableElement = document.createTableElement();
		function prependHeader(text:String) {
			var h2 = document.createElement("h2");
			h2.append(text);
			table.before(h2);
		}
		out.append(table);
		//
		if (sideways.checked) { // Name > Class > Level
			function addHeader() {
				table.classList.add("sideways");
				var headerRow = document.createTableRowElement();
				if (!sep) appendTH(headerRow, "Name").classList.add("align-right");
				appendTH(headerRow, "Class").classList.add("align-right");
				for (level in 1 ... 21) {
					var th = appendTH(headerRow, "" + level);
					th.classList.add("level-row");
					if (wantLevelSep(level)) th.classList.add("sep-left");
				}
				table.append(headerRow);
			}
			addHeader();
			//
			for (profIndex => prof in chosenProfs) {
				if (sep && profIndex > 0) {
					table = document.createTableElement();
					out.append(table);
					addHeader();
				}
				if (sep) prependHeader(prof.name);
				for (classIndex => cl in chosenClasses) {
					var row = document.createTableRowElement();
					if (classIndex == 0 && !sep) {
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
					table.append(row);
				}
			}
		} else { // Name > Weapons > Spells
			// add legends:
			for (cl in chosenClasses) {
				var li = document.createLIElement();
				li.append('${cl.shortName}: ${cl.name}');
				legend.append(li);
			}
			//
			var rows:Array<TableRowElement> = null;
			function init() {
				if (!sep) {
					var profRow = document.createTableRowElement();
					appendTH(profRow, "Name").classList.add("align-right");
					for (prof in chosenProfs) {
						appendTH(profRow, prof.name, chosenClasses.length).classList.add("sep-left");
					}
					table.append(profRow);
				}
				//
				var classRow = document.createTableRowElement();
				appendTH(classRow, "Class").classList.add("align-right", "condensed");
				table.append(classRow);
				rows = [classRow];
				//
				for (level in 1 ... 21) {
					var tr = document.createTableRowElement();
					if (wantLevelSep(level)) tr.classList.add("sep-top");
					appendTD(tr, "" + level).classList.add("align-right");
					table.append(tr);
					rows.push(tr);
				}
			}
			function addClassNames() {
				var first = true;
				for (cl in chosenClasses) {
					var th = appendTH(rows[0], cl.shortName);
					th.classList.add("condensed");
					th.title = cl.name;
					if (first) {
						first = false;
						th.classList.add("sep-left");
					}
				}
			}
			init();
			//
			for (profIndex => prof in chosenProfs) {
				if (profIndex > 0 && sep) {
					table = document.createTableElement();
					out.append(table);
					init();
				}
				if (sep) prependHeader(prof.name);
				addClassNames();
				for (level in 1 ... 21) {
					var tr = rows[level];
					for (ci => cl in chosenClasses) {
						var tier = prof.getter(cl.perLevel[level - 1]);
						var td = addProficiencyTD(tr, cl, prof, level, tier);
						if (ci == 0) {
							td.classList.add("sep-left");
						}
					}
				}
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
		separate.onchange = e -> { render(); };
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