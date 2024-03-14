function check(condition, message)
	if not condition then error(message); end
end

function floatEqual(a,b) return a - b < 0.001 end

function checkInstances(instances)
	for path, type in pairs(instances) do
		local instance = game;
		-- Iterate through everything between the .'s
		for name in path:gmatch("[^%.]+") do
			instance = instance:FindFirstChild(name);
			check(instance ~= nil
			,     string.format("Missing %s.", path));
		end
		check(instance:IsA(type)
		,     string.format("Missing %s : %s.", path, type));
	end
end

function checkExistence(t, members)
	for fullPath, type in pairs(members) do
		-- Ignore the name of 't' itself.
		local path = fullPath:match("^[^%.]+%.(.+)");

		local member = t;
		for name in path:gmatch("[^%.]+") do
			member = t[name];
			check(member ~= nil and type(member) == type
			,     string.format("Missing %s.", path));
		end
		check(type(member) == type
		,     string.format("Missing %s : %s.", path, type));
	end
end

--[[ Object Tree / Class Checks ]]----------------------------------------------
checkInstances({
	["Workspace.scripts"]   = "Folder",
	["Workspace.Util"]      = "ModuleScript",
	["Workspace.Type"]      = "ModuleScript",
	["Workspace.MIDI"]      = "ModuleScript",
	["Workspace.CueMapper"] = "ModuleScript",
});

--[[ Util Checks ]]-------------------------------------------------------------
Util = require(workspace.scripts.Util);

checkExistence(Util, {
	["Util.less"]        = "function",
	["Util.equal"]       = "function",
	["Util.identity"]    = "function",
	["Util.tableEqual"]  = "function",
	["Util.deepCopy"]    = "function",
	["Util.sort"]        = "function",
	["Util.allOf"]       = "function",
	["Util.anyOf"]       = "function",
	["Util.noneOf"]      = "function",
	["Util.findUntil"]   = "function",
	["Util.Set"]         = "function",
	["Util.parseBase64"] = "function",
	["Util.parseUint"]   = "function",
	["Util.parseSint"]   = "function",
});

do -- tableEqual
	local cases = {
		[{ {}                   , {}                    }] = true,
		[{ {1,2,3}              , {1,2,3}               }] = true,
		[{ {"abcd"}             , {"abcd"}              }] = true,
		[{ {1,2,3}              , {[1]=1, [2]=2, [3]=3} }] = true,
		[{ {1,2,{3,4},5}        , {1,2,{3,4},5}         }] = true,
		[{ {time = 0}           , {time = 0}            }] = true,
		[{ {{{{{"A"}}}}}        , {{{{{"A"}}}}}         }] = true,
		[{ {[false]=0, [true]=1}, {[false]=0, [true]=1} }] = true,

		[{ {}           , {1}              }] = false,
		[{ {1}          , {2}              }] = false,
		[{ {42}         , {"A"}            }] = false,
		[{ {nil, 2}     , {[2]=2}          }] = false,
		[{ {1,2,3,nil,5}, {1,2,3, [5]=5}   }] = false,
		[{ {a=1, b=1}   , {a=1, b=1, c=1}  }] = false,
		[{ {a=1, b=1    , c=1}, {a=1, b=1} }] = false,
	};

	for args, result in pairs(cases) do
		check(Util.tableEqual(unpack(args)) == result
		,     "Util.tableEqual");
	end
end

do -- deepCopy
	local cases = {
		[{ {} }] == true,
		[{ {1,2,3,{4,5}, size = 23, pitch = 0.24, {{42}}} }] == true,
	};

	for args, result in pairs(cases) do
		local t = unpack(args);
		local u = Util.deepCopy(t);
		check(t ~= u and Util.tableEqual(t,u)
		,     "Util.deepCopy");
	end
end

