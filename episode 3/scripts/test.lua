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

return nil;