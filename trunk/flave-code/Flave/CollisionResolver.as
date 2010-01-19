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
	import flash.geom.Point;
	
	import Flave.*;
	import Flave.Util.*;
	
	// Collision resolver class
	public class CollisionResolver {
		// Resolves particle-particle collision
		// @param p1 The first particle to resolve
		// @param p2 The second particle to resolve
		public static function resolveParticle(p1:Particle, p2:Particle) : void {
			if(p1 == p2  || !p1.collideWithPart || !p2.collideWithPart) return;
			
			var dx:Number, dy:Number, dis:Number;
			
			dx = p1.X - p2.X;
			dy = p1.Y - p2.Y;
			
			dis = Math.sqrt(dx * dx + dy * dy);
			
			// If the distance between both particles is smaller than
			// the sum of both radius....
			if(dis <= p1.rad + p2.rad){
				var pen:Number = ((p1.rad + p2.rad) - dis) * 0.5;
				
				dx /= dis;
				dy /= dis;
				
				if(p1.fixed || p2.fixed)
					pen *= 2;
				
				// var mw:Number = (p1.iMass + p2.iMass), m:Number;
				if(!p1.fixed){
					//m = (p1.iMass / mw);
					p1.X += dx * pen;
					p1.Y += dy * pen;
					
				}
				
				if(!p2.fixed){
					//m = (p2.iMass / mw);
					
					
					p2.X -= dx * pen;
					p2.Y -= dy * pen;
				}
			}
		}
		
		// Resolves particle-constraint collision
		// @param p0 The particle to check
		// @param c1 The constraint to check
		public static function resolveCircleConstraint(p0:Particle, c1:Constraint) : void {
			// Usind the dot factor, you can easily resolve the penetration between
			// a circle and a line:
			
			// Do not test if particle and constraint are linked:
			if(p0.constraints.indexOf(c1) != -1 || (c1.p1.fixed && c1.p2.fixed && p0.fixed))
				return;
			
			// Declare the variables:
			var ax:Number, ay:Number, bx:Number, by:Number, AdotB:Number, p1:Particle, p2:Particle, len:Number, px:Number, py:Number;
			
			p1 = c1.p1;
			p2 = c1.p2;
			
			///// First, test trajectory penetrations:
			
			// ...between the old and new position:
			var p1v:Vector2 = new Vector2(p1.X, p1.Y);
			var p2v:Vector2 = new Vector2(p2.X, p2.Y);
			
			var p0v:Vector2 = new Vector2(p0.X, p0.Y);
			var pov:Vector2 = new Vector2(p0.oldx, p0.oldy);
			
			// var v:Vector2, nx:Number, ny:Number, ns:Number;
			var dx:Number, dy:Number, dir:Number, dis:Number,
				pen:Number, perc1:Number, perc2:Number;
			
			// TODO: Apply the force also to the constraint's particles:
			
			// Math.abs is too slow :(
			var dpx:Number = p0.oldx - p0.X;
			dpx = (dpx < 0 ? -dpx : dpx);
			
			var dpy:Number = p0.oldy - p0.Y;
			dpy = (dpy < 0 ? -dpy : dpy);
			
			if((dpx > p0.rad || dpy > p0.rad) && checkLines(p1v, p2v, pov, p0v)[0] && !p0.fixed){
				var v:Vector2, nx:Number, ny:Number, ns:Number;
				
				//trace(checkLines(p1v, p2v, pov, p0v)[1]);
				// Take the penetration Vector2:
				v = checkLines(p1v, p2v, pov, p0v)[1];
				
				// Calculate the normal of the speed:
				nx = p0.X - p0.oldx;
				ny = p0.Y - p0.oldy;
				ns = Math.sqrt(nx * nx + ny * ny);
				nx /= ns;
				ny /= ns;
				
				// Now apply the Vector2 with the offset:
				var mid:Vector2 = new Vector2((p0.X + v.x) * 0.5, (p0.Y + v.y) * 0.5);
				p0.X = (v.x - nx*2);
				p0.Y = (v.y - ny*2);
				p0.slowDown();
			}
			
			///// Everything's fine, now test and resolve collisions:
			
			ax = p1.X - p2.X;
			ay = p1.Y - p2.Y;
			len = Math.sqrt(ax * ax + ay * ay);
			ax /= len;
			ay /= len;

			bx = p1.X - p0.X;
			by = p1.Y - p0.Y;
			
			var ac:Number = ax * bx + ay * by;
			
			AdotB = 0 > ac ? 0 : ac;
			
			ac = distance(p1.X, p1.Y,p2.X, p2.Y);
			
			AdotB = AdotB < ac ? AdotB : ac;
			
			px = (ax * AdotB);
			py = (ay * AdotB);
			
			// Test and resolve the collision:
			if (distance(p0.X, p0.Y, p1.X - px, p1.Y - py) < p0.rad) {
				///// Penetration Calcs:
				dx = (p1.X - px) - p0.X;
				dy = (p1.Y - py) - p0.Y;
				dis = Math.sqrt (dx * dx + dy * dy);
				if(dis == 0) dx = dis = 1; // Delta cannot be 0!
				dx /= dis;
				dy /= dis;
				pen = (p0.rad - dis);
				
				///// Particle Calcs:
				if(!p0.fixed){					
					if(c1.p1.fixed && c1.p2.fixed)
						pen *= 1;
					
					p0.X -= dx * pen;
					p0.Y -= dy * pen;
				} else pen *= 4;
				
				
				
				///// Constraint Calcs:
				
				// Calculate the percentage offset [0-1]:
				perc2 = AdotB / c1.getLen();
				perc1 = 1-perc2;
				
				// Apply it:
				if(!c1.p1.fixed){
					if(c1.p2.fixed) perc1 = 1;
					c1.p1.X += dx * (pen * 0.5 * perc1);
					c1.p1.Y += dy * (pen * 0.5 * perc1);
				} else perc2 = 1;
				
				if(!c1.p2.fixed){
					c1.p2.X += dx * (pen * 0.5 * perc2);
					c1.p2.Y += dy * (pen * 0.5 * perc2);
				}
			}
		}
		
		
		public static function resolveConstraintConstraint(line1:Constraint, line2:Constraint) : void {
			// Not up yet :(
		}
		
		// Check if two lines intersect (code taken from http://www.gamedev.pastebin.com/f49a054c1)
		// Returns if they collide, the intersection point and the distance along each line
		public static function checkLines(ptA:Vector2, ptB:Vector2, ptC:Vector2, ptD:Vector2) : Array {
			var r:Number, s:Number, d:Number;
			
			var x1:Number = ptA.x, y1:Number = ptA.y,
				x2:Number = ptB.x, y2:Number = ptB.y,
				x3:Number = ptC.x, y3:Number = ptC.y,
				x4:Number = ptD.x, y4:Number = ptD.y;
			
            //Make sure the lines aren't parallel
            if ((y2 - y1) / (x2 - x1) != (y4 - y3) / (x4 - x3))
            {
                d = (((x2 - x1) * (y4 - y3)) - (y2 - y1) * (x4 - x3));
                if (d != 0)
                {
                    r = (((y1 - y3) * (x4 - x3)) - (x1 - x3) * (y4 - y3)) / d;
                    s = (((y1 - y3) * (x2 - x1)) - (x1 - x3) * (y2 - y1)) / d;
                    if (r >= 0 && r <= 1)
                    {
						if (s >= 0 && s <= 1)
                        {
                            // result.InsertSolution(x1 + r * (x2 - x1), y1 + r * (y2 - y1));
							return [true, new Vector2(x1 + r * (x2 - x1), y1 + r * (y2 - y1)), r, s]; // penetrated, position, scale along first line, scale along second line
                        }
						else return [false];
                    }
					else return [false];
                }
            }
			
			return [false];
		}
		
		// Check if two lines intersect (code taken from http://www.gamedev.pastebin.com/f49a054c1)
		// Returns if they collide, the intersection point and the distance along each line
		public static function checkLinesP(x1:Number, y1:Number,
										   x2:Number, y2:Number,
										   x3:Number, y3:Number,
										   x4:Number, y4:Number) : Array {
			var ptA:Vector2 = new Vector2(x1, y1);
			var ptB:Vector2 = new Vector2(x2, y2);
			var ptC:Vector2 = new Vector2(x3, y3);
			var ptD:Vector2 = new Vector2(x4, y4);
			
            return checkLines(ptA, ptB, ptC, ptD);
		}
		
		// TODO: When the ray is shortened by a collision, remove it from
		//       the cells it isn't present anymore
		// Checks for collision between a ray and a particle
		// @param p0 The particle to check
		// @param ray The ray to check
		public static function rayOnParticle(p0:Particle, ray:Ray) : Array {
			// Do not test if line is the ray's caster:
			if(ray.Caster == p0)
				return [false];
			
			var oex:Number = ray.ex;
			var oey:Number = ray.ey;
			var olh:* = ray.lastHit;
			
			var x1_:Number = ray.sx, y1_:Number = ray.sy, x2_:Number = ray.ex, y2_:Number = ray.ey,
				x3_:Number = p0.X, y3_:Number = p0.Y, r3_:Number = p0.rad;
			
			var v1:Vector2, v2:Vector2;
            //Vector2 from point 1 to point 2
            v1 = new Vector2(x2_ - x1_, y2_ - y1_);
            //Vector2 from point 1 to the circle's center
            v2 = new Vector2(x3_ - x1_, y3_ - y1_);

           	var dot:Number = v1.X * v2.X + v1.Y * v2.Y;
            var proj1:Vector2 = new Vector2(((dot / (v1.length())) * v1.X), ((dot / (v1.length())) * v1.Y));

            var midpt:Vector2 = new Vector2(x1_ + proj1.X, y1_ + proj1.Y);
            var distToCenter:Number = (midpt.X - x3_) * (midpt.X - x3_) + (midpt.Y - y3_) * (midpt.Y - y3_);
            
			if (distToCenter > r3_ * r3_) return [false];
			
            if (distToCenter == r3_ * r3_)
            {
                //ray.ex = midpt.x;
				//ray.ey = midpt.y;
                return [false];
            }
	        var distToIntersection:Number;
            if (distToCenter == 0)
            {
                distToIntersection = r3_;// * r3_;
            }
            else
            {
                distToCenter = Math.sqrt(distToCenter);
                distToIntersection = Math.sqrt(r3_ * r3_ - distToCenter * distToCenter);
            }
            var lineSegmentLength:Number = 1 / v1.magnitude();
           	v1.multEquals(lineSegmentLength);
            v1.multEquals(distToIntersection);
			
			var sol:Vector2, hit:Boolean;
			
			// If you want inner circle collision checking...
           	var solution1:Vector2 = midpt.plus(v1);
            if ((solution1.X - x1_) * v1.X + (solution1.Y - y1_) * v1.Y > 0)
            {
                //result.InsertSolution(solution1);
				/*ray.ex = solution1.x;
				ray.ey = solution1.y;
				
				ray.lastHit = p0;*/
				sol = solution1;
				hit = true;
            }
            var solution2:Vector2 = midpt.minus(v1);
            if ((solution2.X - x1_) * v1.X + (solution2.Y - y1_) * v1.Y > 0)
            {
                //result.InsertSolution(solution2);
				/*ray.ex = solution2.x;
				ray.ey = solution2.y;
				
				ray.lastHit = p0;*/
				sol = solution2;
				hit = true;
            }
			
			
			var dx:Number = ray.sx - ray.ex;
			var dy:Number = ray.sy - ray.ey;
			
			var dox:Number = ray.sx - oex;
			var doy:Number = ray.sy - oey;
			
			var dis:Number = Math.sqrt(dx * dx + dy * dy);
			
			if(Math.sqrt(dox * dox + doy * doy) < dis){
				sol.x = oex;
				sol.y = oey;
				hit = false;
			} else if(dis > ray.Range){
				// ray.updateBeam(ray.sx, ray.sy, ray.Direction, ray.Range);
			}
			
			return [hit, sol];
		}
		
		// TODO: When the ray is shortened by a collision, remove it from
		//       the cells it isn't present anymore
		// Perform collision check against a constraint and a ray
		// @param c0 The constraint to check
		// @param ray The ray to check
		public static function rayOnConstraint(c0:Constraint, ray:Ray) : Array {
			var result:Array = checkLinesP(ray.sx, ray.sy, ray.ex, ray.ey, c0.p1.X, c0.p1.Y, c0.p2.X, c0.p2.Y);
			
			//var oex = ray.ex;
			//var oey = ray.ey;
			
			if(result[0] == true){
				ray.ex = result[1].X;
				ray.ey = result[1].Y;
				ray.lastHit = c0;
			}
			
			return result;
		}
		
		public static function distance(x1:Number, y1:Number, x2:Number, y2:Number) : Number {
			return Math.sqrt((x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2));
		}
		
		public static function sign(x:Number) : Number {
			return x > 0 ? 1 : -1;
		}
	}
}