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

// THIS ACTIONSCRIPT FILE IS PART OF THE FLASH PHYSICS TOY ENGINE (FPE)
//  THIS ACTIONSCRIPT FILE IS PART OF THE FLASH VERLET ENGINE (Flave)
// 
// This is the main script for the world, where everything happens.
// 
// CURRENT VERSION (Engine): 0.6.2b
// CURRENT VERSION  (File) : 1.0


package Flave {
	// Import needed classes:
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.utils.*;
	
	import Flave.Util.*;
	import Flave.*;
	
	// World class. This is the root of the engine
	// and this guy here runs the simulation for you!
	public class World extends Sprite {
		// Really, not used yet.
		public var timeStep:Number = 1.0/50.0;
		
		// Ammount of iterations for constraint solver
		public var consIterations:uint = 2;
		
		// Ammount of iterations for the collision solver
		public var iterations:uint = 2;
		
		// Grid file, the broad-phase that the engine uses
		public var grid:Grid;
		
		// Whether the engine can be interacted with (drag particles
		// around, etc)
		public var interactible:Boolean = true;
		
		// Array of partices, constraints, polygons and raycasters
		public var parts:Array = new Array();
		public var cons:Array = new Array();
		public var polys:Array = new Array();
		public var rays:Array = new Array();
		
		// Default particle size, used when creating particles:
		public var defPartSize:Number = 10;
		
		// Gravity speed
		public var grav:Number = 0.1;
		
		// Clipping bounds used to keep elements inside. Any element
		// exiting the boundaries is quickly sent back inside
		public var clipBounds:Rectangle;
		// Whether to draw the boundaries as a outlined rectangle
		// on the .Draw() function
		public var drawBounds:Boolean = false;
		
		// Offset to which particles will be add. Keep this as
		// (0,0), just in case
		public var offset:Point;
		
		// If the engine is active. If not, no iterations are given
		public var active:Boolean = true;
		
		// Constructor:
		public function World() {
			offset = new Point();
			
			grid = new Grid();
			grid.MCMov = new Sprite();
			addChild(grid.MCMov);
		}
		
		// Step event. Solves particle, constraint and raycast iteration
		// along with the broad-phase grid.
		public function Step() : void {
			// Not active? Skip it!
			if(!active)	return;
			
			// Basic verlet:
			var i:int = 0;
			for each(var p:Particle in parts){
				if(!p.fixed) { // We don't want to move fixed particles
					// Step the particle:
					p.step();
					// Pushes it down:
					p.Y += grav;
					// Clip the particle inside the boundaries:
					clipParticle(p);
				}
				// If it can collide with other particles, add it to the
				// grid:
				if(p.collideWithPart || p.collideWithCons)
					grid.addParticle(p);
			}
			
			// Constraints:
			for(var k:int = 0; k < consIterations; k++){
				for each(var c:Constraint in cons){
					c.resolve();
				}
			}
			// Check for rupturing:
			for each(c in cons){
				c.rupture();
				
				if(c != null && c.collidable)
					grid.addConstraint(c);
			}
			
			// Rays:
			/*for(i=0;i<rays.length;i++){
				rays[i].trim(clipBounds.x, clipBounds.y, clipBounds.width, clipBounds.height);
				if(rays[i].fixOnCaster && rays[i].Caster != null){
					rays[i].updateBeam(rays[i].Caster.X, rays[i].Caster.Y, rays[i].Direction, rays[i].Range);
				} else {
					rays[i].updateBeam(rays[i].sx, rays[i].sy, rays[i].Direction, rays[i].Range);
				}
				// Don't need to add 'em anymore!
				// grid.addRay(rays[i]);
			}*/
			
			// Resolve the broadphase:
			// var t = getTimer();
			if(Configuration.PartPart){
				for(i=0;i<iterations;i++)
					grid.resolveBroadPhase();
			}
			// Resolve the ray-trace:
			for(i=0;i<rays.length;i++){
				rays[i].trim(clipBounds.x, clipBounds.y, clipBounds.width, clipBounds.height);
				if(rays[i].fixOnCaster && rays[i].Caster != null){
					rays[i].updateBeam(rays[i].Caster.X, rays[i].Caster.Y, rays[i].Direction, rays[i].Range);
				} else {
					rays[i].updateBeam(rays[i].sx, rays[i].sy, rays[i].Direction, rays[i].Range);
				}
				// Don't need to add 'em anymore!
				grid.testRay(rays[i]);
			}
			// trace("Resolve time: " + (getTimer() - t));
			
			// Reset the grid:
			grid.resetGrid(grid.subdiv);
			
			// Bound clip:
			if(clipBounds != null)
				for(i = 0; i<parts.length; i++){
					clipParticle(parts[i]);
				}
		}
		
		// Drawing function. Draws the particles, constraints, boundaries
		// rays, etc.
		public function Draw() : void {
			// Not active? Skip it!
			if(!active) return;
			
			// Constraints:
			for(var i:int = 0; i < cons.length; i++){
				cons[i].draw();
			}
			
			// Particles:
			for(i = 0; i<parts.length; i++){
				parts[i].draw();
			}
			
			// Rays:
			for(i = 0; i<rays.length; i++){
				rays[i].trim(clipBounds.x, clipBounds.y, clipBounds.width, clipBounds.height);
				rays[i].redraw();
			}
			
			// Boundaries:
			if(drawBounds){
				this.graphics.clear();
				this.graphics.lineStyle(1, 0, 0.5);
				this.graphics.drawRect(clipBounds.x, clipBounds.y, clipBounds.width, clipBounds.height);
			}
		}
		
		// Adds a particle to the simulation
		// @param _x The X position to add the particle at
		// @param _y The Y position to add the particle at
		// @param fixed Whether the particle will remain fixed in place
		// @param rad The particle radius
		public function addParticle(_x:Number, _y:Number, fixed:Boolean = false, rad:Number = -1) : Particle {
			// Create the particle instance:
			var p:Particle = new Particle(_x + offset.x, _y + offset.y);
			
			// Set the variables:
			p.fixed = fixed;
			p.index = parts.length;
			p.rad = (rad == -1 ? defPartSize : rad);
			
			// Push it into the particle list:
			parts.push(p);
			
			// Add the displayable object to the world:
			addChild(p);
			
			// Init the logic after adding it to the display list:
			p.init();
			
			// Return the particle created:
			return p;
		}
		
		// Add a constraint to the simulation:
		// @param p1 The first particle to link
		// @param p2 The second particle to link
		// @param dis The restlen. Distance that the resolver will try to keep the particles at.
		// @param e The error delta. Should be keep at 0.5.
		// @param coll Whether this constraint can collide with other particles and rays.
		public function addConstraint(p1:Particle, p2:Particle, dis:Number = -1, e:Number = 0.5, coll:Boolean = true) : Constraint {
			// Create the constraint, setting the particles and restLen:
			var c:Constraint = new Constraint(p1, p2, dis);
			
			// Set the error and collision flag:
			c.error = e;
			c.collidable = coll;
			
			// Pushes it into the constraints list:
			cons.push(c);
			
			// Add it to the display list, at the bottom:
			addChildAt(c, 0);
			
			// Return the constraint created:
			return c;
		}
		
		// Adds a polygon. A polygon is just cosmetic. It links particles with a cool
		// polygon shape. They have no influence on the simulation whatsoever.
		// @param spots The list of particles to link
		// @param col The color used to draw
		// @param _a The alpha used to draw
		public function addPoly(spots:Array, col:uint=0, _a:Number=1) : Polygon {
			// Creates and pushes the polygon to the polygon list:
			polys.push(new Polygon(spots, col, _a));
			
			// Adds it to the display list, at the bottom:
			this.addChildAt(polys[polys.length-1], cons.length);
			
			// Redraw it:
			polys[polys.length-1].redraw();
			
			// Return the polygon created:
			return polys[polys.length-1];
		}
		
		// Adds a raycast to the simulation
		// @param sx The ray starting X point
		// @param sy The ray starting Y point
		// @param dir The ray direction
		// @param range The ray range
		public function addRay(sx:Number, sy:Number, dir:Number, range:Number) : Ray {
			var r:Ray = new Ray();
			
			this.addChildAt(r, 0);
			
			r.updateBeam(sx, sy, dir, range);
			r.redraw();
			
			rays.push(r);
			
			return r;
		}
		
		// Loads a simulation from a strind code
		public function loadFromCode(input:String) : Boolean {			
			// Clear current simulation:
			clearEverything();
			
			// Trim the string:
			input = trim(input);
			
			//if(input.substr(0, 8) == "COMPRESS"){
				input = Util.decompress(input);
			//}
			
			// Split strings between '|':
			var tempS:Array = input.split('|');
			var tempA:Array = new Array();
			
			// Split one more time and decode:
			for(var i:int = 0; i < tempS.length; i++){
				tempA[i] = tempS[i].split(",");
			}
			
			// Temp variables:
			var obs:Object = {};
			
			var A:*, B:*, D:*, Hand:String, S:*, X:Number, Y:Number, currentType:String;
			
			for(i = 0; i < tempA.length; i++){
				if(tempA[i][0] != undefined/* && tempA[i][1] != undefined && tempA[i][2] != undefined*/){
					if(tempA[i][0] == "p" || tempA[i][0] == "f" || tempA[i][0] == "d" || tempA[i][0] == "o"){
						currentType = tempA[i][0];
					} else if(tempA[i][0] == "c" || tempA[i][0] == "x") {
						currentType = tempA[i][0];
					} else if(tempA[i][0] == "n") {
						currentType = "n";
						var ta:Array = new Array();
						for(var j:int=0;j<tempA[i].length-2;j++){
							ta.push(obs[tempA[i][j+2]]);
						}
						addPoly(ta, parseInt(tempA[i][1]));
					}
					
					if((currentType == "p" || currentType == "f" || currentType == "d" || currentType == "o") && tempA[i].length >= 3){
						var offset:int = -1;
						
						if(tempA[i][0] == currentType) offset = 0;
						
						X = parseFloat(tempA[i][2 + offset]);
						Y = parseFloat(tempA[i][3 + offset]);
						Hand = tempA[i][1 + offset];
						obs[Hand] = addParticle(X, Y,  currentType == "f" || currentType == "d");
						
						obs[Hand].collideWithPart = currentType == "p" || currentType == "f";
						
						obs[Hand].mass = tempA[i][4 + offset] == undefined ? 30 : parseFloat(tempA[i][4 + offset]);
					}
					
					if((currentType == "c" || currentType == "x") && tempA[i].length > 1){
						offset = -1;
						
						if(tempA[i][0] == currentType) offset = 0;
						
						A = tempA[i][1 + offset];
						B = tempA[i][2 + offset];
						addConstraint(obs[A], obs[B], -1, 0.5, currentType == "c");
					}
				}
			}
			
			return true;
		}
		
		// Removes a particle and all traces of it from the code
		public function removeParticle(p:Particle) : Boolean {
			if(parts.indexOf(p) != -1 && p.parent != null){
				// Delete from memory:
				// delete parts[parts.indexOf(p)];
				
				p.cleanGarbage();
				
				// Remove from screen:
				removeChild(p);
				
				// Exclude from array:
				parts.splice(parts.indexOf(p), 1);
				
				// Succeful!
				return true;
			}
			
			return false;
		}
		
		// Removes a constraint and all traces of it from the code
		public function removeConstraint(c:Constraint) : Boolean {
			if(cons.indexOf(c) != -1){
				// Exclude from array:
				cons.splice(cons.indexOf(c), 1);
				
				// Delete from memory:
				delete cons[cons.indexOf(c)];
				
				// Remove from screen:
				removeChild(c);
				
				// Succeful!
				return true;
			}
			
			// This constraint was not found
			return false;
		}
		
		// Remove a poly and any and all traces of it from the code
		// correctly cleaning for garbage collecting.
		public function removePoly(poly:Polygon) : void {
			if(poly == null) return;
			
			var n:int = polys.indexOf(poly);
			
			poly.clearGarbage();
			
			if(poly.parent != null)
				this.removeChild(poly);
			
			if(n != -1){
				polys[n] = null;
				polys.splice(n, 1);
			}
			
			poly = null;
		}
		
		// Removes a ray and all traces of it from the code
		public function removeRay(r:Ray) : void {
			if(r == null) return;
			
			var n:int = rays.indexOf(r);
			
			if(r.parent != null)
				this.removeChild(r);
			
			if(n != -1){
				rays[n] = null;
				rays.splice(n, 1);
			}
			
			r = null;
		}
		
		// Clip a particle inside the boundaries:
		public function clipParticle(p:Particle) : void {
			var dx:Number = 0, dy:Number = 0;
			
			if(p.X <  clipBounds.x + p.rad){
				dx = (p.X - p.oldx) * 0.8;
			}
			if(p.Y <  clipBounds.y + p.rad){
				dy = (p.Y - p.oldy) * 0.8;
				
				// Horizontal friction:
				if((dx < 0 ? -dx : dx) > 0) dx *= 0.5;
				else {
					dx = -(p.X - p.oldx) * 0.5;
				}
			}
			
			if(p.X > clipBounds.width - p.rad){
				dx = (p.X - p.oldx) * 0.8;
			}
			if(p.Y > clipBounds.height - p.rad){
				dy = (p.Y - p.oldy) * 0.8;
				
				// Horizontal friction:
				if((dx < 0 ? -dx : dx) > 0) dx *= 0.5;
				else {
					dx = -(p.X - p.oldx) * 0.5;
				}
			}
			
			var dpx:Number = clipBounds.x + p.rad, dpy:Number = clipBounds.y + p.rad;
			
			p.X = (p.X < dpx ? dpx : p.X);
			p.Y = (p.Y < dpy ? dpy : p.Y);
			
			dpx = clipBounds.width - p.rad, dpy = clipBounds.height - p.rad;
			
			p.X = (p.X > dpx ? dpx : p.X);
			p.Y = (p.Y > dpy ? dpy : p.Y);
			
			if((dx < 0 ? -dx : dx) > 0) p.oldx = p.X + dx;
			if((dy < 0 ? -dx : dx) > 0) p.oldy = p.Y + dy;
		}
		
		
		// Sim control:
		public function togglePause(pause:* = null) : void {
			active = (pause != null ? pause as Boolean : !active);
		}
		
		// Cllears the entire simulation:
		public function clearEverything() : void {
			while(parts.length > 0)
				removeParticle(parts[0]);
			
			while(cons.length > 0)
				removeConstraint(cons[0]);
			
			while(polys.length > 0)
				removePoly(polys[0]);
			
			while(rays.length > 0)
				removeRay(rays[0]);
		}
		
		
		// Misc:
		public function setOffset(X:Number = 0, Y:Number = 0) : void {
			offset.x = X;
			offset.y = Y;
		}
		
		// Trims a string
		public function trim(str:String) : String {
		    var stripCharCodes:Object = {
		        code_9  : true,
		        code_10 : true,
		        code_13 : true,
		        code_32 : true
		    };
			
		    while(stripCharCodes["code_" + str.charCodeAt(0)] == true) {
		        str = str.substring(1, str.length);
		    }
			
		    while(stripCharCodes["code_" + str.charCodeAt(str.length - 1)] == true) {
		        str = str.substring(0, str.length - 1);
		    }
			
			var strs:String = "";
			var a:Number;
			for(var i:int = 0; i < str.length; i++){
				a = str.charCodeAt(i);
				if(a != 9 && a != 10 && a != 13 && a != 32)
					strs += String.fromCharCode(str.charCodeAt(i));
			}
		
		    return strs;
		}
	}
}