do -- sort
	local cases = {
		[{ {}, Util.less }]
		=  {},
		[{ {3,2,1}, Util.less }]
		=  {1,2,3},
		[{ {6,2,8,3,1,5,0,7,9,4}, function(a, b) return a > b; end }]
		=  {9,8,7,6,5,4,3,2,1,0},
		[{ {"x","y","z","w"}, Util.less }]
		=  {"w","x","y","z"},
		[{ {"aaa","bb","c",""}, function(a, b) return #a < #b; end }]
		=  {"","c","bb","aaa"},
		[{ {{x= 1, y= 1}, {x=-1, y= 1}, {x=-1, y=-1}, {x= 1, y=-1}},
			function(a, b)
				return math.atan2(a.y, a.x) < math.atan2(b.y, b.x)
			end }]
		=  {{x=-1, y=-1}, {x= 1, y=-1}, {x= 1, y= 1}, {x=-1, y= 1}},
	};

	for args, result in pairs(cases) do
		check(Util.tableEqual(Util.sort(unpack(args)))
		,     "Util.tableEqual");
	end
end

-- allOf
check(Util.allOf({true , true }, Util.identity) == true , "Util.allOf");
check(Util.allOf({false, true }, Util.identity) == false, "Util.allOf");
check(Util.allOf({false, false}, Util.identity) == false, "Util.allOf");
check(Util.allOf({            }, Util.identity) == true , "Util.allOf");

-- anyOf
check(Util.anyOf({true , true }, Util.identity) == true , "Util.anyOf");
check(Util.anyOf({false, true }, Util.identity) == true , "Util.anyOf");
check(Util.anyOf({false, false}, Util.identity) == false, "Util.anyOf");
check(Util.anyOf({            }, Util.identity) == false, "Util.anyOf");

-- noneOf
check(Util.noneOf({true , true }, Util.identity) == false, "Util.noneOf");
check(Util.noneOf({false, true }, Util.identity) == false, "Util.noneOf");
check(Util.noneOf({false, false}, Util.identity) == true , "Util.noneOf");
check(Util.noneOf({            }, Util.identity) == true , "Util.noneOf");

do -- findUntil
	local cases = {
		[{ {}, Util.identity }] = 1,
		[{ {1,3,5}, function(x) return x > 0; end }] = 1,
		[{ {1,3,5}, function(x) return x > 1; end }] = 1,
		[{ {1,3,5}, function(x) return x > 2; end }] = 1,
		[{ {1,3,5}, function(x) return x > 3; end }] = 2,
		[{ {1,3,5}, function(x) return x > 4; end }] = 2,
		[{ {1,3,5}, function(x) return x > 5; end }] = 3,
		[{ {1,3,5}, function(x) return x > 6; end }] = 3,
		[{ {true ,true ,true }, Util.identity }] = 1,
		[{ {false,true ,true }, Util.identity }] = 1,
		[{ {false,false,true }, Util.identity }] = 2,
		[{ {false,false,false}, Util.identity }] = 3,
	};

	for args, result in pairs(cases) do
		check(Util.findUntil(unpack(args)) == result
		,     "Util.findUntil");
	end
end

do -- Set constructor
	local cases = {
		[{ {}           }] = {},
		[{ {nil}        }] = {},
		[{ {1,1}        }] = {[1]=true},
		[{ {1,2,3}      }] = {[1]=true, [2]=true, [3]=true},
		[{ {false,true} }] = {[false]=true, [true]=true},
	};

	for args, result in pairs(cases) do
		check(Util.tableEqual(Util.set(unpack(args)), result)
		,     "Util.Set");
	end
end

do -- parseBase64
	local cases = {
		[{ ""             }] = "",
		[{ "AA=="         }] = "\0",
		[{ "AAA="         }] = "\0\0",
		[{ "AAAA"         }] = "\0\0\0",
		[{ "TVRoZA=="     }] = "MThd",
		[{ "TVRoZAAAAAY=" }] = "MThd\0\0\0\6",

		[{ "a"      }] = nil,
		[{ "="      }] = nil,
		[{ "==="    }] = nil,
		[{ "12=456" }] = nil,
		[{ "a"      }] = nil,
		[{ "$"      }] = nil,
	};

	for args, result in pairs(cases) do
		check(Util.parseBase64(unpack(args)) == result
		,     "Util.parseBase64");
	end
end

do -- parseUint
	local cases = {
		[{ ""                 }] = nil
		[{ "\0"               }] = 0
		[{ "\x10\x00"         }] = 0x1000
		[{ "\xFF\xFF"         }] = 0xFFFF
		[{ "\xFF\xFF\xFF\xFF" }] = 0xFFFFFFFF
	};

	for args, result in pairs(cases) do
		check(Util.parseUint(unpack(args)) == result
		,     "Util.parseUint");
	end
end

do -- parseSint
	local cases = {
		[{ ""                 }] = nil
		[{ "\0"               }] = 0
		[{ "\x7F"             }] = 127
		[{ "\x80"             }] = -128
		[{ "\xFF"             }] = -1
		[{ "\x7F\xFF"         }] = 0x7FFF
		[{ "\x80\x00"         }] = -0x8000
		[{ "\x80\x01"         }] = -0x7FFF
		[{ "\xFF\xFF"         }] = -1
		[{ "\x00\x00\x00\x00" }] = 0
		[{ "\x76\x54\x32\x10" }] = 0x76543210
		[{ "\x7F\xFF\xFF\xFF" }] = 0x7FFFFFFF
		[{ "\x80\x00\x00\x00" }] = -0x80000000
		[{ "\xFF\xFF\xFF\xFF" }] = -1
	};

	for args, result in pairs(cases) do
		check(Util.parseSint(unpack(args)) == result
		,     "Util.parseSint");
	end
end

--[[ Type Checks ]]-------------------------------------------------------------
Type = require(workspace.scripts.Type);

checkExistence(Type, {
	["Type.new"] = "function",
});

--[[ MIDI Checks ]]-------------------------------------------------------------
MIDI = require(workspace.scripts.MIDI);

checkExistence(MIDI, {
	["MIDI.statusLength"]         = "table",
	["MIDI.Parser"]               = "table",
	["MIDI.Parser.parse"]         = "function",
	["MIDI.Parser.parseHeader"]   = "function",
	["MIDI.Parser.parseTickRate"] = "function",
	["MIDI.Parser.parseTrack"]    = "function",
	["MIDI.Parser.parseEvent"]    = "function",
	["MIDI.Parser.peek"]          = "function",
	["MIDI.Parser.read"]          = "function",
	["MIDI.Parser.readUint"]      = "function",
	["MIDI.Parser.readSint"]      = "function",
	["MIDI.Parser.readVarLen"]    = "function",
});

-- MIDI.statusLength
check(MIDI.statusLength[0x8] == 2
and   MIDI.statusLength[0x9] == 2
and   MIDI.statusLength[0xA] == 2
and   MIDI.statusLength[0xB] == 2
and   MIDI.statusLength[0xC] == 1
and   MIDI.statusLength[0xD] == 1
and   MIDI.statusLength[0xE] == 2
,     "MIDI.statusLength");

-- MIDI.Parser.peek
check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "abc";
	local b = parser:peek(1);
	return b == "a" and parser.i == 1;
end) (), "MIDI.Parser.peek");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "abc";
	local b = parser:peek(3);
	return b == "abc" and parser.i == 1;
