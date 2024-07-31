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
				local t, i = seconds - cue.seconds, cue.index;
				result.angle = result.angle
				+	math.rad(4) * Graph.wave(t, 1.2, 0.3);
				Util.append(result.marbles, Graph.trajectory(t, {
					{-0.35, Vector3.new( 0.000, 0, 11.000), 28.073 },
					{ 0.00, Vector3.new(11.674, 0, 37.716), 34.696 },
					{ 0.80, Vector3.new( 1.870, 0,  3.400), nil    },
				}),CFrame.new(-5.003, 0, -18.3) * CFrame.Angles(
					0, math.rad(Graph.lerp((i-1)/9, -40.5, 40.5)), 0
				));
			end
			return result;
		end);

		apply = (function(params, model) end);
	},
	["Vibe"] = {
		keys = {type = "range", track = "Vibraphone", notes = {size = 40}};

		animate = (function (seconds, cueTrack)
			local result = {
				arm1 = 0, arm2 = 0, arm3 = 0;
				barBounce = 0, barGlow = 0;
				marbles = {};
			};
			for _, cue in pairs(cueTrack) do
				local t, i = seconds - cue.seconds, cue.index;
				result.arm1 = result.arm1
				+	math.rad(3) * Graph.wave(t, 3.1, 1.3);
				result.arm2 = result.arm2
				+	math.rad(4) * Graph.wave(t, 2.8, 1.0);
				result.arm3 = result.arm3
				+	math.rad(3) * Graph.wave(t, 2.3, 1.5);
				result.barBounce = result.barBounce
				+	0.2 * Graph.wave(t,6,2);
				result.barGlow = result.barGlow
				+	(t > 0) and 0.8*math.exp(-t/0.2) or 0;
				Util.append(result.marbles, Graph.trajectory(t, {
					{-0.935, Vector3.new( 0.000, 0, 11.500), 33.356},
					{ 0.000, Vector3.new(12.472, 0, 16.347), 25.102},
					{ 0.768, Vector3.new(22.294, 0, 05.892), nil   },
				}), CFrame.new(-5.003, 0, -18.3) * CFrame.Angle(
					0, Graph.lerp((i-1)/39, 1.75*math.pi, -0.25*math.pi), 0
				));
			end
		end);

		apply = (function(params, model) end);
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
