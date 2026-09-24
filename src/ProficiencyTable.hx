import js.html.Console;
import js.html.URLSearchParams;
import js.html.InputElement;
import js.Browser;
import js.Browser.document;
import ProficiencyData;
using tools.ArrayTools;

class ProficiencyTable {
	public static var classes = new TagBlockSet(find("#classes"));
	public static var proficiencies = new TagBlockSet(find("#proficiencies"));
	//
	public static function main() {
		ProficiencyType.init();
		for (pt in ProficiencyType.list) {
			var option = document.createOptionElement();
			option.text = pt.name;
			proficiencies.select.append(option);
		}
		//
		var modeStr:String = "pf2e";
		var search = new URLSearchParams(document.location.search);
		{
			var classData = [];
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
			ProficiencyData.list = classData;
		}
		for (cl in ProficiencyData.list) {
			cl.id = makeID(cl.name);
		}
		//
		var sortedClassNames = ProficiencyData.list.map(c -> c.name);
		sortedClassNames.sort((a, b) -> (a < b ? -1 : 1));
		for (name in sortedClassNames) {
			var option = document.createOptionElement();
			option.text = name;
			classes.select.append(option);
		}
		//
		Renderer.init();
		//
		var shareButton:InputElement = find("#share");
		var shareButtonText = shareButton.value;
		shareButton.onclick = e -> {
			var args = [];
			if (modeStr != "pf2e") args.push(modeStr);
			function print(set:TagBlockSet) {
				return [for (block in set.blocks) block.dataset.id].join("~");
			}
			args.push("classes=" + print(classes));
			args.push("profs=" + print(proficiencies));
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
				var cl = ProficiencyData.list.find(c -> c.id == id);
				if (cl != null) classes.add(cl.name);
			}
		} else {
			for (cl in ProficiencyData.list) {
				classes.add(cl.name);
			}
		}
		if (search.has("profs")) {
			for (id in search.get("profs").split("~")) {
				var prof = ProficiencyType.list.find(p -> p.id == id);
				if (prof != null) proficiencies.add(prof.name);
			}
		} else {
			for (prof in ProficiencyType.list) if (prof.onByDefault) {
				proficiencies.add(prof.name);
			}
		}
		Renderer.canRender = true;
		Renderer.run();
	}
}