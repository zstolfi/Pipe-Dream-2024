Util  = require(workspace.scripts.Util);
Graph = require(workspace.scripts.Graph);

local PipeDreamInstruments = {
	["Guitar"] = {
		keys = {type = "range", track = "Guitar|Banjo", notes = {size = 16}};
		
		animate = (function(seconds, cueTrack)
			local result = {
				string1 = 0, holderAngle1 = 0;
				string2 = 0, holderAngle2 = 0;
				drumBounce = 0;
				marbles = {};
			};
			for _, cue in pairs(cueTrack) do
				local t, i = seconds - cue.seconds, cue.index;
				result.string1 = result.string1
				+	Graph.wave(t-0.405, 60, 10);
				result.string2 = result.string1
				+	Graph.wave(t-0.000, 60, 10);
				result.holderAngle1 = result.holderAngle1
				+	math.rad(9) * Graph.wave(t-0.405, 10, 13);
				result.holderAngle2 = result.holderAngle2
				+	math.rad(9) * Graph.wave(t-0.000, 10, 13);
				result.drumBounce = result.drumBounce
				+	0.2 * Graph.wave(t, 10, 13);
				Util.append(result.marbles, Graph.trajectory(t, {
					{-0.817, Vector3.new(39.766, 24.105, 0), 30.773},
					{ 0.000, Vector3.new(22.898, 14.269, 0), 17.769},
					{ 0.405, Vector3.new(38.135, 13.409, 0), 11.606},
					{ 0.608, Vector3.new(30.953,  8.653, 0), 11.107},
					{ 1.092, Vector3.new(35.438,  3.636, 0), nil   },
				}, CFrame.new(47.006, 1.293, 26.2)
				*	CFrame.new((i-1)//12 * -25.081, 0, (i-1)%12 * -4.4)
				));
			end
			return result;
		end);

		apply = (function(params, model) end);
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
					{-0.350, Vector3.new( 0.000, 11.000, 0), 28.073 },
					{ 0.000, Vector3.new(11.674, 37.716, 0), 34.696 },
					{ 0.800, Vector3.new( 1.870,  3.400, 0), nil    },
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
					{-0.935, Vector3.new( 0.000, 11.500, 0), 33.356},
					{ 0.000, Vector3.new(12.472, 16.347, 0), 25.102},
					{ 0.768, Vector3.new(22.294,  5.892, 0), nil   },
				}), CFrame.new(-5.003, 0, -18.3) * CFrame.Angle(
					0, Graph.lerp((i-1)/39, 1.75*math.pi, -0.25*math.pi), 0
				));
			end
			return result;
		end);

		apply = (function(params, model) end);
	},
	["Marimba"] = {
		keys = {type = "single", track = "Marimba", notes = {all = true}};
		
		animate = (function (seconds, cueTrack)
			local result = {
				bars = {};
				marbles = {};
			};
			for _, cue in pairs(cueTrack) do
				local t, p = seconds - cue.seconds, cue.pitch;
				if -2.4 <= t and t <= 2.4 then
					local u = Graph.map(t, -2.4, 2.4, 0.488, 0.012);
					Util.append(result.bars, {
						length = Graph.map(p, 36, 79, 6.919, 1.519);
						bounce = Graph.wave(t, 6, 5) * 0.4;
						position = 28.075 * Graph.roundedSquare(0.263, u)
						+	Vector2.new(-44.15, 2.404);
						normal = Graph.roundedSquare_normal(0.263, u);
					});
				end
				Util.append(result.marbles, Graph.trajectory(t, {
					{-0.534, Vector3.new(-28.674, 33.496, 29.193), 39.001},
					{ 0.000, Vector3.new(-44.150, 33.120, 17.093), 34.271},
					{ 0.601, Vector3.new(-56.652, 18.837,  7.318), nil   },
				}));
			end
			return result;
		end);

		apply = (function(params, model) end);
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

		animate = (function (seconds, cueTrack)
			local result = {
				bounce = 0;
				marbles = {};
			};
			for _, cue in pairs(cueTrack) do
				local t, name = seconds - cue.seconds, cue.keyName;
				local d = ({
					["Bass"]  = {{-0.668, 0.185},
						{-39.388, 12.414,  4.152, 22.843},
						{-39.388,  3.804, -1.678,  9.300},
						{Graph.wave(t, 8,  8) * -0.20, 0.30}},
					["Snare"] = {{-0.701, 0.401},
						{-44.303, 19.382,  1.761, 28.418},
						{-45.139, 24.622, 15.990, 25.465},
						{Graph.wave(t, 8, 12) * -0.12, 1.00}},
					["Tom 1"] = {{-0.834, 0.367},
						{-53.528, 20.116, -2.749, 28.604},
						{-59.152, 23.041,  9.610, 24.181},
						{Graph.wave(t, 8, 10) * -0.15, 0.05}},
					["Tom 2"] = {{-0.734, 0.401},
						{-51.893, 20.116,  4.851, 27.879},
						{-57.348, 22.288, 21.335, 24.424},
						{Graph.wave(t, 8, 10) * -0.15, 0.05}},
					["Tom 3"] = {{-0.734, 0.534},
						{-48.677, 22.105,  9.811, 27.226},
						{-43.985,  3.439, -9.919, 19.297},
						{Graph.wave(t, 8,  8) * -0.15, 0.05}},
					["Tom 4"] = {{-0.685, 0.567},
						{-42.124, 23.522,  9.784, 28.285},
						{-40.953,  3.459, -9.860, 20.867},
						{Graph.wave(t, 8,  8) * -0.15, 0.05}},
					["Tom 5"] = {{-0.717, 0.567},
						{-36.672, 24.852, 10.040, 29.090},
						{-37.749,  3.500, -9.749, 21.676},
						{Graph.wave(t, 8,  8) * -0.15, 0.05}},
					["Tom 6"] = {{-0.717, 0.567},
						{-31.722, 24.553,  9.774, 28.914},
						{-34.645,  3.541, -9.793, 21.745},
						{Graph.wave(t, 8,  8) * -0.15, 0.05}},
				}) [name];
				result.bounce = result.bounce + d[4][1];
				result.radius = result.radius + d[4][1] * d[4][2];
				Util.append(result.marbles, Graph.trajectory(t, {
					{d[1][1], Vector3.new(-33.843,  14.831, -39.388), d[2][2]},
					{  0.000, Vector3.new(d[2][1], d[2][2], d[2][3]), d[3][2]},
					{d[1][2], Vector3.new(d[3][1], d[3][2], d[3][3]), nil    },
				}));
			end
			return result;
		end);

		apply = (function(params, model) end);
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
