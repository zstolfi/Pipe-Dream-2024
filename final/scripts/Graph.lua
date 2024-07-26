Util = require(workspace.scripts.Util);

local Graph = {};

function lerp(a, b, t) return (1-t)*a + t*b; end

function Graph.wave(seconds, frequency, decay) --> number
	if seconds < 0 then return 0; end
	return math.exp(-decay*seconds) * -math.sin(math.pi*frequency*seconds);
end

function Graph.trajectory(seconds, arcs, offset) --> possible marble
	if seconds < arcs[1][1] or seconds > arcs[#arcs][1] then
		return nil;
	else
		local i = Util.findUntil(arcs, function(a) return a[1] >= seconds; end);
		local cur, next = arcs[i], arcs[i+1];
		local t = (seconds - cur[1]) / (next[1] - cur[1]);
		return (offset or CFrame.new()) * Vector3.new(
			lerp(cur[2].x, next[2].x, t),
			-- https://www.desmos.com/calculator/fgddvocyfw
			t*(2*t-1) * next[2].y + (t-1) * ((2*t-1)*cur[2].y - 4*t*cur[3]),
			lerp(cur[2].z, next[2].z, t)
		);
	end
end

return Graph;
