function check(condition, message)
	if not condition then error(message); end
end

function floatEqual(a,b) return a - b < 0.001 end

--[[ Object Tree / Class Checks ]]----------------------------------------------
check(workspace:FindFirstChild("scripts")
,     "Missing workspace.scripts : Folder.");

-- Util.lua
check(workspace.scripts:FindFirstChild("Util")
and   workspace.scripts:FindFirstChild("Util"):IsA("ModuleScript")
,     "Missing workspace.scripts.Util : ModuleScript.");

check(type(require(workspace.scripts.Util)) == "table"
,     "Table not returned from workspace.scripts.Util.");

-- Type.lua
check(workspace.scripts:FindFirstChild("Type")
and   workspace.scripts:FindFirstChild("Type"):IsA("ModuleScript")
,     "Missing workspace.scripts.Type : ModuleScript.");

check(type(require(workspace.scripts.Type)) == "table"
,     "Table not returned from workspace.scripts.Type.");

-- MIDI.lua
check(workspace.scripts:FindFirstChild("MIDI")
and   workspace.scripts:FindFirstChild("MIDI"):IsA("ModuleScript")
,     "Missing workspace.scripts.MIDI : ModuleScript.");

check(type(require(workspace.scripts.MIDI)) == "table"
,     "Table not returned from workspace.scripts.MIDI.");

-- CueMapper.lua
check(workspace.scripts:FindFirstChild("CueMapper")
and   workspace.scripts:FindFirstChild("CueMapper"):IsA("ModuleScript")
,     "Missing workspace.scripts.CueMapper : ModuleScript.");

check(type(require(workspace.scripts.CueMapper)) == "table"
,     "Table not returned from workspace.scripts.CueMapper.");

--[[ Util Checks ]]-------------------------------------------------------------
Util = require(workspace.scripts.Util);

check(type(Util.less) == "function"
,     "Missing Util.less : function.");

check(type(Util.equal) == "function"
,     "Missing Util.equal : function.");

check(type(Util.identity) == "function"
,     "Missing Util.identity : function.");

-- tableEqual
check(type(Util.tableEqual) == "function"
,     "Missing Util.tableEqual : function.");

check(Util.tableEqual({}, {})
,     "Util.tableEqual");

check(Util.tableEqual({1,2,3}, {1,2,3})
,     "Util.tableEqual");

check(Util.tableEqual({"abcd"}, {"abcd"})
,     "Util.tableEqual");

check(Util.tableEqual({1,2,3}, {[1]=1, [2]=2, [3]=3})
,     "Util.tableEqual");

check(Util.tableEqual({1,2,{3,4},5}, {1,2,{3,4},5})
,     "Util.tableEqual");

check(Util.tableEqual({time = 0}, {time = 0})
,     "Util.tableEqual");

check(Util.tableEqual({{{{{"A"}}}}}, {{{{{"A"}}}}})
,     "Util.tableEqual");

check(Util.tableEqual({[false]=0, [true]=1}, {[false]=0, [true]=1})
,     "Util.tableEqual");

check(not Util.tableEqual({}, {1})
,     "Util.tableEqual");

check(not Util.tableEqual({1}, {2})
,     "Util.tableEqual");

check(not Util.tableEqual({42}, {"A"})
,     "Util.tableEqual");

check(not Util.tableEqual({nil, 2}, {[2]=2})
,     "Util.tableEqual");

check(not Util.tableEqual({1,2,3,nil,5}, {1,2,3, [5]=5})
,     "Util.tableEqual");

check(not Util.tableEqual({a=1, b=1}, {a=1, b=1, c=1})
,     "Util.tableEqual");

check(not Util.tableEqual({a=1, b=1, c=1}, {a=1, b=1})
,     "Util.tableEqual");

-- deepCopy
check(type(Util.deepCopy) == "function"
,     "Missing Util.deepCopy : function.");

check((function()
	local t = {};
	local u = Util.deepCopy(t);
	return t ~= u and Util.tableEqual(t, u);
end) (), "Util.deepCopy");

check((function()
	local t = {1,2,3,{4,5}, size = 23, pitch = 0.24, {{42}}};
	local u = Util.deepCopy(t);
	return t ~= u and Util.tableEqual(t, u);
end) (), "Util.deepCopy");

-- sort
check(type(Util.sort) == "function"
,     "Missing Util.sort : function.");

check((function()
	local t = {};
	local u = Util.sort(t, Util.less);
	return t == u;
end) (), "Util.sort");

