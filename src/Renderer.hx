import js.html.TableCellElement;
import js.html.TableRowElement;
import js.html.SpanElement;
import js.html.Element;
import js.html.UListElement;
import js.html.TableElement;
import js.html.InputElement;
import ProficiencyTable.*;

class Renderer {
	public static var canRender = true;
	// checkboxes
	static var sideways:InputElement = find("#sideways");
	static var separate:InputElement = find("#separate");
	//
	static var out:Element = find("#out");
	static var legend:UListElement = find("#legend");
	//
	public static function run() {
		if (!canRender) return;
		function getPicks<T:{name:String}>(div:Element, arr:Array<T>) {
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
	public static function init() {
		sideways.onchange = e -> { run(); };
		separate.onchange = e -> { run(); };
	}
}