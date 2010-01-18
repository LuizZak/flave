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
	
	// Implements a Ray, which is a beam that
	// can be blocked (or reflected?) by objects
	public class Ray extends Sprite {
		// Start points:
		public var sx:Number, sy:Number;
		// End points:
		public var ex:Number, ey:Number;
		// The beam's Direction:
		public var Direction:Number = 0;
		// The beam's Range:
		public var Range:Number;
		// The beam's color:
		public var Color:uint = 0xFF00000;
		// The ray's caster It can be a particle in which the ray
		// will remain fixed (see below)
		public var Caster:* = null;
		// Wheter to update the starting and ending points to match caster
		// movements:
		public var fixOnCaster = false;
		
		// Returns the last hitten object:
		public var lastHit:* = null;
		
		// User defined data
		public var userDef:*;
		
		// Constructor:
		public function Ray() {
			this.mouseEnabled = false;
			this.mouseChildren = false;
		}
		
		// Updates the beam stream:
		public function updateBeam(startX:Number, startY:Number, dir:Number, range:Number) : void {
			sx = startX;
			sy = startY;
			
			Direction = dir;
			
			Range = range;
			
			// Calculate end points:
			ex = sx + Math.cos(Direction * (Math.PI / 180)) * Range;
			ey = sy + Math.sin(Direction * (Math.PI / 180)) * Range;
			
			lastHit = null;
		}
		
		// Redraws the beam:
		public function redraw() : void {
			this.graphics.clear();
			this.graphics.lineStyle(1, Color, 1);
			this.graphics.beginFill(0xFF0000);
			this.graphics.drawCircle(ex, ey, 2);
			this.graphics.endFill();
			
			this.graphics.moveTo(sx, sy);
			this.graphics.lineTo(ex, ey);
		}
		
		// Trims the ray into the given range:
		public function trim(minX, minY, maxX, maxY) : void {
			// Test each line of the boundary:
			if(CollisionResolver.checkLinesP(sx, sy, ex, ey, minX, minY, maxX, minY)[0]){
				var res = CollisionResolver.checkLinesP(sx, sy, ex, ey, minX, minY, maxX, minY)[1];
				ex = res.x;
				ey = res.y;
			}
			
			if(CollisionResolver.checkLinesP(sx, sy, ex, ey, minX, minY, minX, maxY)[0]){
				res = CollisionResolver.checkLinesP(sx, sy, ex, ey, minX, minY, minX, maxY)[1];
				ex = res.x;
				ey = res.y;
			}
			
			if(CollisionResolver.checkLinesP(sx, sy, ex, ey, minX, maxY, maxX, maxY)[0]){
				res = CollisionResolver.checkLinesP(sx, sy, ex, ey, minX, maxY, maxX, maxY)[1];
				ex = res.x;
				ey = res.y;
			}
			
			if(CollisionResolver.checkLinesP(sx, sy, ex, ey, maxX, minY, maxX, maxY)[0]){
				res = CollisionResolver.checkLinesP(sx, sy, ex, ey, maxX, minY, maxX, maxY)[1];
				ex = res.x;
				ey = res.y;
			}
			
			/*sx = Math.max(minX, Math.min(sx, maxX));
			sy = Math.max(minY, Math.min(sy, maxY));
			ex = Math.max(minX, Math.min(ex, maxX));
			ey = Math.max(minY, Math.min(ey, maxY));*/
		}
	}
}