local PipeDreamInstruments = {
	-- Simple key definitions:
	["Guitar"]  = {type = "range",  track = "Guitar|Banjo" , {size = 16},
		Params = {
			string1 = 0, holderAngle1 = 0;
			string2 = 0, holderAngle2 = 0;
			drumBounce = 0;
			marbles = {};
		}
	},
	["Bells"]   = {type = "range",  track = "Tubular Bells", {size = 10},
		Params = {
			angle = 0;
			marbles = {};
		}
	},
	["Vibe"]    = {type = "range",  track = "Vibraphone", {size = 40},
		Params = {
			arm1 = 0, arm2 = 0, arm3 = 0;
			barBounce = 0, barGlow = 0;
			marbles = {};
		}
	},
	["Marimba"] = {type = "single", track = "Marimba", {all = true},
		Params = {
			bars = {};
			marbles = {};
		}
	},
	["Drums"]   = {type = "list",   track = "{10}", {
		["Bass"] = {36},
		["Snare"] = {38},
		["Tom 1"] = {41},
		["Tom 2"] = {43},
		["Tom 3"] = {45},
		["Tom 4"] = {47},
		["Tom 5"] = {48},
		["Tom 6"] = {50},
		-- Suckerpinch'd!
		["Cowbell"] = {56},
		["WBlock Hi"] = {76},
		["WBlock Lo"] = {77}},
		Params = {
			bounce = 0;
			marbles = {};
		}
	},
	["Cymbals"]   = {type = "list",   track = "{10}", {
		["Crash 1"] = {49},
		["Crash 2"] = {57},
		["Splash"] = {55},
		["HiHat"] = {42, 46}},
		Params = {
			angleX = 0;
			angleY = 0;
			marbles = {};
		}
	},

	-- Instrument positions are also categorized as 'keys' oddly enough.
	["Bell Position"] = {
		type = "single", track = "Tubular Bells", {all = true},
		Params = {
			height = 0;
		}
	},
	["Vibe Position"] = {
		type = "single", track = "Vibraphone", {all = true},
		Params = {
			height = 0;
		}
	},
	["HiHat Position"] = {
		type = "single", track = "{10}", {42, 44, 46},
		Params = {
			height = 0;
		}
	},
	["For-Way Position"] = {
		type = "single", track = "{10}", {55, 56, 42, 44, 46, 76, 77},
		Params = {
			angle = 0;
		}
	},
};

return PipeDreamInstruments;