check(Util.tableEqual(Util.sort({}, Util.less), {})
,     "Util.sort");

check((function()
	local t, result = {}, {};
	Util.sort(t, Util.less);
	return Util.tableEqual(t, result);
end) (), "Util.sort");

check((function()
	local t, result = {3,2,1}, {1,2,3};
	Util.sort(t, Util.less);
	return Util.tableEqual(t, result);
end) (), "Util.sort");

check((function()
	local t, result
	= {6,2,8,3,1,5,0,7,9,4}
	, {9,8,7,6,5,4,3,2,1,0};
	Util.sort(t, function(a, b) return a > b; end);
	return Util.tableEqual(t, result);
end) (), "Util.sort");

check((function()
	local t, result
	= {"x","y","z","w"}
	, {"w","x","y","z"};
	Util.sort(t, Util.less);
	return Util.tableEqual(t, result);
end) (), "Util.sort");

check((function()
	local t, result
	= {"aaa","bb","c",""}
	, {"","c","bb","aaa"};
	Util.sort(t, function(a, b) return #a < #b; end);
	return Util.tableEqual(t, result);
end) (), "Util.sort");

check((function()
	local t, result
	= {1,2,2,3}
	, {1,2,3};
	Util.sort(t, Util.less);
	return not Util.tableEqual(t, result);
end) (), "Util.sort");

check((function()
	local t, result
	= {{x= 1, y= 1}, {x=-1, y= 1}, {x=-1, y=-1}, {x= 1, y=-1}}
	, {{x=-1, y=-1}, {x= 1, y=-1}, {x= 1, y= 1}, {x=-1, y= 1}};
	Util.sort(t, function(a, b)
		return math.atan2(a.y, a.x) < math.atan2(b.y, b.x)
	end);
	return Util.tableEqual(t, result);
end) (), "Util.sort");

-- allOf
check(type(Util.allOf) == "function", "Missing Util.allOf : function.");
check(Util.allOf({true}       , Util.identity) == true , "Util.allOf");
check(Util.allOf({false, true}, Util.identity) == false, "Util.allOf");
check(Util.allOf({false}      , Util.identity) == false, "Util.allOf");
check(Util.allOf({}           , Util.identity) == true , "Util.allOf");

-- anyOf
check(type(Util.anyOf) == "function", "Missing Util.anyOf : function.");
check(Util.anyOf({true}       , Util.identity) == true , "Util.anyOf");
check(Util.anyOf({false, true}, Util.identity) == true , "Util.anyOf");
check(Util.anyOf({false}      , Util.identity) == false, "Util.anyOf");
check(Util.anyOf({}           , Util.identity) == false, "Util.anyOf");

-- noneOf
check(type(Util.noneOf) == "function", "Missing Util.noneOf : function.");
check(Util.noneOf({true}       , Util.identity) == false, "Util.noneOf");
check(Util.noneOf({false, true}, Util.identity) == false, "Util.noneOf");
check(Util.noneOf({false}      , Util.identity) == true , "Util.noneOf");
check(Util.noneOf({}           , Util.identity) == true , "Util.noneOf");

-- findUntil
check(type(Util.findUntil) == "function"
,     "Missing Util.findUntil : function.");

check((function()
	local t, result
	= {}, 1;
	return Util.findUntil(t, function(x) return x; end);
end) (), "Util.findUntil");

check((function()
	local t_i_result_table = {
		{{1,3,5}, 0, 1},
		{{1,3,5}, 1, 1},
		{{1,3,5}, 2, 1},
		{{1,3,5}, 3, 2},
		{{1,3,5}, 4, 2},
		{{1,3,5}, 5, 3},
		{{1,3,5}, 6, 3},
	};
	for i,v in pairs(t_i_result_table) do
		if Util.findUntil(v[1], function(x) return x > v[2]; end) ~= v[3] then
			return false;
		end
	end
	return true;
end) (), "Util.findUntil");

check((function()
	local I, O = true, false;
	local t_result_table = {
		{{I,I,I}, 1},
		{{O,I,I}, 1},
		{{O,O,I}, 2},
		{{O,O,O}, 3},
	};
	for i,v in pairs(t_result_table) do
		if Util.findUntil(v[1], Util.identity) ~= v[2] then
			return false;
		end
	end
	return true;
end) (), "Util.findUntil");

-- Set constructor
check(type(Util.Set) == "function"
,     "Missing Util.Set : function.");

check(Util.tableEqual(
      Util.Set({}), {})
,    "Util.Set");

check(Util.tableEqual(
      Util.Set({1,2,3}), {[1]=true, [2]=true, [3]=true})
,    "Util.Set");

check(Util.tableEqual(
      Util.Set({nil}), {})
,    "Util.Set");

check(Util.tableEqual(
      Util.Set({1,1}), {[1]=true})
,    "Util.Set");

check(Util.tableEqual(
      Util.Set({false,true}), {[false]=true, [true]=true})
,    "Util.Set");

-- parseBase64
check(type(Util.parseBase64) == "function"
,     "Missing Util.parseBase64 : function.");

check(Util.parseBase64("") == ""
,     "Util.parseBase64");

check(Util.parseBase64("AA==") == "\0"
,     "Util.parseBase64");

check(Util.parseBase64("AAA=") == "\0\0"
,     "Util.parseBase64");

check(Util.parseBase64("AAAA") == "\0\0\0"
,     "Util.parseBase64");

check(Util.parseBase64("TVRoZA==") == "MThd"
,     "Util.parseBase64");

check(Util.parseBase64("TVRoZAAAAAY=") == "MThd\0\0\0\6"
,     "Util.parseBase64");

check(Util.parseBase64("a") == nil
,     "Util.parseBase64");

check(Util.parseBase64("=") == nil
,     "Util.parseBase64");

check(Util.parseBase64("===") == nil
,     "Util.parseBase64");

check(Util.parseBase64("12=456") == nil
,     "Util.parseBase64");

check(Util.parseBase64("a") == nil
,     "Util.parseBase64");

check(Util.parseBase64("$") == nil
,     "Util.parseBase64");

-- parseUint
check(type(Util.parseUint) == "function"
,     "Missing Util.parseUint : function.");

check(Util.parseUint("") == nil
,     "Util.parseUint");

check(Util.parseUint("\0") == 0
,     "Util.parseUint");

check(Util.parseUint("\x10\x00") == 0x1000
,     "Util.parseUint");

check(Util.parseUint("\xFF\xFF") == 0xFFFF
,     "Util.parseUint");

check(Util.parseUint("\xFF\xFF\xFF\xFF") == 0xFFFFFFFF
,     "Util.parseUint");

-- parseSint
check(type(Util.parseSint) == "function"
,     "Missing Util.parseSint : function.");

check(Util.parseSint("") == nil
,     "Util.parseSint");

check(Util.parseSint("\0") == 0
,     "Util.parseSint");

check(Util.parseSint("\x7F") == 127
,     "Util.parseSint");

check(Util.parseSint("\x80") == -128
,     "Util.parseSint");

check(Util.parseSint("\xFF") == -1
,     "Util.parseSint");

check(Util.parseSint("\x7F\xFF") == 0x7FFF
,     "Util.parseSint");

check(Util.parseSint("\x80\x00") == -0x8000
,     "Util.parseSint");

check(Util.parseSint("\x80\x01") == -0x7FFF
,     "Util.parseSint");

check(Util.parseSint("\xFF\xFF") == -1
,     "Util.parseSint");

check(Util.parseSint("\x00\x00\x00\x00") == 0
,     "Util.parseSint");

check(Util.parseSint("\x76\x54\x32\x10") == 0x76543210
,     "Util.parseSint");

check(Util.parseSint("\x7F\xFF\xFF\xFF") == 0x7FFFFFFF
,     "Util.parseSint");

check(Util.parseSint("\x80\x00\x00\x00") == -0x80000000
,     "Util.parseSint");

check(Util.parseSint("\xFF\xFF\xFF\xFF") == -1
,     "Util.parseSint");

--[[ Type Checks ]]-------------------------------------------------------------
Type = require(workspace.scripts.Type);

check(type(Type.new) == "function"
,     "Missing Type.new : function.");

--[[ MIDI Checks ]]-------------------------------------------------------------
MIDI = require(workspace.scripts.MIDI);

-- MIDI.statusLength
check(type(MIDI.statusLength) == "table"
,     "Missing MIDI.statusLength : table.");

check(MIDI.statusLength[0x8] == 2
and   MIDI.statusLength[0x9] == 2
and   MIDI.statusLength[0xA] == 2
and   MIDI.statusLength[0xB] == 2
and   MIDI.statusLength[0xC] == 1
and   MIDI.statusLength[0xD] == 1
and   MIDI.statusLength[0xE] == 2
,     "MIDI.statusLength");

-- MIDI.Parser
check(type(MIDI.Parser) == "table"
,     "Missing type MIDI.Parser.");

-- MIDI.Parser.peek
check(type(MIDI.Parser.peek) == "function"
,     "Missing MIDI.Parser.peek : function.");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "abc";
	local b = parser:peek(1);
	return b == "a" and parser.i == 1;
end) (), "Midi.Parser.peek");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "abc";
	local b = parser:peek(3);
	return b == "abc" and parser.i == 1;
