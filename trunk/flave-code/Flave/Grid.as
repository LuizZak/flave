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
	import flash.display.*;
	
	import Flave.*;
	import Flave.Util.*;
	
	// Allows support for small broad-phase collision
	// detection/resolving
	public class Grid {
		// The grid itself:
		public var grid:Array = [];
		
		// Keep track of collision pairs (doesn't work, right now):
		public var colls:Array = [[null][null]];
		
		// The grid resolution (The larger, the greated the
		// ammount of cells. Can somewhat speed things up a
		// bit, but might slow down if incorrectly used).
		public var resolution:int = 0;
		
		// The grid subdivision
		public var subdiv:int = 0;
		
		public var drawGrid:Boolean = false;
		
		public var MCMov:Sprite;
		
		var tolerance:Number = parseFloat("1.0E-8f");
		
		public function Grid() {
			setGrid(10);
		}
		
		// Starts the broad phase grid to a new clear grid
		// @param subdivision The grid subdivisions
		public function setGrid(subdivision:int) : void {
			// ALWAYS assume the simulation is 1000-sized.
			resolution = Math.ceil(550/subdivision);
			subdiv = subdivision;
			
			grid = new Array(subdivision);
			colls = [[null][null]];
			
			for(var i:int = 0;i<subdivision;i++){
				grid[i] = new Array(subdivision);
				for(var j:int = 0;j<subdivision;j++){
					grid[i][j] = new Array();
				}
			}
		}
		
		// Resets the broad phase grid to a new clear grid
		// @param subdivision The grid subdivisions
		public function resetGrid(subdivision:int) : void {
			resolution = Math.ceil(1000/subdivision);
			subdiv = subdivision;
			
			//grid = new Array(subdivision);
			colls = [[null][null]];
		}
		
		// Adds a new particle to the broad phase collision checking
		// @param part the particle to be added
		public function addParticle(part:Particle) : void {
			var x:Number = toGrid(int(part.X), resolution);
			var y:Number = toGrid(int(part.Y), resolution);
			var l:Number = toGrid(int(part.X-part.rad*2), resolution);
			var r:Number = toGrid(int(part.X+part.rad*2), resolution);
			var t:Number = toGrid(int(part.Y-part.rad*2), resolution);
			var b:Number = toGrid(int(part.Y+part.rad*2), resolution);
			
			// Check for the particle range:
			if(ior([x, y])) return;
			
			// Push it:
			grid[x/resolution][y/resolution].push(part);
			
			// Push also the extremities:
			// Now it ckecks the 8, instead of only 4:
			if(x/resolution != l/resolution && !ior(l)) grid[l/resolution][y/resolution].push(part);
			if(x/resolution != r/resolution && !ior(r)) grid[r/resolution][y/resolution].push(part);
			if(y/resolution != t/resolution && !ior(t)) grid[x/resolution][t/resolution].push(part);
			if(y/resolution != b/resolution && !ior(b)) grid[x/resolution][b/resolution].push(part);
			
			
			/*if(x/resolution != l/resolution && !ior(l)
   			&& y/resolution != t/resolution && !ior(t)) grid[l/resolution][t/resolution].push(part);
			
			if(x/resolution != l/resolution && !ior(l)
			&& y/resolution != b/resolution && !ior(b)) grid[l/resolution][b/resolution].push(part);
			
			if(x/resolution != r/resolution && !ior(r)
			&& y/resolution != t/resolution && !ior(t)) grid[r/resolution][t/resolution].push(part);
			
			if(x/resolution != r/resolution && !ior(r)
			&& y/resolution != b/resolution && !ior(b)) grid[r/resolution][b/resolution].push(part);*/
		}
		
		// Adds a constraint to the broad phase collision checking
		// @param c the contraint to add to the broad phase
		public function addConstraint(c:Constraint) : void {
			var vx:Number, vy:Number, incx:Number, incy:Number;
			
			var gridA:Number = resolution;
			
			var bax:Number = c.p1.X / gridA;
			var bay:Number = c.p1.Y / gridA;
			var bbx:Number = c.p2.X / gridA;
			var bby:Number = c.p2.Y / gridA;
			
			if(bax < bbx) {
				var tx:Number = bax;
				bax = bbx;
				bbx = tx;
				
				var ty:Number = bay;
				bay = bby;
				bby = ty;
			}
			
			vx = bbx - bax;
			vy = bby - bay;
			
			var scale:Number = 1;
			
			incx = ((vx < 0 ? -vx : vx) < tolerance) ? 1.0 / tolerance : 1.0 / (vx < 0 ? -vx : vx);
			incy = ((vy < 0 ? -vy : vy) < tolerance) ? 1.0 / tolerance : 1.0 / (vy < 0 ? -vy : vy);
			
			incx *= scale;
			incy *= scale;
			
			var x:Number = int(bax);
			var y:Number = int(bay);
			
			var dx:Number = (vx < 0.0) ? -1 : (vx > 0.0) ? 1 : 0;
			var dy:Number = (vy < 0.0) ? -1 : (vy > 0.0) ? 1 : 0;
			
			dx *= scale;
			dy *= scale;
			
			var accumx:Number = (vx < 0.0) ? (bax - x) * incx : ((x+1*scale) - bay) * incx;
			var accumy:Number = (vy < 0.0) ? (bay - y) * incy : ((y+1*scale) - bay) * incy;
			
			accumx *= scale;
			accumy *= scale;
			
			var t:Number = 0.0;
			
			while (t <= 1.0)
			{
				if(!ior(x) && !ior(y)) {
					if(grid[x] != undefined && grid[x][y] != undefined &&
						  grid[x][y].indexOf(c) == -1)
						grid[x][y].push(c);
				}
				
				if(accumx < accumy)
				{
					t	 	= accumx;
					accumx += incx;
					x	   += dx;
				}
				else
				{
					t		= accumy;
					accumy += incy;
					y	   += dy;
				}
			}
		}
		
		// Adds a ray to the broad phase collision checking
		// @param c the ray to add to the broad phase
		// Yep, this is a shame copy of the addConstraint() function
		public function addRay(c:Ray) : void {
			var vx:Number, vy:Number, incx:Number, incy:Number;
			
			var gridA:Number = resolution;
			
			var bax:Number = c.sx / gridA;
			var bay:Number = c.sy / gridA;
			var bbx:Number = c.ex / gridA;
			var bby:Number = c.ey / gridA;
			
			if(bax < bbx) {
				var tx:Number = bax;
				bax = bbx;
				bbx = tx;
				
				var ty:Number = bay;
				bay = bby;
				bby = ty;
			}
			
			vx = bbx - bax;
			vy = bby - bay;
			
			var scale:Number = 1;
			
			incx = ((vx < 0 ? -vx : vx) < tolerance) ? 1.0 / tolerance : 1.0 / (vx < 0 ? -vx : vx);
			incy = ((vy < 0 ? -vy : vy) < tolerance) ? 1.0 / tolerance : 1.0 / (vy < 0 ? -vy : vy);
			
			/*incx = (Math.abs(vx) < tolerance) ? 1.0 / tolerance : 1.0 / Math.abs(vx);
			incy = (Math.abs(vy) < tolerance) ? 1.0 / tolerance : 1.0 / Math.abs(vy);*/
			
			incx *= scale;
			incy *= scale;
			
			var x:Number = int(bax);
			var y:Number = int(bay);
			
			var dx:Number = (vx < 0.0) ? -1 : (vx > 0.0) ? 1 : 0;
			var dy:Number = (vy < 0.0) ? -1 : (vy > 0.0) ? 1 : 0;
			
			dx *= scale;
			dy *= scale;
			
			var accumx:Number = (vx < 0.0) ? (bax - x) * incx : ((x+1*scale) - bay) * incx;
			var accumy:Number = (vy < 0.0) ? (bay - y) * incy : ((y+1*scale) - bay) * incy;
			
			accumx *= scale;
			accumy *= scale;
			
			var t:Number = 0.0;
			
			while (t <= 1.0)
			{
				if(!ior(x) && !ior(y)) {
					if(grid[x] != undefined && grid[x][y] != undefined &&
						  grid[x][y].indexOf(c) == -1 && grid[x][y].length > 0)
						grid[x][y].push(c);
				}
				
				if(accumx < accumy)
				{
					t	 	= accumx;
					accumx += incx;
					x	   += dx;
				}
				else
				{
					t		= accumy;
					accumy += incy;
					y	   += dy;
				}
			}
		}
		
		// Returns if a value is out of the Broad-Phase range
		// @param x the value to check the range validity
		public function ior(x:*) : Boolean {
			if(x is Number){
				if(x / resolution > grid.length - 1) return true;
				if(x / resolution < 0) return true;
			}if(x is Array){
				for(var i:int = 0; i < x.length; i++){
					if(ior(x[i])) return true;
				}
			}
			return false;
		}
		
		// Resolves the broad-phase collisions
		public function resolveBroadPhase() : void {
			if(drawGrid)
				MCMov.graphics.clear();
			
			if(drawGrid) {
				// MCMov.graphics.lineStyle(1, 0x000000, 1.0);
			}
			
			for(var x:int = 0; x < grid.length; x++){
				for(var y:int = 0; y < grid[x].length; y++){
					var a:*, b:*;
					for(var i:int = 0; i < grid[x][y].length; i++){
						if(grid[x][y][i] is Ray) break;
						
						for(var j:int = i + 1; j < grid[x][y].length; j++){
							a = grid[x][y][i];
							b = grid[x][y][j];
							
							// Particle-Particle
							if(a is Particle &&
							   b is Particle){
								CollisionResolver.resolveParticle(a, b);
							}
							
							// Particle-Constraint
							if(a is Particle &&
							   b is Constraint){
								CollisionResolver.resolveCircleConstraint(a, b);
							}
							
							// Particle-Ray
							if(a is Particle &&
							   b is Ray){
								CollisionResolver.rayOnParticle(a, b);
							}
							
							// Constraitn-Ray
							if(a is Constraint &&
							   b is Ray){
								CollisionResolver.rayOnConstraint(a, b);
							}
						}
					}
					
					if(drawGrid){
						if(grid[x][y].length == 0) {
							MCMov.graphics.lineStyle(1, 0x000000, 1.0);
						} else MCMov.graphics.lineStyle(1, 0xFF0000, 1.0);
						
						MCMov.graphics.moveTo(x * resolution+1, y * resolution+1);
						MCMov.graphics.lineTo(x * (resolution)+resolution-1, y * resolution+1);
						MCMov.graphics.lineTo(x * (resolution)+resolution-1, y * (resolution)+resolution-1);
						MCMov.graphics.lineTo(x * resolution+1, y * (resolution)+resolution-1);
						MCMov.graphics.lineTo(x * resolution+1, y * resolution+1);
					}
					
					// Reset this cell
					grid[x][y] = [];
				}
			}
		}
		
		// Clamps a value into a grid with range
		// seted by te user
		public function toGrid(gx:Number, grid:Number) : Number {
			return int(gx/grid)*grid;
		}
		
		// Returns the number of particles found on the cell given by
		// the X and Y coordinates
		public function partsOnCell(cellX:int, cellY:int) : uint {
			var parts:int = 0;
			
			for(var i:int = 0;i<grid[cellX][cellY].length;i++){
				if(grid[cellX][cellY][i] is Particle){
					parts ++;
				}
			}
			
			return parts;
		}
		
		// Returns the number of constraints found on the cell given by
		// the X and Y coordinates
		public function consOnCell(cellX:int, cellY:int) : uint {
			var cons:int = 0;
			
			for(var i:int = 0;i<grid[cellX][cellY].length;i++){
				if(grid[cellX][cellY][i] is Constraint){
					cons ++;
				}
			}
			
			return cons;
		}
	}
}