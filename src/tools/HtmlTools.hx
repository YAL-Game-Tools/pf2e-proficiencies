package tools;

import js.html.Document;
import haxe.extern.EitherType;
import js.html.Element;
import js.Browser.document;
import js.Browser.window;

class HtmlTools {
	@:noUsing public static function find<T:Element>(selector:String, ?c:Class<T>):T {
		return cast document.querySelector(selector);
	}
	
	private static inline function asElement(el:EitherType<Document, Element>):Element {
		return cast el;
	}
	
	public static inline function querySelectorEls(el:EitherType<Document, Element>, selectors:String):ElementList {
		return cast asElement(el).querySelectorAll(selectors);
	}
	public static inline function querySelectorAllAuto<T:Element>(el:EitherType<Document, Element>, selectors:String, ?c:Class<T>):ElementListOf<T> {
		return cast asElement(el).querySelectorAll(selectors);
	}
	public static inline function querySelectorAuto<T:Element>(
		el:EitherType<Document, Element>, selectors:String, ?c:Class<T>
	):T {
		return cast asElement(el).querySelector(selectors);
	}
}
extern class ElementList implements ArrayAccess<Element> {
	public var length(default, never):Int;
	public function item(index:Int):Element;
}
extern class ElementListOf<T:Element> implements ArrayAccess<T> {
	public var length(default, never):Int;
	public function item(index:Int):T;
}