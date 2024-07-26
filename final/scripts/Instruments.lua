Util  = require(workspace.scripts.Util);
Graph = require(workspace.scripts.Graph);

local PipeDreamInstruments = {
	["Guitar"] = {
		keys = {type = "range", track = "Guitar|Banjo", notes = {size = 16}};
		Params = {
			string1 = 0, holderAngle1 = 0;
			string2 = 0, holderAngle2 = 0;
			drumBounce = 0;
			marbles = {};
		};
	},
	["Bells"] = {
		keys = {type = "range", track = "Tubular Bells", notes = {size = 10}};
		
		animate = (function(seconds, cueTrack)
			local result = {
				angle = 0;
				marbles = {};
			};
			for _, cue in pairs(cueTrack) do
				local t = seconds - cue.seconds;
				result.angle = result.angle
				+	math.rad(4) * Graph.wave(t, 1.2, 0.3);
				Util.append(result.marbles, Graph.trajectory(t, {
					{-0.35, Vector3.new( 0.000, 11.000, 0), 28.083 },
					{ 0.00, Vector3.new(11.674, 37.716, 0), 35.675 },
					{ 0.80, Vector3.new( 2.470,  8.651, 0), nil    },
				})--[[, offset]]);
			end
			return result;
		end);

		apply = (function(params, model)
			print(params);
			-- model.bell:SetPrimaryPartCFrame(CFrame.Angles(params.angle, 0, 0));
			-- print(#params.marbles);
		end);
	},
	["Vibe"] = {
		keys = {type = "range", track = "Vibraphone", notes = {size = 40}};
		Params = {
			arm1 = 0, arm2 = 0, arm3 = 0;
			barBounce = 0, barGlow = 0;
			marbles = {};
		};
	},
	["Marimba"] = {
		keys = {type = "single", track = "Marimba", notes = {all = true}};
		Params = {
			bars = {};
			marbles = {};
		};
	},
	["Drums"] = {
		keys = {type = "list", track = "{10}", notes = {
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
			["WBlock Lo"] = {77}
		}};
		Params = {
			bounce = 0;
			marbles = {};
		};
	},
	["Cymbals"] = {
		keys = {type = "list", track = "{10}", notes = {
			["Crash 1"] = {49},
			["Crash 2"] = {57},
			["Splash"] = {55},
			["HiHat"] = {42, 46}
		}};
		Params = {
			angleX = 0;
			angleY = 0;
			marbles = {};
		};
	},

	-- Instrument positions are also categorized as 'keys' oddly enough.
	["Bell Position"] = {
		keys = {type = "single", track = "Tubular Bells", notes = {all = true}};
		Params = {
			height = 0;
		};
	},
	["Vibe Position"] = {
		keys = {type = "single", track = "Vibraphone", notes = {all = true}};
		Params = {
			height = 0;
		};
	},
	["HiHat Position"] = {
		keys = {type = "single", track = "{10}", notes = {42, 44, 46}};
		Params = {
			height = 0;
		};
	},
	["For-Way Position"] = {
		keys = {type = "single", track = "{10}", notes = {
			55, 56, 42, 44, 46, 76, 77
		}};
		Params = {
			angle = 0;
		};
	},
};

return PipeDreamInstruments;
