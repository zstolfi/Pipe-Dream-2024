local testKeyDefs = {
	["Piano"] = {type = "range", track = "[1]", {from = 21, to = 108}},
	["All"]   = {type = "range", track = "*"  , {from = 0,  to = 127}},
};

local PipeDreamKeyDefs = {
	-- Simple key definitions:
	["Guitar"]  = {type = "range",  track = "Guitar"       , {size = 16}},
	["Bells"]   = {type = "range",  track = "Tubular Bells", {size = 10}},
	["Vibe"]    = {type = "range",  track = "Vibraphone"   , {size = 40}},
	["Marimba"] = {type = "single", track = "Marimba"      , {all = true}},
	["Drums"]   = {type = "list",   track = "Drumset", {
		["Bass"] = 36,
		["Snare"] = 38,
		["Crash 1"] = 49,
		["Crash 2"] = 57,
		["Tom 1"] = 41,
		["Tom 2"] = 43,
		["Tom 3"] = 45,
		["Tom 4"] = 47,
		["Tom 5"] = 48,
		["Tom 6"] = 50,
		-- Suckerpinch'd!
	}},
	["For-Way"] = {type = "list",   track = "Drumset", {
		["Splash"] = 55,
		["Cowbell"] = 56,
		["HiHat Close"] = 42,
		["HiHat Pedal"] = 44,
		["HiHat Open"] = 46,
		["WBlock Hi"] = 76,
		["WBlock Lo"] = 77,
	}},

	-- Instrument positions are also categorized as 'keys' oddly enough.
	["Vibe-Position"] = {
		type = "single", track = "Vibraphone", {all = true}
	},
	["Bell-Position"] = {
		type = "single", track = "Tubular Bells", {all = true}
	},
	["HiHat-Position"] = {
		type = "single", track = "Drumset", {42, 44, 46}
	},
	["For-Way-Position"] = {
		type = "single", track = "Drumset", {55, 56, 42, 44, 46, 76, 77}
	},
};

return testKeyDefs;