function check(condition, ...)
	if not condition then
		warn("~~~~~~~~~~~~ ERROR ~~~~~~~~~~~~");
		print(...);
		warn("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
		error("Execution halted.");
	end
end

-- '[{ args }] = nil' doesn't work, so we use '[{ args }] = Invalid'
Invalid = {};

function floatEqual(a,b) return a - b < 0.000001 end

function checkInstances(instances)
	for path, T in pairs(instances) do
		local instance = game;
		-- Iterate through everything between the .'s
		for name in path:gmatch("[^%.]+") do
			instance = instance:FindFirstChild(name);
			check(instance ~= nil
			,     string.format("Missing %s.", path));
		end
		check(instance:IsA(T)
		,     string.format("Missing %s : %s.", path, T));
	end
end

function checkExistence(t, members)
	for fullPath, T in pairs(members) do
		-- Ignore the name of 't' itself.
		local path = fullPath:match("^[^%.]+%.(.+)");

		local member = t;
		for name in path:gmatch("[^%.]+") do
			member = member[name];
			check(member ~= nil
			,     string.format("Missing %s.", path));
		end
		check(type(member) == T
		,     string.format("Missing %s : %s.", path, T));
	end
end

--[[ Object Tree / Class Checks ]]----------------------------------------------
checkInstances({
	["Workspace.scripts"]           = "Folder",
	["Workspace.scripts.Util"]      = "ModuleScript",
	["Workspace.scripts.Type"]      = "ModuleScript",
	["Workspace.scripts.MIDI"]      = "ModuleScript",
	["Workspace.scripts.CueMapper"] = "ModuleScript",
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
		,     "Util.tableEqual", args);
	end
end

do -- deepCopy
	local cases = {
		[{ {} }] = true,
		[{ {1,2,3,{4,5}, size = 23, pitch = 0.24, {{42}}} }] = true,
	};

	for args, result in pairs(cases) do
		local t = unpack(args);
		local u = Util.deepCopy(t);
		check(t ~= u and Util.tableEqual(t,u)
		,     "Util.deepCopy", args);
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
		check(Util.tableEqual(Util.sort(unpack(args)), result)
		,     "Util.tableEqual", args);
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
		,     "Util.findUntil", args);
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
		check(Util.tableEqual(Util.Set(unpack(args)), result)
		,     "Util.Set", args);
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

		[{ "a"      }] = Invalid,
		[{ "="      }] = Invalid,
		[{ "==="    }] = Invalid,
		[{ "12=456" }] = Invalid,
		[{ "a"      }] = Invalid,
		[{ "$"      }] = Invalid,
	};

	for args, result in pairs(cases) do
		if result == Invalid then result = nil; end
		check(Util.parseBase64(unpack(args)) == result
		,     "Util.parseBase64", args);
	end
end

do -- parseUint
	local cases = {
		[{ ""                 }] = Invalid,
		[{ "\0"               }] = 0,
		[{ "\x10\x00"         }] = 0x1000,
		[{ "\xFF\xFF"         }] = 0xFFFF,
		[{ "\xFF\xFF\xFF\xFF" }] = 0xFFFFFFFF,
	};

	for args, result in pairs(cases) do
		if result == Invalid then result = nil; end
		check(Util.parseUint(unpack(args)) == result
		,     "Util.parseUint", args);
	end
end

do -- parseSint
	local cases = {
		[{ ""                 }] = Invalid,
		[{ "\0"               }] = 0,
		[{ "\x7F"             }] = 127,
		[{ "\x80"             }] = -128,
		[{ "\xFF"             }] = -1,
		[{ "\x7F\xFF"         }] = 0x7FFF,
		[{ "\x80\x00"         }] = -0x8000,
		[{ "\x80\x01"         }] = -0x7FFF,
		[{ "\xFF\xFF"         }] = -1,
		[{ "\x00\x00\x00\x00" }] = 0,
		[{ "\x76\x54\x32\x10" }] = 0x76543210,
		[{ "\x7F\xFF\xFF\xFF" }] = 0x7FFFFFFF,
		[{ "\x80\x00\x00\x00" }] = -0x80000000,
		[{ "\xFF\xFF\xFF\xFF" }] = -1,
	};

	for args, result in pairs(cases) do
		if result == Invalid then result = nil; end
		check(Util.parseSint(unpack(args)) == result
		,     "Util.parseSint", args);
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

