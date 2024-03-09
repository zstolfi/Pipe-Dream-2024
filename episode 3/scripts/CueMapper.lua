Util = require(workspace.scripts.Util);

local CueMapper = {
	result = {};

	midi = {};
	instruments = {};

	keyDefs = {};
	trackNames = {};
	tempoPoints = {
		set = false,
		{ticks = 0, seconds = 0, slope = 0},
	};
};

function CueMapper.read(self, midi, instruments) --> expected cue table
	self.midi, self.instruments
	=    midi,      instruments;

	self:setTrackNames();
	print("\tTrack names:", self.trackNames);
	self:setKeys();
	print("\tKey criteria:", self.keyDefs);

	self:iterateEvents(function(ticks, event, trackNum)
		-- In Pipe Dream we only listen for note-on events.
		if event.status//16 ~= 0x9 then return; end
		local pitch, velocity = event.data:byte(1,2);

		-- By convention vel = 0 counts as note-off
		if velocity == 0 then return; end

		for keyName, keyDef in pairs(self.keyDefs) do
			if keyDef.trackSet[trackNum] and keyDef.pitchSet[pitch] then
				self.result[keyName][#self.result[keyName] + 1] = {
					seconds = self:ticksToSec(ticks),
					pitch = pitch,
					velocity = velocity,
				};
			end
		end
	end);

	return self.result;
end

function CueMapper.setTrackNames(self)
	for i=1, self.midi.header.trackCount do
		for _, event in pairs(self.midi.tracks[i].events) do
			if event.type == "Meta\x03" then
				self.trackNames[event.data] = i;
			end
		end
	end
end

function CueMapper.setKeys(self)
	-- Space efficient way of doing { [1]=true, [2]=true, [3]=true ... }
	local MatchAll = setmetatable({}, {__index = function() return true; end});

	-- A description of which notes a key should listen/respond to:
	-- Ex: {{"Piano"}, {108}}  -> Any C8 on any track named "Piano"
	--     {{"{10}"}, {38,40}} -> Either snare played on Channel 10
	local makeKeyDef = function(track, pitches)
		return {
			trackSet = (track == "*")
				and MatchAll
				or  Util.setFrom({
					tonumber(track:match("^%[(%d+)%]$"))
					or track
				});
			pitchSet = pitches.all
				and MatchAll
				or  Util.setFrom(pitches);
		};
	end;

	for name, def in pairs(self.instruments) do
		if def.type == "single" then
			self.keyDefs[name] = makeKeyDef(def.track, def[1]);
		elseif def.type == "list" then
			for key, pitch in pairs(def[1]) do
				self.keyDefs[name ..".".. key] = makeKeyDef(def.track, {pitch});
			end
		elseif def.type == "range" then
			local size, from, to = def[1].size, def[1].from, def[1].to;
			for i=1, (size or to-from + 1) do
				self.keyDefs[name ..".".. i] = makeKeyDef(def.track,
					(from and to)
					and {i+from - 1}
					or  {}
				);
			end
		end
	end

	for i,v in pairs(self.keyDefs) do
		self.result[i] = {};
	end
end

function CueMapper.ticksToSec(self, ticks)
	if not self.tempoPoints.set then
		self:setTempoPoints();
		self.tempoPoints.set = true;
	end

	local i = Util.findUntil(
		self.tempoPoints,
		function(p) return p.ticks > ticks; end
	);
	local p = self.tempoPoints[i];
	return (ticks-p.ticks) * p.slope + p.seconds;
end;

function CueMapper.setTempoPoints(self)
	local tempoList = {
		{ticks = 0, microseconds = 5000000},
	};

	for _, track in pairs(self.midi.tracks) do
		local ticks = 0;
		for _, event in pairs(track.events) do
			ticks = ticks + event.deltaTime;
			if event.type == "Meta\x51" then
				tempoList[#tempoList + 1] = {
					ticks = ticks,
					microseconds = Util.parseUint(event.data),
				};
			end
		end
	end

	for _, tempo in pairs(tempoList) do
		local p = self.tempoPoints[#self.tempoPoints];

		self.tempoPoints[#self.tempoPoints + 1] = {
			ticks = tempo.ticks,
			seconds = (tempo.ticks-p.ticks) * p.slope + p.seconds,
			slope = (tempo.microseconds/1e6) / self.midi.header.tickRate,
		};
	end
end

-- TODO: Make more functions use this.
function CueMapper.iterateEvents(self, f)
	for i, track in pairs(self.midi.tracks) do
		local ticks = 0;
		for j, event in pairs(track.events) do
			ticks = ticks + event.deltaTime;
			f(ticks, event, i, j);
		end
	end
end

return CueMapper;