Util = require(workspace.scripts.Util);

local CueMapper = {
	result = {};

	tempoPoints = { -- [tickCount] -> {seconds, seconds per tick}
		[0] = {seconds = 0, slope = 0},
	};
};

function CueMapper.read(self, midi) --> expected cue table
	self:setTempoPoints(midi);
	local ticksToSec = function(ticks)
		local ticksPrev, p = Util.pairBefore(self.tempoPoints, ticks);
		return (ticks-ticksPrev) * p.slope + p.seconds;
	end;

	for i, track in pairs(midi.tracks) do
		self.result[i] = {};
		local ticks = 0;
		for _, event in pairs(track.events) do
			ticks = ticks + event.deltaTime;
			self.result[i][ticksToSec(ticks)] = true;
--			self.result[i][1000*ticksToSec(ticks)//1] = true;
		end
	end

	return self.result;
end

function CueMapper.setTempoPoints(self, midi)
	local tempoList = { -- [tickCount] -> microseconds per 1/4-note
		[0] = 500000,
	};

	for _, track in pairs(midi.tracks) do
		local ticks = 0;
		for _, event in pairs(track.events) do
			ticks = ticks + event.deltaTime;
			if event.type == "Meta\x51" then
				tempoList[ticks] = Util.parseUint(event.data);
			end
		end
	end

	for ticks, microseconds in pairs(tempoList) do
		local ticksPrev, p = Util.lastPair(self.tempoPoints);

		self.tempoPoints[ticks] = {
			seconds = (ticks-ticksPrev) * p.slope + p.seconds,
			slope = (microseconds/1e6) / midi.header.tickRate,
		};
	end
end

return CueMapper;