end) (), "MIDI.Parser.peek");

-- MIDI.Parser.read
check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "abc";
	local b = parser:read(1);
	return b == "a" and parser.i == 2;
end) (), "MIDI.Parser.read");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "abc";
	local b = parser:read(3);
	return b == "abc" and parser.i == 4;
end) (), "MIDI.Parser.read");

-- MIDI.Parser.readVarLen
check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "\x00";
	local n = parser:readVarLen();
	return n == 0x00000000 and parser.i == 2;
end) (), "MIDI.Parser.readVarLen");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "\x40";
	local n = parser:readVarLen();
	return n == 0x00000040 and parser.i == 2;
end) (), "MIDI.Parser.readVarLen");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "\x7F";
	local n = parser:readVarLen();
	return n == 0x0000007F and parser.i == 2;
end) (), "MIDI.Parser.readVarLen");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "\x81\x00";
	local n = parser:readVarLen();
	return n == 0x00000080 and parser.i == 3;
end) (), "MIDI.Parser.readVarLen");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "\xC0\x00";
	local n = parser:readVarLen();
	return n == 0x00002000 and parser.i == 3;
end) (), "MIDI.Parser.readVarLen");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "\xFF\x7F";
	local n = parser:readVarLen();
	return n == 0x00003FFF and parser.i == 3;
end) (), "MIDI.Parser.readVarLen");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "\x81\x80\x00";
	local n = parser:readVarLen();
	return n == 0x00004000 and parser.i == 4;
end) (), "MIDI.Parser.readVarLen");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "\xC0\x80\x00";
	local n = parser:readVarLen();
	return n == 0x00100000 and parser.i == 4;
end) (), "MIDI.Parser.readVarLen");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "\xFF\xFF\x7F";
	local n = parser:readVarLen();
	return n == 0x001FFFFF and parser.i == 4;
end) (), "MIDI.Parser.readVarLen");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "\x81\x80\x80\x00";
	local n = parser:readVarLen();
	return n == 0x00200000 and parser.i == 5;
end) (), "MIDI.Parser.readVarLen");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "\xC0\x80\x80\x00";
	local n = parser:readVarLen();
	return n == 0x08000000 and parser.i == 5;
end) (), "MIDI.Parser.readVarLen");

check((function()
	local parser = Type.new(MIDI.Parser);
	parser.bytes = "\xFF\xFF\xFF\x7F";
	local n = parser:readVarLen();
	return n == 0x0FFFFFFF and parser.i == 5;
end) (), "MIDI.Parser.readVarLen");

-- MIDI.Parser.parseTickRate
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