do -- MIDI.Parser:peek
	local cases = {
		[{ "abc", 0 }] = {""   , {i = 1}},
		[{ "abc", 1 }] = {"a"  , {i = 1}},
		[{ "abc", 3 }] = {"abc", {i = 1}},
	};

	for args, result in pairs(cases) do
		local parser = Type.new(MIDI.Parser);
		parser.bytes = args[1];
		local b = parser:peek(args[2]);
		check(b == result[1] and Util.tableSubset(result[2], parser)
		,     "MIDI.Parser:peek", args);
	end
end

do -- MIDI.Parser:read
	local cases = {
		[{ "abc", 0 }] = {""   , {i = 1}},
		[{ "abc", 1 }] = {"a"  , {i = 2}},
		[{ "abc", 3 }] = {"abc", {i = 4}},
	};

	for args, result in pairs(cases) do
		local parser = Type.new(MIDI.Parser);
		parser.bytes = args[1];
		local b = parser:read(args[2]);
		check(b == result[1] and Util.tableSubset(result[2], parser)
		,     "MIDI.Parser:read", args);
	end
end

do -- MIDI.Parser:readVarLen
	local cases = {
		[{ "\x00"             }] = {0x00000000,  {i = 2}},
		[{ "\x40"             }] = {0x00000040,  {i = 2}},
		[{ "\x7F"             }] = {0x0000007F,  {i = 2}},
		[{ "\x81\x00"         }] = {0x00000080,  {i = 3}},
		[{ "\xC0\x00"         }] = {0x00002000,  {i = 3}},
		[{ "\xFF\x7F"         }] = {0x00003FFF,  {i = 3}},
		[{ "\x81\x80\x00"     }] = {0x00004000,  {i = 4}},
		[{ "\xC0\x80\x00"     }] = {0x00100000,  {i = 4}},
		[{ "\xFF\xFF\x7F"     }] = {0x001FFFFF,  {i = 4}},
		[{ "\x81\x80\x80\x00" }] = {0x00200000,  {i = 5}},
		[{ "\xC0\x80\x80\x00" }] = {0x08000000,  {i = 5}},
		[{ "\xFF\xFF\xFF\x7F" }] = {0x0FFFFFFF,  {i = 5}},
	};

	for args, result in pairs(cases) do
		local parser = Type.new(MIDI.Parser);
		parser.bytes = args[1];
		local b = parser:readVarLen();
		check(b == result[1] and Util.tableSubset(result[2], parser)
		,     "MIDI.Parser:readVarLen", args); 
	end
end

do -- MIDI.Parser:parseTickRate
	local enc = function(fps, div) return -256*fps + div; end;

	local cases = {
		[{ 0x0001 }] = {1    , "1/4 note"},
		[{ 0x0060 }] = {96   , "1/4 note"},
		[{ 0x01E0 }] = {480  , "1/4 note"},
		[{ 0x7FFF }] = {32767, "1/4 note"},
		[{ enc(24, 1)   }] = {24        , "second"},
		[{ enc(25, 1)   }] = {25        , "second"},
		[{ enc(30, 1)   }] = {30        , "second"},
		[{ enc(29, 1)   }] = {30/1.001  , "second"},
		[{ enc(24, 25)  }] = {600       , "second"},
		[{ enc(25, 24)  }] = {600       , "second"},
		[{ enc(30, 20)  }] = {600       , "second"},
		[{ enc(29, 20)  }] = {600/1.001 , "second"},
		[{ enc(25, 40)  }] = {1000      , "second"},
		[{ enc(24, 255) }] = {6120      , "second"},
		[{ enc(25, 255) }] = {6375      , "second"},
		[{ enc(30, 255) }] = {7650      , "second"},
		[{ enc(29, 255) }] = {7650/1.001, "second"},
	};

	for args, result in pairs(cases) do
		local parser = Type.new(MIDI.Parser);
		check(Util.tableEqual({parser:parseTickRate(unpack(args))}, result)
		,     "MIDI.Parser:parseTickRate", args);
	end
end

