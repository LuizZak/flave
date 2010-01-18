package {
	// Import needed classes:
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.geom.*;
	import flash.text.*;
	
	import Flave.*;
	
	/***********************************************************/
	/*
	/*   Samples class, containing samples of the engine core
	/*
	/***********************************************************/
	public class Samples extends MovieClip {
		// World object:
		public var w:World;
		
		// Current sample:
		public var curSample:int = 0;
		// Number of samples:
		public var numSamples:int = 11;
		
		// For the FPS counter:
		public var fps:int = 0;
		public var T:Timer = new Timer(1000);
		
		// Constructor:
		public function Samples() {
			// Adds the event listeners:
			addEventListener('enterFrame', loop, false, 0, true);
			stage.addEventListener('keyDown', keyDown, false, 0, true);
			
			// Loads the first sample:
			LoadSample(curSample);
			
			// Update the text boxes focus, we don't want to lose focus of the simulation!
			sampleText.mouseEnabled = notesText.mouseEnabled = fpsText.mouseEnabled = false;
			
			// Start the FPS counter:
			T.addEventListener("timer", tick, false, 0, true);
			T.start();
		}
		
		public function tick(e:Event) : void {
			fpsText.text = "" + fps;
			fps = 0;
		}
		
		public function keyDown(e:KeyboardEvent) : void {
			if(e.keyCode == 37) {
				curSample --;
			} else if(e.keyCode == 39) {
				curSample ++;
			} else { return; }
			
			if(curSample < 0) curSample = numSamples;
			if(curSample > numSamples) curSample = 0;
			
			LoadSample(curSample);
		}
		
		public function loop(e:Event) : void {
			fps ++;
			
			if(w != null) {
				w.Step();
				w.Draw();
			}
		}
		
		// Loads a sample
		// @param The sample ID
		public function LoadSample(si:int) : void {
			if(w != null) {
				w.clearEverything();
			}
			
			// Create a new instance:
			w = new World();
			// Set the boundaries:
			w.clipBounds = new Rectangle(0, 0, 550, 400);
			// Add it to the display list:
			stage.addChildAt(w, 1);
			
			sampleText.text = "#" + (si + 1) + " of " + (numSamples + 1) +": ";
			
			// NOTE: All string-compiled simulations where created using the
			// Flash Physics Toy v2, located at my kongreagate profile
			// http://www.kongregate.com/accounts/luizzak
			// String-compiled simulations lack many of the features of the
			// full engine, like raycasters, custom particles size and other.
			// So I really recommend using the normal simulation handling
			// functions.
			
			if(si == 0) {
				w.loadFromCode("conf,0,0,1,1|p|0,200,130|1,310,130|2,310,230|3,200,230|c|0,1|1,2|2,3|3,0|0,2|3,1");
				sampleText.appendText("Box");
				notesText.text = "This example shows a simple box made of 4 particles and 6 joints. You can drag it around using the mouse.";
			}
			if(si == 1) {
				w.loadFromCode("conf,0,0,1,1|p|0,140,140|1,180,140|2,180,180|3,140,180|4,210,140|5,250,140|6,250,180|7,210,180|8,130,210|9,170,210|10,170,250|11,130,250|12,200,210|13,240,210|14,240,250|15,200,250|16,280,140|17,320,140|18,320,180|19,280,180|20,350,140|21,390,140|22,390,180|23,350,180|24,270,210|25,310,210|26,310,250|27,270,250|28,340,210|29,380,210|30,380,250|31,340,250|32,140,280|33,180,280|34,180,320|35,140,320|36,210,280|37,250,280|38,250,320|39,210,320|40,130,350|41,170,350|42,170,390|43,130,390|44,200,350|45,240,350|46,240,390|47,200,390|48,280,280|49,320,280|50,320,320|51,280,320|52,350,280|53,390,280|54,390,320|55,350,320|56,270,350|57,310,350|58,310,390|59,270,390|60,340,350|61,380,350|62,380,390|63,340,390|c|0,1|1,2|2,3|3,0|0,2|1,3|4,5|4,6|7,4|5,6|5,7|6,7|8,9|8,10|11,8|9,10|9,11|10,11|12,13|12,14|15,12|13,14|13,15|14,15|16,17|16,18|19,16|17,18|17,19|18,19|20,21|20,22|23,20|21,22|21,23|22,23|24,25|24,26|27,24|25,26|25,27|26,27|28,29|28,30|31,28|29,30|29,31|30,31|32,33|32,34|35,32|33,34|33,35|34,35|36,37|36,38|39,36|37,38|37,39|38,39|40,41|40,42|43,40|41,42|41,43|42,43|44,45|44,46|47,44|45,46|45,47|46,47|48,49|48,50|51,48|49,50|49,51|50,51|52,53|52,54|55,52|53,54|53,55|54,55|56,57|56,58|59,56|57,58|57,59|58,59|60,61|60,62|63,60|61,62|61,63|62,63");
				sampleText.appendText("Various boxes");
				notesText.text = "This sample illustrates the robust collision detection and resolving routine.";
			}
			if(si == 2) {
				w.loadFromCode("conf,0,0,1,1|p|149,130,220|150,140,240|151,120,240|152,170,220|153,180,240|154,160,240|155,210,220|156,220,240|157,200,240|158,250,220|159,260,240|160,240,240|161,290,220|162,300,240|163,280,240|164,330,220|165,340,240|166,320,240|167,370,220|168,380,240|169,360,240|170,410,220|171,420,240|172,400,240|173,110,260|174,120,280|175,100,280|176,150,260|177,160,280|178,140,280|179,190,260|180,200,280|181,180,280|182,230,260|183,240,280|184,220,280|185,270,260|186,280,280|187,260,280|188,310,260|189,320,280|190,300,280|191,350,260|192,360,280|193,340,280|194,390,260|195,400,280|196,380,280|197,420,280|198,430,260|199,440,280|200,140,200|201,160,200|202,180,200|203,200,200|204,220,200|205,240,200|206,260,200|207,280,200|208,300,200|209,320,200|210,340,200|211,360,200|212,380,200|213,400,200|214,150,180|215,190,180|216,230,180|217,270,180|218,310,180|219,350,180|220,390,180|221,380,160|222,360,160|223,340,160|224,320,160|225,300,160|226,280,160|227,260,160|228,240,160|229,220,160|230,200,160|231,180,160|232,160,160|233,170,140|234,210,140|235,250,140|236,290,140|237,330,140|238,370,140|239,360,120|240,340,120|241,320,120|242,300,120|243,280,120|244,260,120|245,240,120|246,220,120|247,200,120|248,180,120|c");
				sampleText.appendText("Particles");
				notesText.text = "This sample illustrates once again the collision resolver speed. 100 particles interacting in real time in a verlet-based world.";
			}
			if(si == 3) {
				w.defPartSize = 5;
				w.loadFromCode("conf,0,0,1,1|p|149,130,220|150,140,240|151,120,240|152,170,220|153,180,240|154,160,240|155,210,220|156,220,240|157,200,240|158,250,220|159,260,240|160,240,240|161,290,220|162,300,240|163,280,240|164,330,220|165,340,240|166,320,240|167,370,220|168,380,240|169,360,240|170,410,220|171,420,240|172,400,240|173,110,260|174,120,280|175,100,280|176,150,260|177,160,280|178,140,280|179,190,260|180,200,280|181,180,280|182,230,260|183,240,280|184,220,280|185,270,260|186,280,280|187,260,280|188,310,260|189,320,280|190,300,280|191,350,260|192,360,280|193,340,280|194,390,260|195,400,280|196,380,280|197,420,280|198,430,260|199,440,280|200,140,200|201,160,200|202,180,200|203,200,200|204,220,200|205,240,200|206,260,200|207,280,200|208,300,200|209,320,200|210,340,200|211,360,200|212,380,200|213,400,200|214,150,180|215,190,180|216,230,180|217,270,180|218,310,180|219,350,180|220,390,180|221,380,160|222,360,160|223,340,160|224,320,160|225,300,160|226,280,160|227,260,160|228,240,160|229,220,160|230,200,160|231,180,160|232,160,160|233,170,140|234,210,140|235,250,140|236,290,140|237,330,140|238,370,140|239,360,120|240,340,120|241,320,120|242,300,120|243,280,120|244,260,120|245,240,120|246,220,120|247,200,120|248,180,120|c");
				sampleText.appendText("Small particles");
				notesText.text = "This sample illustrates how to change the global spawnning size of the particles using the variable World.defPartSize";
			}
			if(si == 4) {
				w.addParticle(175, 125, false, 5);
				w.addParticle(175, 150);
				w.addParticle(175, 185, false, 15);
				w.addParticle(175, 230, false, 20);
				w.addParticle(175, 290, false, 30);
				
				w.addParticle(275, 125, false, 5);
				w.addParticle(275, 150);
				w.addParticle(275, 185, false, 15);
				w.addParticle(275, 230, false, 20);
				w.addParticle(275, 290, false, 30);
				
				w.addParticle(375, 125, false, 5);
				w.addParticle(375, 150);
				w.addParticle(375, 185, false, 15);
				w.addParticle(375, 230, false, 20);
				w.addParticle(375, 290, false, 30);
				
				sampleText.appendText("Varied-size particles");
				notesText.text = "This sample shows how particle of different sizes intereact with each other";
			}
			if(si == 5) {
				w.loadFromCode("conf,0,0,1,1|p|f|153,150,310|154,410,310|p|155,180,170|156,220,170|157,260,170|158,300,170|159,340,170|160,200,140|161,240,140|162,280,140|163,320,140|164,380,170|165,360,140|166,220,120|167,260,120|168,300,120|169,340,120|170,230,100|171,250,100|172,270,100|173,290,100|174,310,100|175,330,100|f|176,100,240|177,460,240|p|178,160,200|179,200,200|180,240,200|181,280,200|182,320,200|183,360,200|184,400,200|185,140,230|186,180,230|187,220,230|188,260,230|189,300,230|190,340,230|191,380,230|192,420,230|c|153,154|176,153|177,154");
				
				sampleText.appendText("Constraint-particle collision");
				notesText.text = "This sample shows the default constraint-particle interaction";
			}
			if(si == 6) {
				for(var i:Number = 0; i < 10; i++) {
					var a:Particle = w.addParticle(150 + i*30, 125);
					var b:Particle = w.addParticle(150 + i*30, 250);
					
					w.addConstraint(a, b).stiff = 1 / (i + 1);
				}
				
				sampleText.appendText("Spring-Joints");
				notesText.text = "This sample shows how to turn constraints into springs by adjusting the Constraint.stiff parameter";
			}
			if(si == 7) {
				w.loadFromCode("conf,0,0,1,1|p|f|0,310,120|1,310,190|2,200,210|3,200,310|4,310,250|5,310,320|6,430,180|p|7,430,260|12,430,330|13,420,370|14,400,360|15,410,390|16,440,390|17,450,380|18,470,340|19,460,310|20,450,350|21,420,340|22,390,310|c|0,1|1,2|2,3|4,5|6,7");
				
				var p1:Particle = w.addParticle(50, 200, true);
				
				var r:Ray = w.addRay(p1.X, p1.Y, 0, 500);
				r.Caster = p1;
				r.fixOnCaster = true;
				
				sampleText.appendText("Ray-Caster");
				notesText.text = "This sample shows the ray-casting engine in action";
			}
			if(si == 8) {
				w.loadFromCode("conf,0,0,1,1|p|f|0,310,120|1,310,190|2,200,210|3,200,310|4,310,250|5,310,320|6,430,180|p|7,430,260|12,430,330|13,420,370|14,400,360|15,410,390|16,440,390|17,450,380|18,470,340|19,460,310|20,450,350|21,420,340|22,390,310|c|0,1|1,2|2,3|4,5|6,7");
				
				p1 = w.addParticle(50, 200, true);
				
				for(i = 0; i < 360; i += 360/60) {
					r = w.addRay(p1.X, p1.Y, i, 500);
					r.Caster = p1;
					r.fixOnCaster = true;
				}
				
				sampleText.appendText("Ray-Caster 2");
				notesText.text = "Same sample as the last, but with a larger number of rays";
			}
			if(si == 9) {
				w.loadFromCode("conf,0,0,1,1|p|f|15,220,300|16,330,300|17,440,300|p|18,280,200|f|19,280,360|20,390,360|o|21,390,200|f|24,110,300|25,160,360|p|26,160,200|c|x|15,16|c|16,17|24,15");
				
				sampleText.appendText("Collision filter");
				notesText.text = "This sample shows how to filter collisions using the Particle.collideWithPart, Paticle.collideWithCons and Constraint.collidable variables";
			}
			if(si == 10) {
				for(i = 0; i < 10; i++) {
					w.addParticle(150 + i*30, 145);
					w.addParticle(150 + i*30, 170);
					a = w.addParticle(150 + i*30, 125);
					b = w.addParticle(150 + i*30, 250);
					
					a.fixed = true;
					
					var c:Constraint = w.addConstraint(a, b);
					c.rupturePoint = 0.072 / (i + 1)
					c.collidable = false;
				}
				
				sampleText.appendText("Rupture point");
				notesText.text = "This sample shows the rupture point feature of the joints. Once the rupture tolerance is exceeded, the joint is destroyed.";
			}
			if(si == 11) {
				w.offset = new Point(0, -20);
				w.loadFromCode("conf,0,0,1,1|p|0,10,410|1,70,410|2,70,360|3,90,360|4,90,330|5,70,330|6,70,290|7,100,290|8,100,250|9,10,250|10,10,330|11,10,360|12,120,250|13,120,410|14,200,410|15,200,370|16,160,370|17,160,250|18,120,370|19,220,410|20,310,250|21,310,410|22,280,410|23,250,410|24,280,360|25,250,360|26,250,290|27,250,320|28,280,320|29,280,290|30,220,250|31,330,250|32,360,250|33,400,250|34,430,250|35,410,410|36,350,410|37,380,360|38,450,250|39,530,250|40,450,410|41,530,410|42,530,370|43,510,370|44,510,350|45,530,350|46,530,310|47,510,310|48,510,290|49,530,290|50,450,290|51,450,370|c|6,7|7,8|8,9|0,1|1,2|2,3|3,4|4,5|5,6|x|9,1|0,2|2,5|5,3|4,2|5,9|5,0|6,9|6,0|7,9|6,8|c|9,10|10,11|11,0|x|11,1|2,11|5,10|10,6|10,2|3,10|11,4|10,8|c|12,17|17,16|16,15|15,14|14,13|13,18|18,12|x|12,16|16,13|16,14|15,13|18,16|18,17|17,13|c|20,21|21,22|22,24|24,25|25,23|23,19|26,27|26,29|29,28|28,27|x|28,21|24,20|28,24|24,27|27,25|25,28|29,20|26,20|27,19|26,19|29,21|28,20|c|30,20|30,19|x|23,30|26,30|29,30|30,27|25,30|c|31,32|32,37|37,33|33,34|34,35|35,36|36,31|x|31,37|37,35|36,37|37,34|33,35|32,36|c|38,39|39,49|49,48|48,47|47,46|46,45|45,44|44,43|43,42|42,41|41,40|40,51|51,50|50,38|x|38,48|48,50|50,39|49,38|50,43|51,48|43,51|44,50|47,51|51,41|42,40|40,43|47,45|46,44|46,51|45,50|n,0,9,8,7,6,5,4,3,2,1,0,11,10|n,0,12,17,16,15,14,13,18|n,0,27,28,24,25|n,0,30,20,21,22,24,28,29,26,27,25,23,19|n,0,33,34,35,36,31,32,37|n,0,38,39,49,48,47,46,45,44,43,42,41,40,51,50");
				
				sampleText.appendText("FLAVE!");
				notesText.text = "FLAVE!\nSimulation created using the Flash Physics Toy v2";
			}
			
			notesText.appendText("\n\nUse the arrow keys to navigate between samples");
		}
	}
}