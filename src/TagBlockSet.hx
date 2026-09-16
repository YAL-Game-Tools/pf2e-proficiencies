import js.html.SelectElement;
import js.html.InputElement;
import js.html.Element;

class TagBlockSet {
	public var outer(default, null):Element;
	
	public var select(default, null):SelectElement;
	public var blockHolder(default, null):Element;
	
	public var id(get, never):String;
	inline function get_id() return outer.id;
	
	public var blocks(get, never):ElementListOf<TagBlock>;
	inline function get_blocks() return blockHolder.querySelectorAllAuto(".button");
	
	public function getLabels() {
		return [for (block in blocks) block.innerText];
	}
	
	public function new(outer:Element) {
		this.outer = outer;
		select = outer.querySelectorAuto("select");
		blockHolder = outer.querySelector(".filter-buttons");
		//
		var buttons = outer.querySelectorAllAuto('input[type="button"]', InputElement);
		buttons[0].onclick = e -> {
			var snip = select.value;
			if (snip != "" && snip != null) add(snip);
		};
		buttons[1].onclick = e -> {
			addMissing();
		}
		buttons[2].onclick = e -> {
			blockHolder.innerHTML = "";
			Renderer.run();
		}
	}
	public function add(text:String, canRender = true) {
		var block = new TagBlock(this, text);
		blockHolder.append(block);
		if (canRender) Renderer.run();
	}
	public function addMissing() {
		var added = false;
		var names = [for (e in blocks) e.innerText];
		for (i in 0 ... select.options.length) {
			var text = select.options[i].innerText;
			if (!names.contains(text)) {
				add(text, false);
				added = true;
			}
		}
		if (added) Renderer.run();
	}
}