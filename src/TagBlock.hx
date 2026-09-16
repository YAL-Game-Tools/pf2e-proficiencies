import js.html.DragEvent;
import js.html.Element;

@:forward
abstract TagBlock(Element) to Element {
	public function new(target:TagBlockSet, text:String) {
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
		this = button;
	}
}