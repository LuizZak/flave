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
	public class Util {
		public static function trim(str:String) : String {
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
		
		public static function compress(in_str:String) : String {
			if(in_str.indexOf("COMPRESS") == 0){
				return in_str;
			}
			
			return "COMPRESS" + LZW.compress(in_str);
		}
		
		public static function decompress(in_str:String) : String {
			if(in_str.indexOf("COMPRESS") != 0){
				return in_str;
			}
			
			in_str = in_str.split("COMPRESS")[1];
			
			in_str = LZW.decompress(in_str);
			
			return in_str;
		}
	}
}