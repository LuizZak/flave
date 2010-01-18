/****************************************************/
/*
/*  The LZW is a copyrighted algorithm from Unisys
/*
/****************************************************/

package Flave.Util {
	public class LZW {
		// Change this variable to output an xml safe string
		private static var xmlsafe:Boolean = false;
		
		public static function compress(str:String):String {
			var dico:Array = new Array();
			var skipnum:Number = xmlsafe ? 5 : 0;
			
			for (var i = 0; i < 256; i++) {
				dico[String.fromCharCode(i)] = i;
			}
			
			if (xmlsafe) {
				dico["<"] = 256;
				dico[">"] = 257;
				dico["&"] = 258;
				dico["\""] = 259;
				dico["'"] = 260;
			}
			
			var res:String = "";
			var txt2encode:String = str;
			var splitStr:Array = txt2encode.split("");
			var len:Number = splitStr.length;
			var nbChar:Number = 256+skipnum;
			var buffer:String = "";
			
			for (i = 0; i <= len; i++) {
				var current = splitStr[i];
				
				if (dico[buffer + current] !== undefined) {
					buffer += current;
				} else {
					res += String.fromCharCode(dico[buffer]);
					dico[buffer + current] = nbChar;
					nbChar++;
					buffer = current;
				}
			}
			return res;
		}
		
		public static function decompress(str:String):String
		{
			var dico:Array = new Array();
			var skipnum:Number = xmlsafe ? 5 : 0;
			
			for (var i = 0; i < 256; i++){
				var c:String = String.fromCharCode(i);
				dico[i] = c;
			}
			
			if (xmlsafe) {
				dico[256] = "<";
				dico[257] = ">";
				dico[258] = "&";
				dico[259] = "\"";
				dico[260] = "'";
			}
			
			var txt2encode:String = str;
			var splitStr:Array = txt2encode.split("");
			var length:Number = splitStr.length;
			var nbChar:Number = 256 + skipnum;
			var buffer:String = "";
			var chaine:String = "";
			var result:String = "";
			
			for (i = 0; i < length; i++) {
				var code:Number = txt2encode.charCodeAt(i);
				var current:String = dico[code];
				
				if (buffer == ""){
					buffer = current;
					result += current;
				} else {
					if (code <= 255 + skipnum) {
						result += current;
						chaine = buffer + current;
						dico[nbChar] = chaine;
						nbChar++;
						buffer = current;
					} else {
						chaine = dico[code];
						
						if (chaine == null) chaine = buffer + buffer.slice(0,1);
						
						result += chaine;
						dico[nbChar] = buffer + chaine.slice(0, 1);
						nbChar++;
						buffer = chaine;
						
					}
				}
			}
			
			return result;
		}
	}
}