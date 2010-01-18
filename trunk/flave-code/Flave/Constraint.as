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
	
	// Constraint clss definition:
	public class Constraint extends Sprite {
		// First particle, second particle, restlen and error:
		public var p1:Particle, p2:Particle, dis:Number, error:Number;
		
		// Whether this constraint is collidable:
		public var collidable:Boolean = true;
		
		// Stiffness and damping:
		public var stiff:Number = 1; // [0-1]
		public var damp:Number  = 1; // [0-1]
		
		// Rupture tolerance. If the difference between the delta
		// and the rest length is larger than the rupture point,
		// the constraint breaks.
		public var rupturePoint:Number = 0.02 * 1000;
		
		// The delta distance between the particles
		public var diff:Number = 0;
		
		// User defined data
		public var userDef:*;
		
		public function Constraint(_p1:Particle, _p2:Particle, _dis:Number = -1, collide:Boolean = true){
			p1 = _p1; if(p1.constraints.indexOf(this) == -1) p1.constraints.push(this);
			p2 = _p2; if(p2.constraints.indexOf(this) == -1) p2.constraints.push(this);
			
			dis = _dis == -1 ? Math.sqrt((p1.X - p2.X)*(p1.X - p2.X) + (p1.Y - p2.Y)*(p1.Y - p2.Y))
							   : _dis;
			
			collidable = collide;
		}
		
		public function resolve() : void {
			if((p1.fixed || p1.drag) && (p2.fixed || p2.drag)) return;
			
			var vx:Number = p1.X - p2.X;
			var vy:Number = p1.Y - p2.Y;
			
			var vlen:Number = Math.sqrt(vx * vx + vy * vy);
			
			diff = (dis - vlen) / vlen;
			
			var dx:Number = (vx * diff) * stiff;
			var dy:Number = (vy * diff) * stiff;
			
			var mw:Number = 1 / (p1.iMass + p2.iMass);
			
			if(!p1.fixed && !p1.drag){
				p1.X += dx * (p1.iMass * mw) * stiff;
				p1.Y += dy * (p1.iMass * mw) * stiff;
			}
			
			if(!p2.fixed && !p2.drag){
				p2.X -= dx * (p2.iMass * mw) * stiff;
				p2.Y -= dy * (p2.iMass * mw) * stiff;
			}
		}
		
		// Check for rupturint:
		public function rupture() : void {
			if((diff < 0 ? -diff : diff) > rupturePoint){
				parent['removeConstraint'](this);
			}
		}
		
		public function draw() : void {
			var rp:Number = diff / rupturePoint;
			rp = (rp < 0 ? -rp : rp);
			var r:Number = rp * 0xFF;
			var g:Number = 0x00;
			var b:Number = 0x00;

			this.graphics.clear();
			this.graphics.lineStyle(1, (r << 16) | (g << 8) | (b), (rp / 2) + (collidable ? 0.5 : 0.2));
			this.graphics.moveTo(p1.X, p1.Y);
			this.graphics.lineTo(p2.X, p2.Y);
		}
		
		public function getLen() : Number {
			return Math.sqrt((p1.X - p2.X)*(p1.X - p2.X) + (p1.Y - p2.Y)*(p1.Y - p2.Y));
		}
	}
}