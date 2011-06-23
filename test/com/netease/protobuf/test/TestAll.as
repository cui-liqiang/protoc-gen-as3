// Copyright (c) 2010 , NetEase.com,Inc. All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.

package com.netease.protobuf.test {
	import google.protobuf.FileDescriptorSet;
	import protobuf_unittest.*
	import protobuf_unittest.TestAllTypes.*
	import test.*
	import flash.display.*
	import flash.utils.*
	import flash.system.*
	import com.netease.protobuf.*

	public class TestAll {
	
		private static function assert(b:Boolean,
				errorMessage:String = "Assertion failed.",
				errorId:int = 0):void {
			if (!b) {
				throw new Error(errorMessage, errorId)
			}
		}
		private static function assertSame(l:*, r:*, name:String = ""):void {
			if (typeof(l) == "object") {
				assert(getQualifiedClassName(l) ==
						getQualifiedClassName(r))
				if (l is Array || l is ByteArray) {
					assertSame(l.length, r.length, name + ".length")
					for (var i:int = 0; i < l.length; i++) {
						assertSame(l[i], r[i], name + "[" + i + "]")
					}
				} else {
					var k:*
					for(k in l) {
						assertSame(l[k], r[k], name + "[" + k + "]")
					}
					for(k in r) {
						assertSame(l[k], r[k], name + "[" + k + "]")
					}
					const description:XML = describeType(l)
					for each(var getter:XML in description..accessor.(@access != "writeonly")) {
						assertSame(l[getter.@name], r[getter.@name], name + "." + getter.@name)
					}
					for each(var field:XML in description..variable) {
						assertSame(l[field.@name], r[field.@name], name + "." + field.@name)
					}
				}
			} else {
				assert(l === r || (isNaN(l) && isNaN(r)), name + " not equal.")
			}
		}
		private static const HEX_CHARS:String = "0123456789ABCDEF"
		private static function testAmf(input:*):void {
			const ba:ByteArray = new ByteArray
			ba.writeObject(input)
			var s:String = ""
			for (var i:uint = 0; i < ba.length; i++) {
				s += HEX_CHARS.charAt(ba[i] / 16)
				s += HEX_CHARS.charAt(ba[i] % 16)
				s += " "
			}
			trace(input)
			trace(s)
			ba.position = 0
			const output:* = ba.readObject()
			assertSame(input, output)
		}
		private static function testText(input:Message):void {
			const text:String =
					com.netease.protobuf.TextFormat.printToString(input, false)
			const output:Message =
					new (getDefinitionByName(getQualifiedClassName(input)))
			com.netease.protobuf.TextFormat.mergeFromString(text, output)
			trace("input:", input, "output:", output, "text:", text)
			assertSame(input, output)
		}
		private static function test(input:Message):void {
			const ba:ByteArray = new ByteArray
			input.writeTo(ba)
			var s:String = ""
			for (var i:uint = 0; i < ba.length; i++) {
				s += HEX_CHARS.charAt(ba[i] / 16)
				s += HEX_CHARS.charAt(ba[i] % 16)
				s += " "
			}
			ba.position = 0
			const output:Message = new (getDefinitionByName(
					getQualifiedClassName(input)))
			output.mergeFrom(ba)
			assertSame(input, output)
		}
		public static function run(haxeTest:Boolean = false):void {
			
			const int64:Int64 = new Int64(0x12345678, 0x91abcde1)
			assertSame(int64.toString(), "-7950034350635723144")
			assertSame(Int64.parseInt64(int64.toString()), int64)

			const int64_2:Int64 = new Int64(0x12345678, 0xb)
			assertSame(int64_2.toString(), "47550060152")
			assertSame(Int64.parseInt64(int64_2.toString()), int64_2)

			const int64_3:Int64 = new Int64(0x12345678, 0xabcdef12)
			assertSame(int64_3.toString(), "-6066930262104320392")
			assertSame(Int64.parseInt64(int64_3.toString()), int64_3)

			const int64_4:Int64 = new Int64(0x12345678, 0xbb)
			assertSame(int64_4.toString(), "803464304248")
			assertSame(Int64.parseInt64(int64_4.toString()), int64_4)

			const int64_5:Int64 = new Int64(0, 0)
			assertSame(int64_5.toString(), "0")
			assertSame(Int64.parseInt64(int64_5.toString()), int64_5)

			const uint64:UInt64 = new UInt64(0x12345678, 0)
			assertSame(uint64.toString(), "305419896")
			assertSame(UInt64.parseUInt64(uint64.toString()), uint64)

			const uint64_2:UInt64 = new UInt64(0x12345678, 0xb)
			assertSame(uint64_2.toString(), "47550060152")
			assertSame(UInt64.parseUInt64(uint64_2.toString()), uint64_2)

			const uint64_3:UInt64 = new UInt64(0x12345678, 0xabcdef12)
			assertSame(uint64_3.toString(), "12379813811605231224")
			assertSame(UInt64.parseUInt64(uint64_3.toString()), uint64_3)

			const uint64_4:UInt64 = new UInt64(0x12345678, 0xbb)
			assertSame(uint64_4.toString(), "803464304248")
			assertSame(UInt64.parseUInt64(uint64_4.toString()), uint64_4)

			const uint64_5:UInt64 = new UInt64(0, 0)
			assertSame(uint64_5.toString(), "0")
			assertSame(UInt64.parseUInt64(uint64_5.toString()), uint64_5)

			const t0:TestAllTypes = new TestAllTypes
			t0[1500938] = stringToByteArray('\n')
			test(t0)
			testText(t0)
			
			const t1:TestPackedTypes = new TestPackedTypes
			t1.packedDouble = [1.23424353, 2.12]
			t1.packedEnum = [ForeignEnum.FOREIGN_BAZ, ForeignEnum.FOREIGN_FOO,
					ForeignEnum.FOREIGN_FOO, ForeignEnum.FOREIGN_BAR]
			test(t1)
			testText(t1)

			const t2:TestPackedExtensions = new TestPackedExtensions
			t2[PACKED_DOUBLE_EXTENSION] = [324.234, 1.23424353, 2.12]
			t2[PACKED_ENUM_EXTENSION] =[ForeignEnum.FOREIGN_BAZ,
					ForeignEnum.FOREIGN_FOO, ForeignEnum.FOREIGN_FOO] 
			test(t2)
			testText(t2)

			const t3:TestAllTypes = new TestAllTypes
			t3.optionalString = "111foo"
			t3.defaultNestedEnum = NestedEnum.FOO
			t3.repeatedNestedMessage.push(new NestedMessage)
			t3.repeatedNestedMessage.push(new NestedMessage)
			t3.repeatedNestedMessage[1].bb = 123
			t3.optionalInt32 = -23412413
			t3.optionalDouble = 123.456
			t3.repeatedNestedEnum.push(NestedEnum.FOO)
			t3.repeatedNestedEnum.push(NestedEnum.BAR)
			t3.optionalNestedMessage = new NestedMessage
			t3.optionalNestedMessage.bb = 234
			t3.optionalSint32 = -3
			t3.optionalSint64 = new Int64(199999999, 199999999)
			test(t3)
			testText(t3)
			const t4:TestPackedTypes = new TestPackedTypes
			t4.packedDouble = [1]
			test(t4)
			testText(t4)
			const t5:TestAllTypes = new TestAllTypes
			t5.optionalSint32 = -199999999
			test(t5)
			testText(t5)
			const t6:TestAllTypes = new TestAllTypes
			t6.optionalInt64 = new Int64(uint(-185754567), -198741265)
			test(t6)
			testText(t6)
			const t7:TestAllTypes = new TestAllTypes
			const s64:Int64 = new Int64(uint(-171754567), -198741265)
			t7.optionalSint64 = s64
			t7.optionalInt64 = new Int64(ZigZag.encode64low(s64.low, s64.high),
										 ZigZag.encode64high(s64.low, s64.high))
			t7.optionalInt32 = -1
			t7[41192] = UInt64.parseUInt64("12343245732475923") // Unknown Varint
			t7[631669] = 12345325 // Unknown Fixed32
			t7[631677] = [234, 234, 123222, 12345325] // Unknown Fixed32
			t7[1500930] = stringToByteArray("Hello\u00C4\u00C3xxx") // Unknown Length Delimited
			t7[1500938] = [stringToByteArray("Hello"), stringToByteArray("World")] // Unknown Length Delimited
			testText(t7)
			test(t7)
			const t9:TestAllTypes = new TestAllTypes
			t9.optionalSint64 = new Int64(uint(-171754567), -198741265)
			test(t9)
			testText(t9)
			const t10:AAA = new AAA
			t10.s = "xxxx"
			test(t10)
			testText(t10)
			if (haxeTest) {
				import flash.net.registerClassAlias
				registerClassAlias("中文名", AAA)
				registerClassAlias("com.dongxiguo.Foo", BBB)
			}
			testAmf(t10)
			
			const t11:BBB = new BBB
			t11.aaa = new AAA
			t11.aaa.s = "1234xxx"
			t11.i = 1234
			test(t11)
			testText(t11)
			testAmf(t11)
			testAmf([t10, t11, t10])
			

			const t12:TestAllExtensions = new TestAllExtensions
			t12[REPEATED_STRING_EXTENSION] = ["aaaa", "bbb"]
			test(t12)
			testText(t12);

			[Embed(source = "../../../../../unittest.bin",
					mimeType="application/octet-stream")]
			const UNITTEST_BIN:Class
			const descriptors:FileDescriptorSet = new FileDescriptorSet
			descriptors.mergeFrom(new UNITTEST_BIN)
			test(descriptors)
			testText(descriptors)
			
			trace("All tests pass.")
			fscommand("quit")
		}
	}

}