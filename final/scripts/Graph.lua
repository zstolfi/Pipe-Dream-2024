Util = require(workspace.scripts.Util);

local Graph = {};

function Graph.lerp(t, a, b) return (1-t)*a + t*b; end
function Graph.map(t, a, b, p, q) return Graph.lerp((t-a)/(b-a), p, q); end
function Graph.clamp(t, t0, t1) return math.max(t0, math.min(t1, t)); end

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
		-- https://www.desmos.com/calculator/fgddvocyfw
		return (offset or CFrame.new()) * Vector3.new(
			Graph.lerp(t, cur[2].x, next[2].x),
			t*(2*t-1) * next[2].y + (t-1) * ((2*t-1)*cur[2].y - 4*t*cur[3]),
			Graph.lerp(t, cur[2].z, next[2].z)
		);
	end
end

function Graph.roundedSquare(r, t) --> Vector2
	-- https://www.desmos.com/calculator/pslkafiydt
	local PI = Graph.lerp(4, math.pi, r);

	local function c(x)
		if x < 0 then return x; end
		if r == 0 then return 0; end
		return r * math.sin(math.min(x, 0.5*math.pi*r) / r);
	end

	local function d(x)
		return c(PI/2 - math.abs(PI/2 - x) - (1-r)) + (1-r);
	end

	local function s_sin(x)
		return ((x-PI) % (2*PI) < PI and -1 or 1) * d(x % PI);
	end

	return Vector2.new(s_sin(2*PI*t), s_sin(PI/2 - 2*PI*t));
end

function Graph.roundedSquare_normal(r, t) --> Vector2
	local PI = Graph.lerp(4, math.pi, r);

	-- https://www.desmos.com/calculator/w4wvjljb49
	local function staircase(s, x)
		if s == 0 then return math.floor(x) + 0.5; end
		return x - (1/(2*s)-1)*(x%1) - Graph.clamp(1/(2*s)*(x%1), 0, 1/(2*s)-1);
	end

	local u = PI/2 * staircase(2*(1-r)/PI, t);
	return Vector2.new(math.cos(u), math.sin(u));
end

return Graph;