do -- MIDI.Parser:parseHeader
	local cases = {
		[{ "MThd".."\0\0\0\6".."\0\1".."\0\1".."\x01\xE0" }] = {
			format = 1;
			trackCount = 1;
			tickRate = 480;
			divisionType = "1/4 note";
		},
		[{ "MThd".."\0\0\0\6".."\0\1".."\xFF\xFF".."\x7F\xFF" }] = {
			format = 1;
			trackCount = 0xFFFF;
			tickRate = 0x7FFF;
			divisionType = "1/4 note";
		},
		[{ "QSCV".."\0\0\0\6".."\0\1".."\0\1".."\x01\xE0" }] = Invalid,
		[{ "MThd".."\1\2\3\4".."\0\1".."\0\1".."\x01\xE0" }] = Invalid,
		[{ "MThd".."\0\0\0\6".."\0\4".."\0\1".."\x01\xE0" }] = Invalid,
		[{ "MThd".."\0\0\0\6".."\0\1".."\0\0".."\x01\xE0" }] = Invalid,
		[{ "MThd".."\0\0\0\6".."\0\1".."\0\1".."\x00\x00" }] = Invalid,
		[{ "MThd".."\0\0\0\6".."\0\1".."\0\1".."\xE8\x00" }] = Invalid,
		[{ "MThd".."\0\0\0\6".."\0\1".."\0\1".."\xE7\x00" }] = Invalid,
		[{ "MThd".."\0\0\0\6".."\0\1".."\0\1".."\xE3\x00" }] = Invalid,
		[{ "MThd".."\0\0\0\6".."\0\1".."\0\1".."\xE2\x00" }] = Invalid,
	};

	for args, result in pairs(cases) do
		local parser = Type.new(MIDI.Parser);
		parser.bytes = args[1];
		parser:parseHeader();
		check((result ~= Invalid)
			and (not parser.error
			     and Util.tableSubset(result, parser.result.header))
			or  (not not parser.error)
		,     "MIDI.Parser:parseHeader", args);
	end
end

do -- MIDI.Parser:parseTrack
	local cases = {
		[{ "MTrk".."\0\0\0\1".."\x00\xFF\x2F\x00" }] = {i = 13, count = 1},
		[{ "MTrk".."\0\0\0\1".."\x00\x80\60\80"   }] = Invalid,
		[{ "xyzw".."\0\0\0\1".."\x00\xFF\x2F\x00" }] = Invalid,
		[{ "MTrk".."\0\0\0\0"                     }] = Invalid,
	};

	for args, result in pairs(cases) do
		local parser = Type.new(MIDI.Parser);
		parser.bytes = args[1];
		parser:parseTrack();
		check((result ~= Invalid)
			and (not parser.error
			     and parser.i == result.i
			     and #parser.result.tracks == 1
			     and #parser.result.tracks[1].events == result.count)
			     and parser.result.tracks[1].eventCount == result.count
			or  (not not parser.error)
		,     "MIDI.Parser:parseTrack", args);
	end
end

do -- MIDI.Parser:parseEvent
	local cases = {
		[{ "\x00\x80\60\80" }] = {i = 5, event = {
			deltaTime = 0;
			type = "Midi";
			status = 0x80;
			data = "\60\80";
		}},
		[{ "\x00\xF0\x00" }] = {i = 4, event = {
			deltaTime = 0;
			type = "SysEx";
			status = 0xF0;
			data = "";
		}},
		[{ "\x00\xF7\x00" }] = {i = 4, event = {
			deltaTime = 0;
			type = "SysEx";
			status = 0xF7;
			data = "";
		}},
		[{ "\x00\xFF\x01\6Hello!" }] = {i = 11, event = {
			deltaTime = 0;
			type = "Meta\x01";
			status = 0xFF;
			data = "Hello!";
		}},
		[{ "\x00\xFF\x01\7Hello!\0" }] = {i = 12, event = {
			deltaTime = 0;
			type = "Meta\x01";
			status = 0xFF;
			data = "Hello!";
		}},
	};

	for args, result in pairs(cases) do
		local parser = Type.new(MIDI.Parser);
		parser.bytes = args[1];
		local e = parser:parseEvent();
		check((result ~= Invalid)
			and (not parser.error
			     and parser.i == result.i
			     and Util.tableSubset(result.event, e))
			or  (not not parser.error)
		,     "MIDI.Parser:parseEvent", args);
	end
end

return nil;