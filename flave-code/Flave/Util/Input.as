/*
Flave v0.6b Copyright (c) 2010 Luiz Fernando

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/

package Flave.Util {
	import flash.events.KeyboardEvent;
	import flash.events.FocusEvent;
	
	public class Input {
		private var press_left = false;
		private var press_right = false;
		private var press_up = false;
		private var press_down = false;
		private var press_space = false;
		
		public var Keys:Array = new Array(150);
		
		public static var keysDown:Array = new Array(150);
		
		public static var calls:Array = new Array();
		
		public function Input(movieclip) {
			movieclip.stage.addEventListener(KeyboardEvent.KEY_DOWN, key_down, false, 0);
			movieclip.stage.addEventListener(KeyboardEvent.KEY_UP, key_up, false, 1);
		}
		
		public function focus(e:FocusEvent){
			for(var i:int = 0;i<Keys.length;i++){
				Keys[i] = false;
			}
			
			press_left = false;
			press_right = false;
			press_up = false;
			press_down = false;
			press_space = false;
		}
		
		public function is_left() {
			return press_left;
		}
		
		public function is_right() {
			return press_right;
		}
		
		public function is_up() {
			return press_up;
		}
		
		public function is_down() {
			return press_down;
		}
		
		public function is_space() {
			return press_space;
		}
		
		public function isDown(key:int){
			return Keys[key];
		}
		
		private function key_down(event:KeyboardEvent) {
			for(var i=0;i<calls.length;i++){
				calls[i](event);
			}
			
			Keys[event.keyCode] = true;
			
			Input.keysDown[event.keyCode] = true;
			
			if (event.keyCode == 32) {
				press_space = true;
			}
			if (event.keyCode == 37 || event.keyCode == 65) {
				press_left = true;
			}
			if (event.keyCode == 38 || event.keyCode == 87) {
				press_up = true;
			}
			if (event.keyCode == 39 || event.keyCode == 68) {
				press_right = true;
			}
			if (event.keyCode == 40 || event.keyCode == 83) {
				press_down = true;
			}
		}
		
		private function key_up(event:KeyboardEvent) {
			
			Keys[event.keyCode] = false;
			
			Input.keysDown[event.keyCode] = false;
			
			if (event.keyCode == 32) {
				press_space = false;
			}
			if (event.keyCode == 37 || event.keyCode == 65) {
				press_left = false;
			}
			if (event.keyCode == 38 || event.keyCode == 87) {
				press_up = false;
			}
			if (event.keyCode == 39 || event.keyCode == 68) {
				press_right = false;
			}
			if (event.keyCode == 40 || event.keyCode == 83) {
				press_down = false;
			}
		}
		
		public static function addCallback(callback:Function) : void {
			calls.push(callback);
		}
		
		public static function removeCallback(callback:Function) : void {
			var cInt:uint = calls.indexOf(callback);
			
			if(cInt == -1) return;
			
			calls[cInt] = null;
			calls.splice(cInt, 1);
		}
	}
}