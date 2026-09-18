package tools;

import js.lib.RegExp;
import js.html.Document;
import haxe.extern.EitherType;
import js.html.Element;
import js.Browser.document;
import js.Browser.window;

class HtmlTools {
	@:noUsing public static function makeID(text:String) {
		var id = text;
		id = (cast id).replaceAll(new RegExp("[^\\w+ ]", "g"), "");
		id = StringTools.replace(id, " ", "-");
		return id;
	}
	
	public static function capitalize(s:String) {
		return s.charAt(0).toUpperCase() + s.substr(1);
	}
	
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
	
	public static function appendSimple(target:Element, tagName:String, ?text:String):Element {
		var element = document.createElement(tagName);
		if (text != null) element.append(text);
		target.append(element);
		return element;
	}
	public static function appendSimpleAs<T:Element>(target:Element, tagName:String, ?text:String, ?c:Class<T>):T {
		var element:T = cast document.createElement(tagName);
		if (text != null) element.append(text);
		target.append(element);
		return element;
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