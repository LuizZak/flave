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

package Flave {
	// Import needed classes:
	import flash.display.Sprite;
	
	import Flave.Util.*;
	
	// Class definition for the Polygon
	public class Polygon extends Sprite {
		// The spots to draw a polygon around
		public var spots:Array = new Array();
		
		// The color used to draw the polygon
		public var color:uint = 0x000000;
		
		// User defined data
		public var userDef:*;
		
		// Polygon constructor
		public function Polygon(_spots:Array,
								_color:uint=0,
								_alpha:Number=0.5){
			spots = _spots;
			
			this.addEventListener("enterFrame", loop, false, 0, true);
			this.addEventListener("mouseOver", over, false, 0, true);
			this.addEventListener("mouseOut", out, false, 0, true);
			this.addEventListener("click", click, false, 0, true);
			
			color = _color;
			alpha = _alpha;
		}
		
		// Clears the garbage that can block the garbage collector
		// from collecting this object:
		public function clearGarbage() : void {
			spots.splice(0, spots.length);
			spots = null;
			
			this.removeEventListener("enterFrame", loop, false);
		}
		
		public function loop(e:*) : void {
			redraw();
		}
		
		public function over(e:*) : void {
			
		}
		
		public function out(e:*) : void {
			
		}
		
		public function click(e:*) : void {
			
		}
		
		public function redraw() : void {
			if(this.spots.length < 2)
				return;
			
			this.graphics.clear();
			this.graphics.lineStyle(0, 0, 1);
			this.graphics.beginFill(color);
			this.graphics.moveTo(spots[0].X, spots[0].Y);
			
			for(var i:int = 0; i < spots.length; i++){
				if(spots[i].callBack() != true) {
					parent["removePoly"](this);
					return;
				}
				this.graphics.lineTo(spots[i].X, spots[i].Y);
			}
			
			this.graphics.lineTo(spots[0].X, spots[0].Y);
			
			this.graphics.endFill();
		}
		
		public function drawSel() : void {
			if(this.spots.length < 2)
				return;
			
			this.graphics.lineStyle(0, 0, 1);
			this.graphics.beginFill(Input.keysDown[17] ? 0xff0000 : 0xffff00, 0.75);
			this.graphics.moveTo(spots[0].X, spots[0].Y);
			
			for(var i:int = 0; i < spots.length; i++){
				if(spots[i].callBack() != true) {
					parent["removePoly"](this);
					return;
				}
				this.graphics.lineTo(spots[i].X, spots[i].Y);
			}
			
			this.graphics.lineTo(spots[0].X, spots[0].Y);
			
			this.graphics.endFill();
		}
		
		public function genString() : String {
			var out:String = "n," + color + ",";
			
			for(var i:int = 0; i < spots.length; i++){
				out += spots[i]._handler + (i == spots.length-1 ? "" : ",");
			}
			
			return "|" + out;
		}
	}
}