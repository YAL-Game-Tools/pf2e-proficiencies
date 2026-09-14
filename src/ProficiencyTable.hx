import js.html.KeyboardEvent;
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
using tools.ArrayTools;

class ProficiencyTable {
	static function makeID(text:String) {
		var id = text;
		id = (cast id).replaceAll(new RegExp("[^\\w+ ]", "g"), "");
		id = StringTools.replace(id, " ", "-");
		return id;
	}
	static function addRemovable(target:Element, text:String) {
		var parentID = target.id;
		var parentKey = "text/parent-is-" + parentID;
		var id = makeID(text);
		var fullID = parentID + ":" + id;
		var button = document.createSpanElement();
		button.classList.add("button");
		button.append(text);
		button.dataset.id = id;
		button.id = fullID;
		button.draggable = true;
		//button.type = "button";
		//button.value = text;
		button.onclick = e -> {
			button.remove();
			Renderer.run();
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
			Renderer.run();
		}
		target.append(button);
		Renderer.run();
		return button;
	}
	static function addMissingRemovables(
		select:SelectElement,
		out:Element
	) {
		Renderer.canRender = false;
		var added = false;
		var names = [for (e in out.querySelectorAll(".button")) (cast e:Element).innerText];
		for (i in 0 ... select.options.length) {
			var text = select.options[i].innerText;
			if (!names.contains(text)) {
				addRemovable(out, text);
				added = true;
			}
		}
		Renderer.canRender = true;
		if (added) Renderer.run();
	}
	static function createRemovableFactory(
		select:SelectElement,
		add:InputElement,
		addMissing:InputElement,
		clear:InputElement,
		out:Element
	) {
		add.onclick = e -> {
			var snip = select.value;
			if (snip != "" && snip != null) addRemovable(out, snip);
		};
		addMissing.onclick = e -> {
			addMissingRemovables(select, out);
		}
		clear.onclick = e -> {
			out.innerHTML = "";
			Renderer.run();
		}
	}
	//
	public static var profData:Array<{ name:String, id:String, getter:ProficiencyPerLevel->Int, opt:Bool }> = [];
	public static var profPicker:SelectElement = find("#prof-picker");
	public static var profList:DivElement = find("#prof-list");
	static function addProf(name, getter, opt = false) {
		profData.push({ name: name, id: makeID(name), getter: getter, opt: opt });
		var option = document.createOptionElement();
		option.text = name;
		profPicker.append(option);
	}
	//
	public static var classData:Array<ProficiencyData>;
	public static var classPicker:SelectElement = find("#class-picker");
	public static var classList:DivElement = find("#class-list");
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
		createRemovableFactory(profPicker, find("#prof-add"), find("#prof-add-missing"), find("#prof-clear"), profList);
		//
		var modeStr:String = "pf2e";
		var search = new URLSearchParams(document.location.search);
		{
			classData = [];
			if (search.has("both")) {
				modeStr = "both";
			} else if (search.has("sf2e")) {
				modeStr = "sf2e";
			}
			if (!search.has("sf2e")) {
				classData = classData.concat(ProficiencyData.pf2e());
			}
			if (search.has("sf2e") || search.has("both")) {
				classData = classData.concat(ProficiencyData.sf2e());
			}
		}
		for (cl in classData) {
			cl.id = makeID(cl.name);
		}
		//
		var sortedClassNames = classData.map(c -> c.name);
		sortedClassNames.sort((a, b) -> (a < b ? -1 : 1));
		for (name in sortedClassNames) {
			var option = document.createOptionElement();
			option.text = name;
			classPicker.append(option);
		}
		createRemovableFactory(classPicker, find("#class-add"), find("#class-add-missing"), find("#class-clear"), classList);
		//
		Renderer.init();
		//
		var shareButton:InputElement = find("#share");
		var shareButtonText = shareButton.value;
		shareButton.onclick = e -> {
			var args = [];
			if (modeStr != "pf2e") args.push(modeStr);
			function print(div:Element) {
				var buttons = div.querySelectorAll(".button");
				var ids = [for (button in buttons) (cast button:Element).dataset.id];
				return ids.join("~");
			}
			args.push("classes=" + print(classList));
			args.push("profs=" + print(profList));
			var base:String;
			if (document.location.protocol == "file:") {
				base = "https://yal.cc/game-tools/pf2e/prof/";
			} else {
				base = Browser.location.origin + Browser.location.pathname;
			}
			var snip = base + "?" + args.join("&");
			//
			var revertTimeout:Null<Int> = null;
			function blink() {
				if (revertTimeout != null) Browser.window.clearTimeout(revertTimeout);
				shareButton.value = "copied!";
				revertTimeout = Browser.window.setTimeout(() -> {
					shareButton.value = shareButtonText;
				}, 1300);
			}
			function fallback() {
				Browser.window.prompt('Here\'s your share URL:', snip);
			}
			try {
				Browser.navigator.clipboard.writeText(snip).then((_) -> {
					blink();
				}).catchError((x) -> {
					Console.error("Failed to copy:", x);
					fallback();
				});
			} catch (x:Dynamic) {
				Console.error("Failed to copy:", x);
				fallback();
			}
		};
		// demo
		Renderer.canRender = false;
		if (search.has("classes")) {
			for (id in search.get("classes").split("~")) {
				var cl = classData.find(c -> c.id == id);
				if (cl != null) addRemovable(classList, cl.name);
			}
		} else {
			for (cl in classData) {
				addRemovable(classList, cl.name);
			}
		}
		if (search.has("profs")) {
			for (id in search.get("profs").split("~")) {
				var prof = profData.find(p -> p.id == id);
				if (prof != null) addRemovable(profList, prof.name);
			}
		} else {
			for (prof in profData) if (!prof.opt) {
				addRemovable(profList, prof.name);
			}
		}
		Renderer.canRender = true;
		Renderer.run();
	}
}