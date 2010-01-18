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
	// Vector2 class
	public class Vector2 {

		public var x:Number;
		public var y:Number;
		
		public function get X() : Number{
			return x;
		}
		
		public function get Y() : Number{
			return y;
		}

		public function Vector2(px:Number=0,py:Number=0) {
			x=px;
			y=py;
		}
		
		public function setTo(px:Number,py:Number):void {
			x=px;
			y=py;
		}
		
		public function copy(v:Vector2):void {
			x=v.x;
			y=v.y;
		}
		
		public function dot(v:Vector2):Number {
			return x * v.x + y * v.y;
		}
		
		public function cross(v:Vector2):Number {
			return x * v.y - y * v.x;
		}
		
		public function plus(v:Vector2):Vector2 {
			return new Vector2(x + v.x,y + v.y);
		}
		
		public function plusEquals(v:Vector2):Vector2 {
			x+= v.x;
			y+= v.y;
			return this;
		}
		
		public function minus(v:Vector2):Vector2 {
			return new Vector2(x - v.x,y - v.y);
		}
		
		public function minusEquals(v:Vector2):Vector2 {
			x-= v.x;
			y-= v.y;
			return this;
		}
		
		public function mult(s:Number):Vector2 {
			return new Vector2(x * s,y * s);
		}
		
		public function multEquals(s:Number):Vector2 {
			x *= s;
			y *= s;
			return this;
		}
		
		public function times(v:Vector2):Vector2 {
			return new Vector2(x * v.x,y * v.y);
		}
		
		public function divEquals(s:Number):Vector2 {
			if (s == 0) {
				s = 0.0001;
			}
			x/= s;
			y/= s;
			return this;
		}
		
		public function magnitude() : Number {
			return Math.sqrt(x * x + y * y);
		}
		
		public function length() : Number {
			return (x * x) + (y * y);
		}
		
		public function distance(v:Vector2) : Number {
			var delta:Vector2 = this.minus(v);
			return delta.magnitude();
		}
		
		public function getDifference(v:Vector2) : Vector2 {
			return new Vector2(v.x - x, v.y - y);
		}
		
		public function normalize() : Vector2 {
			var m:Number = magnitude();
			if (m == 0) {
				m = 0.0001;
			}
			return mult(1 / m);
		}
		
		public function negate() : Vector2 {
			x *= -1;
			y *= -1;
			return this;
		}
		
		public function toString() : String {
			return (x + " : " + y);
		}
	}
}