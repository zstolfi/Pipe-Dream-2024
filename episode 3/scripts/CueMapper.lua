Util = require(workspace.scripts.Util);

local CueMapper = {
	result = {};

	tempoPoints = {
		{ticks = 0, seconds = 0, slope = 0},
	};
};

function CueMapper.read(self, midi) --> expected cue table
	self:setTempoPoints(midi);
	local ticksToSec = function(ticks)
		local i = Util.findUntil(
			self.tempoPoints,
			function(p) return p.ticks > ticks; end
		);
		local p = self.tempoPoints[i];
		return (ticks-p.ticks) * p.slope + p.seconds;
	end;

	for i, track in pairs(midi.tracks) do
		self.result[i] = {};
		local ticks = 0;
		for _, event in pairs(track.events) do
			ticks = ticks + event.deltaTime;
			self.result[i][#self.result[i]] = {
				ticksToSec(ticks)
			};
		end
	end

	return self.result;
end

function CueMapper.setTempoPoints(self, midi)
	local tempoList = {
		{ticks = 0, microseconds = 5000000},
	};

	for _, track in pairs(midi.tracks) do
		local ticks = 0;
		for _, event in pairs(track.events) do
			ticks = ticks + event.deltaTime;
			if event.type == "Meta\x51" then
				tempoList[#tempoList + 1] = {
					ticks = ticks,
					microseconds = Util.parseUint(event.data);
				};
			end
		end
	end

	for _, tempo in pairs(tempoList) do
		local p = self.tempoPoints[#self.tempoPoints];

		self.tempoPoints[#self.tempoPoints + 1] = {
			ticks = tempo.ticks,
			seconds = (tempo.ticks-p.ticks) * p.slope + p.seconds,
			slope = (tempo.microseconds/1e6) / midi.header.tickRate,
		};
	end
end

return CueMapper;