end) (), "Midi.Parser.peek");

-- MIDI.Parser.read
check(type(MIDI.Parser.read) == "function"
,     "Missing MIDI.Parser.read : function.");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "abc";
	local b = parser:read(1);
	return b == "a" and parser.i == 2;
end) (), "Midi.Parser.read");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "abc";
	local b = parser:read(3);
	return b == "abc" and parser.i == 4;
end) (), "Midi.Parser.read");

-- MIDI.Parser.readUint
check(type(MIDI.Parser.readUint) == "function"
,     "Missing MIDI.Parser.readUint : function.");

-- MIDI.Parser.readSint
check(type(MIDI.Parser.readSint) == "function"
,     "Missing MIDI.Parser.readSint : function.");

-- MIDI.Parser.readVarLen
check(type(MIDI.Parser.readVarLen) == "function"
,     "Missing MIDI.Parser.readVarLen : function.");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "\x00";
	local n = parser:readVarLen();
	return n == 0x00000000 and parser.i == 2;
end) (), "Midi.Parser.readVarLen");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "\x40";
	local n = parser:readVarLen();
	return n == 0x00000040 and parser.i == 2;
end) (), "Midi.Parser.readVarLen");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "\x7F";
	local n = parser:readVarLen();
	return n == 0x0000007F and parser.i == 2;
