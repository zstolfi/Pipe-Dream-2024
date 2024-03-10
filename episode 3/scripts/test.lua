function check(condition, message)
	if not condition then error(message); end
end

--[[ Object Tree / Class Checks ]]----------------------------------------------
check(workspace:FindFirstChild("scripts")
,     "No 'workspace.scripts' Folder.");

-- Util.lua
check(workspace.scripts:FindFirstChild("Util")
and   workspace.scripts:FindFirstChild("Util"):IsA("ModuleScript")
,     "No 'workspace.scripts.Util ModuleScript'.");

check(type(require(workspace.scripts.Util)) == "table"
,     "Table not returned from 'workspace.scripts.Util'.");

-- Type.lua
check(workspace.scripts:FindFirstChild("Type")
and   workspace.scripts:FindFirstChild("Type"):IsA("ModuleScript")
,     "No 'workspace.scripts.Type' ModuleScript.");

check(type(require(workspace.scripts.Type)) == "table"
,     "Table not returned from 'workspace.scripts.Type'.");

-- MIDI.lua
check(workspace.scripts:FindFirstChild("MIDI")
and   workspace.scripts:FindFirstChild("MIDI"):IsA("ModuleScript")
,     "No 'workspace.scripts.MIDI ModuleScript'.");

check(type(require(workspace.scripts.MIDI)) == "table"
,     "Table not returned from 'workspace.scripts.MIDI'.");

-- CueMapper.lua
check(workspace.scripts:FindFirstChild("CueMapper")
and   workspace.scripts:FindFirstChild("CueMapper"):IsA("ModuleScript")
,     "No 'workspace.scripts.CueMapper' ModuleScript.");

check(type(require(workspace.scripts.CueMapper)) == "table"
,     "Table not returned from 'workspace.scripts.CueMapper'.");

--[[ Util Checks ]]-------------------------------------------------------------
Util = require(workspace.scripts.Util);

-- tableEqual
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

-- deepCopy
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

check(not (function()
	local t, result
	= {1,2,2,3}
	, {1,2,3};
	Util.sort(t, Util.less);
	return Util.tableEqual(t, result);
end) (), "Util.sort");

check((function()
	local t, result
	= {{x= 1, y= 1}, {x=-1, y= 1}, {x=-1, y=-1}, {x= 1, =-1}}
	, {{x=-1, y=-1}, {x= 1, y=-1}, {x= 1, y= 1}, {x=-1, = 1}};
	Util.sort(t, function(a, b)
		return math.atan2(a.y, a.x) < math.atan2(b.y, b.x)
	end);
	return Util.tableEqual(t, result);
end) (), "Util.sort");

-- findUntil
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
	}
	return Util.findUntil(t, function(x) return x > i; end);
end) (), "Util.findUntil");

check((function()
	local I, O = true, false;
	local t_result_table = {
		{{I,I,I}, 1},
		{{O,I,I}, 2},
		{{O,O,I}, 3},
		{{O,O,O}, 3},
	}
	return Util.findUntil(t, function(x) return x; end);
end) (), "Util.findUntil");

-- setFrom
check(Util.setFrom({}) == {}
,     "Util.setFrom");

check(Util.setFrom({1,2,3}) == {[1]=true, [2]=true, [3]=true}
,     "Util.setFrom");

check(Util.setFrom({nil}) == {}
,     "Util.setFrom");

check(Util.setFrom({1,1}) == {[1]=true}
,     "Util.setFrom");

check(Util.setFrom({false,true}) == {[false]=true, [true]=true}
,     "Util.setFrom");

-- parseBase64
check(Util.parseBase64("") == ""
,     "Util.parseBase64");

check(Util.parseBase64("\0") == "AA=="
,     "Util.parseBase64");

check(Util.parseBase64("\0\0") == "AAA="
,     "Util.parseBase64");

check(Util.parseBase64("\0\0\0") == "AAAA"
,     "Util.parseBase64");

check(Util.parseBase64("MThd") == "TVRoZA=="
,     "Util.parseBase64");

check(Util.parseBase64("MThd\0\0\0\6") == "TVRoZAAAAAY="
,     "Util.parseBase64");

check(not Util.parseBase64("a") ~= nil
,     "Util.parseBase64");

check(not Util.parseBase64("=") ~= nil
,     "Util.parseBase64");

check(not Util.parseBase64("===") ~= nil
,     "Util.parseBase64");

check(not Util.parseBase64("12=456") ~= nil
,     "Util.parseBase64");

check(not Util.parseBase64("a") ~= nil
,     "Util.parseBase64");

check(not Util.parseBase64("$") ~= nil
,     "Util.parseBase64");

-- parseUint
check(not Util.parseUint("") ~= nil
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
check(not Util.parseSint("") ~= nil
,     "Util.parseSint");

check(Util.parseSint("\0") == 0
,     "Util.parseSint");

check(Util.parseSint("\x7F") == 127
,     "Util.parseSint");

check(Util.parseSint("\x80") == 128
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

check(Util.parseSint("\x80\x00\x00\x00") == -0x8FFFFFFF
,     "Util.parseSint");

check(Util.parseSint("\xFF\xFF\xFF\xFF") == -1
,     "Util.parseSint");

return nil;