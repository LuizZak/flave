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
	
	// Class definition for the Particle.
	// Particles are small circles and are the
	// primitive type of objects on Flave engine.
	public dynamic class Particle extends Sprite {
		// Define some vars here:
		public var X:Number      = 0,      // X position
				   Y:Number      = 0,      // Y position
				   oldx:Number   = 0,      // Last X position
				   oldy:Number   = 0,      // Last Y position
				   rad:Number    = 10,     // Particle radius
				   mass:Number   = 30,     // Particle mass
				   fixed:Boolean = false,  // If fixed, it won't move
				   index:int     = 0;      // Particle index
		
		// X and Y friction:
		public var xfric:Number = 0.9999, yfric:Number = 0.9999;
		
		// Cheesiest way to do collision pairing (don't work now):
		public var CollisionPair:Array = [];
		
		// If the particle is currently being drag
		public var drag:Boolean = false;
		
		// Temp vars
		public var vx:Number = X;
		public var vy:Number = Y;
		
		// Last connected constraint
		public var lastIndex:int = 0;
		
		// Constraints that this particle is attached to:
		public var constraints:Array = new Array();
		
		// Whether this particle collide with other particles
		// and other constraints:
		public var collideWithPart:Boolean = true
		public var collideWithConstraint:Boolean = true;
		
		// Whether this particle has been drawn already.
		// If so, no need to redraw every frame
		public var drawn:Boolean = false;
		
		// User defined data
		public var userDef:*;
		
		// Particle constructor
		// @param _x X position
		// @param _y Y position
		public function Particle(_x:Number, _y:Number) {
			oldx = X = _x;
			oldy = Y = _y;
			this.cacheAsBitmap = true;
			
			this.addEventListener("mouseDown", click, false, 0, true);
		}
		
		// Init particle logic
		public function init() : void {
			// empty...
		}
		
		// Faster drawing method is win!
		public function draw() : void {
			x = X;
			y = Y;
			
			if(drawn) return;
			if(!drawn) drawn = true;
			
			this.graphics.clear();
			this.graphics.lineStyle(0, collideWithPart ? 0x000000 : 0xAAAAAA, 0.5);
			
			if(!fixed)
				this.graphics.beginFill(0xEEEEEE, 0.5 + iMass/2);
			else
				this.graphics.beginFill(0xAAAAAA, 0.5 + iMass/2);
			
			this.graphics.drawCircle(0, 0, rad);
		}
		
		// Clean the garbage (remove listeners, etc.)
		public function cleanGarbage() : void {
			stage.removeEventListener("mouseMove", move);
			stage.removeEventListener("mouseUp", up);
			this.removeEventListener("mouseDown", click);
		}
		
		// Step:
		public function step() : void {
			// Reset collision pair
			CollisionPair = [];
			
			// Dragging:
			if(drag){
				oldx = X = Input.keysDown[16] ? toGrid(vx, 10) : vx;
				oldy = Y = Input.keysDown[16] ? toGrid(vy, 10) : vy;
				return;
			}
			
			if(fixed) return; // Don't move if fixed!
			
			// Basic verlet procedure:
			var tx:Number = X, ty:Number = Y;
			
			X += (X - oldx) * xfric;
			Y += (Y - oldy) * yfric;
			
			oldx = tx;
			oldy = ty;
		}
		
		// Happens when the particle is clicked:
		public function click(e:*) : void {
			if(!parent['interactible']) return;
			
			if(Input.keysDown[16]){
				fixed = !fixed;
				return;
			}
			
			drag = true;
			X = vx = root["mouseX"];
			Y = vy = root["mouseY"];
			
			stage.addEventListener("mouseMove", move, false, 0, true);
			stage.addEventListener("mouseUp", up, false, 0, true);
		}
		
		// Happens when the particle is released:
		public function up(e:*) : void {
			drag = false;
			
			stage.removeEventListener("mouseMove", move);
		}
		
		// Happens when the particle is mouse-moved:
		public function move(e:*) : void {
			if(!drag)
				stage.removeEventListener("mouseMove", move);
			
			X = vx = root["mouseX"];
			Y = vy = root["mouseY"];
			
			X = Input.keysDown[16] ? toGrid(vx, 10) : vx;
			Y = Input.keysDown[16] ? toGrid(vy, 10) : vy;
		}
		
		// Returns the inverse mass of the particle (read-only)
		public function get iMass() : Number {
			return 1/mass;
		}
		
		// Returns the total velocity of this particle (read-only)
		public function get velocity() : Vector2 {
			var vx:Number = X - oldx;
			var vy:Number = Y - oldy;
			
			return new Vector2(vx, vy);
		}
		
		// Returns the direction of the particle (read-only)
		public function get direction() : Number {
			var dx:Number = X - oldx;
			var dy:Number = Y - oldy;
			
			return Math.atan2(dy, dx) * (180 / Math.PI);
		}
		
		// Slows down a particle by dividing the speed vectors:
		// @param factor The slowdown factor (1: no change 0: complete stop)
		public function slowDown(factor:Number = 0.5) : void {
			var vx:Number = X - oldx;
			var vy:Number = Y - oldy;
			
			oldx = X - (vx * factor);
			oldy = Y - (vy * factor);
		}
		
		// Accelerates the particle on the givven coordinates:
		// @param vx The x acceleration
		// @param vy The y acceleration
		public function accelerate(vx:Number, vy:Number) : void {
			oldx += vx;
			oldy += vy;
		}
		
		// Gets the next particle connected with a constraint (read-only)
		public function get nextConnected() : Particle {
			return (constraints[lastIndex].p1 == this? constraints[lastIndex].p2 : constraints[lastIndex].p1);
		}
		
		// Snaps a value to a grid
		// @param vari Variable to snap
		// @param grid Grid to snap variable to
		public function toGrid(vari:Number, grid:Number) : Number {
			return int(vari/grid)*grid;
		}
		
		// Callback function used to ensure this instance exists
		public function callBack() : Boolean {
			if(parent == null) return false;
			return true;
		}
	}
}