end) (), "Midi.Parser.readVarLen");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "\x81\x00";
	local n = parser:readVarLen();
	return n == 0x00000080 and parser.i == 3;
end) (), "Midi.Parser.readVarLen");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "\xC0\x00";
	local n = parser:readVarLen();
	return n == 0x00002000 and parser.i == 3;
end) (), "Midi.Parser.readVarLen");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "\xFF\x7F";
	local n = parser:readVarLen();
	return n == 0x00003FFF and parser.i == 3;
end) (), "Midi.Parser.readVarLen");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "\x81\x80\x00";
	local n = parser:readVarLen();
	return n == 0x00004000 and parser.i == 4;
end) (), "Midi.Parser.readVarLen");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "\xC0\x80\x00";
	local n = parser:readVarLen();
	return n == 0x00100000 and parser.i == 4;
end) (), "Midi.Parser.readVarLen");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "\xFF\xFF\x7F";
	local n = parser:readVarLen();
	return n == 0x001FFFFF and parser.i == 4;
end) (), "Midi.Parser.readVarLen");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "\x81\x80\x80\x00";
	local n = parser:readVarLen();
	return n == 0x00200000 and parser.i == 5;
end) (), "Midi.Parser.readVarLen");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "\xC0\x80\x80\x00";
	local n = parser:readVarLen();
	return n == 0x08000000 and parser.i == 5;
end) (), "Midi.Parser.readVarLen");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "\xFF\xFF\xFF\x7F";
	local n = parser:readVarLen();
	return n == 0x0FFFFFFF and parser.i == 5;
end) (), "Midi.Parser.readVarLen");

-- MIDI.Parser.parseTickRate
check(type(MIDI.Parser.parseTickRate) == "function"
,     "Missing MIDI.Parser.parseTickRate : function.");

check((function()
	local parser = Type.new(MIDI.Parser);
	return parser:parseTickRate(0x0060) == 96;
end) (), "MIDI.Parser.parseTickRate");

check((function()
	local parser = Type.new(MIDI.Parser);
	return parser:parseTickRate(0x01E0) == 480;
end) (), "MIDI.Parser.parseTickRate");

check((function()
	local parser = Type.new(MIDI.Parser);
	return parser:parseTickRate(0x0001) == 1;
end) (), "MIDI.Parser.parseTickRate");

check((function()
	local parser = Type.new(MIDI.Parser);
	return parser:parseTickRate(0x7FFF) == 32767;
end) (), "MIDI.Parser.parseTickRate");

check((function()
	local parser = Type.new(MIDI.Parser);
	local fps, div = 25, 40;
	return parser:parseTickRate(-256*fps + div) == 1000;
end) (), "MIDI.Parser.parseTickRate");

check((function()
	local parser = Type.new(MIDI.Parser);
	local fps, div = 24, 25;
	return parser:parseTickRate(-256*fps + div) == 600;
end) (), "MIDI.Parser.parseTickRate");

