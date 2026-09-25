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
	static var summary:InputElement = find("#show-summary");
	//
	static var out:Element = find("#out");
	static var legend:UListElement = find("#legend");
	//
	public static var proficiencyNames = ["Untrained", "Trained", "Expert", "Master", "Legendary"];
	public static var proficiencyClassNames = proficiencyNames.map(s -> s.toLowerCase());
	public static var proficiencyShortNames = ["U", "T", "E", "M", "L"];
	//
	public static function createLegend() {
		var table = document.createTableElement();
		table.appendSimple('td', 'Legend');
		for (i => prof in proficiencyNames) {
			var td = table.appendSimple('td', prof);
			td.classList.add("prof", proficiencyClassNames[i]);
		}
		return table;
	}
	public static function run() {
		if (!canRender) return;
		function getPicks<T:{name:String}>(set:TagBlockSet, arr:Array<T>) {
			var out = [];
			for (node in set.blocks) {
				var button:SpanElement = cast node;
				var name = button.innerText;
				var thing = arr.filter(q -> q.name == name)[0];
				if (thing != null) out.push(thing);
			}
			return out;
		}
		//
		var chosenClasses = getPicks(classes, ProficiencyData.list);
		var chosenProfs = getPicks(proficiencies, ProficiencyType.list);
		//
		legend.innerHTML = "";
		out.innerHTML = "";
		out.append(createLegend());
		function appendTD(row:TableRowElement, text:String, isHeader = false) {
			var th:TableCellElement = isHeader ? cast document.createElement("th") : document.createTableCellElement();
			SummaryRenderer.setText(th, text);
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
		function addProficiencyTD(tr:TableRowElement, cl, prof, level:Int, tier:Int) {
			var td = appendTD(tr, proficiencyShortNames[tier]);
			td.title = [
				'Level $level',
				cl.name,
				prof.name + ": " + proficiencyNames[tier],
			].join("\n");
			td.classList.add("prof", proficiencyClassNames[tier]);
			return td;
		}
		//
		//
		var sep = separate.checked;
		var table:TableElement = null;
		function prependHeader(text:String) {
			var h2 = document.createElement("h2");
			h2.append(text);
			table.before(h2);
		}
		//
		if (summary.checked) {
			table = SummaryRenderer.run(chosenClasses, chosenProfs);
			out.append(table);
			prependHeader("Summary (WIP)");
		}
		//
		table = document.createTableElement();
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
					appendTH(row, (cl.midName != null ? cl.midName + "|" : "") + cl.name).classList.add("align-right");
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
		summary.onchange = e -> { run(); };
	}
}