check((function()
	local parser = Type.new(MIDI.Parser);
	local fps, div = 25, 24;
	return parser:parseTickRate(-256*fps + div) == 600;
end) (), "MIDI.Parser.parseTickRate");

check((function()
	local parser = Type.new(MIDI.Parser);
	local fps, div = 30, 20;
	return parser:parseTickRate(-256*fps + div) == 600;
end) (), "MIDI.Parser.parseTickRate");

check((function()
	local parser = Type.new(MIDI.Parser);
	local fps, div = 29, 20;
	return floatEqual(parser:parseTickRate(-256*fps + div)
	,                 600/1.001);
end) (), "MIDI.Parser.parseTickRate");

-- MIDI.Parser.parseHeader
check(type(MIDI.Parser.parseHeader) == "function"
,     "Missing MIDI.Parser.parseHeader : function.");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "MThd".."\0\0\0\6".."\0\1".."\0\1".."\x01\xE0";
	parser:parseHeader();
	return not parser.error and Util.tableEqual(parser.result.header, {
		format = 1;
		trackCount = 1;
		tickRate = 480;
		divisionType = "1/4 note";
	});
end) (), "MIDI.Parser.parseHeader");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "MThd".."\0\0\0\6".."\0\1".."\xFF\xFF".."\x7F\xFF";
	parser:parseHeader();
	return not parser.error and Util.tableEqual(parser.result.header, {
		format = 1;
		trackCount = 0xFFFF;
		tickRate = 0x7FFF;
		divisionType = "1/4 note";
	});
end) (), "MIDI.Parser.parseHeader");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "QSCV".."\0\0\0\6".."\0\1".."\0\1".."\x01\xE0";
	parser:parseHeader();
	return parser.error;
end) (), "MIDI.Parser.parseHeader");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "MThd".."\0\0\4\2".."\0\1".."\0\1".."\x01\xE0";
	parser:parseHeader();
	return parser.error;
end) (), "MIDI.Parser.parseHeader");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "MThd".."\0\0\0\6".."\0\4".."\0\1".."\x01\xE0";
	parser:parseHeader();
	return parser.error;
end) (), "MIDI.Parser.parseHeader");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "MThd".."\0\0\0\6".."\0\1".."\0\1".."\x00\x00";
	parser:parseHeader();
	return parser.error;
end) (), "MIDI.Parser.parseHeader");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "MThd".."\0\0\0\6".."\0\1".."\0\1".."\xE2\x00";
	parser:parseHeader();
	return parser.error;
end) (), "MIDI.Parser.parseHeader");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "MThd".."\0\0\0\6".."\0\1".."\0\0".."\x01\xE0";
	parser:parseHeader();
	return parser.error;
end) (), "MIDI.Parser.parseHeader");

-- MIDI.Parser.parseTrack
check(type(MIDI.Parser.parseTrack) == "function"
,     "Missing MIDI.Parser.parseTrack : function.");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "MTrk".."\0\0\0\1".."\x00\xFF\x2F\x00";
	parser:parseTrack();
	return not parser.error
	and    parser.i == 1 + 12
	and    parser.result.tracks[1].eventCount == 1
	and    #parser.result.tracks[1].events == 1;
end) (), "MIDI.Parser.parseTrack");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "xyzw".."\0\0\0\1".."\x00\xFF\x2F\x00";
	parser:parseTrack();
	return parser.error;
end) (), "MIDI.Parser.parseTrack");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "MTrk".."\0\0\0\0";
	parser:parseTrack();
	return parser.error;
end) (), "MIDI.Parser.parseTrack");

-- MIDI.Parser.parseEvent
check(type(MIDI.Parser.parseEvent) == "function"
,     "Missing MIDI.Parser.parseEvent : function.");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "\x00\x80\60\80";
	local e = parser:parseEvent();
	return not parser.error
	and    parser.i == 1 + 4
	and    Util.tableEqual(e, {
		deltaTime = 0;
		type = "Midi";
		status = 0x80;
		data = "\60\80";
	});
end) (), "MIDI.Parser.parseTrack");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "\x00\x80\60\80";
	local e = parser:parseEvent();
	return not parser.error
	and    parser.i == 1 + 4
	and    Util.tableEqual(e, {
		deltaTime = 0;
		type = "Midi";
		status = 0x80;
		data = "\60\80";
	});
end) (), "MIDI.Parser.parseTrack");

return nil;