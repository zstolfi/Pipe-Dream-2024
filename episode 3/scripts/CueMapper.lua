Util = require(workspace.scripts.Util);

local CueMapper = {
	result = {};

	midi = {};
	instruments = {};

	keyDefs = {};
	keyMaps = {};
	trackIndices = {};
	tempoPoints = {
		set = false,
		{ticks = 0, seconds = 0, slope = 0},
	};
};

function CueMapper.read(self, midi, instruments) --> expected cue table
	self.midi, self.instruments = midi, instruments;

	self:setTrackNames();
	self:setKeyMaps();
	self:setKeys();

	self:iterateNotes(function(ticks, note, trackNum)
		for keyName, keyDef in pairs(self.keyDefs) do
			local match = Util.anyOf(keyDef, function(k)
				return k.trackSet[trackNum]
				and    k.pitchSet[note.pitch]
				and    k.channelSet[note.channel];
			end);

			if match then
				Util.append(self.result[keyName], {
					seconds  = self:ticksToSec(ticks),
					pitch    = note.pitch,
					velocity = note.velocity,
				});
			end
		end
	end);

	for _, v in pairs(self.result) do
		Util.sort(v, function(a, b)
			return a.seconds < b.seconds;
		end);
	end

	return self.result;
end

function CueMapper.setTrackNames(self)
	self:iterateEvents(function( _ , event, trackNum)
		if event.type == "Meta\x03" then
			local name = Util.trimWhitespace(event.data);
			if #name > 0 then
				self.trackIndices[name] = trackNum;
			end
		end
	end);
end

function CueMapper.setKeyMaps(self)
	for name, def in pairs(self.instruments) do
		if def.type == "range" then
			local d = def[1];
			local size = d.size or d.to - d.from;
			local range = self:getNoteRange(def.track);
			self.keyMaps[name] = {};
			for i=1, size do self.keyMaps[name][i] = {}; end

			-- Less notes than keys:
			if #range < size then
				local span = range[#range] - range[1] + 1;
				-- The span of notes fit:
				if span < size then
					local center = d.center or 0.5;
					local offset = center * (size - span) // 1 - range[1] + 1;
					for _ , pitch in pairs(range) do
						self.keyMaps[name][pitch + offset] = {pitch};
					end
				-- Underfit:
				else
					-- TODO: Replace with non state-based algorithm.
					local gapIndeces, gapSizes = {}, {};
					for i=1, #range-1 do
						if range[i]+1 ~= range[i+1] then
							Util.append(gapIndeces, i);
							Util.append(gapSizes, range[i+1] - range[i] - 1);
						end
					end

					local scaleFactor = (size - #range) / (span - #range);
					local errAccum = 0.0;
					for i=1, #gapSizes do
						local goal = gapSizes[i] * scaleFactor;

						gapSizes[i] = errAccum < 0.5
							and math.floor(goal)
							or  math.ceil(goal);

						errAccum = errAccum + (goal - gapSizes[i]);

						if errAccum >= 0.5 then
							errAccum = errAccum - 1.0;
							gapSizes[i] = gapSizes[i] + 1;
						end
					end

					local keyId, gapId = 1, 1;
					for i=1, #range do
						self.keyMaps[name][keyId] = {range[i]};
						if gapIndeces[gapId] == i then
							keyId = keyId + gapSizes[gapId];
							gapId = gapId + 1;
						end
						keyId = keyId + 1;
					end
				end

			-- 1 to 1 fit:
			elseif #range == size then
				for i=1, size do
					self.keyMaps[name][i] = {range[i]};
				end

			-- Overfit:
			elseif #range > size then
				local stride = #range / size;
				for i=1, size do
					local lo = (i-1)*stride//1 + 1;
					local hi = (i-0)*stride//1;
					for j=lo, hi do
						Util.append(self.keyMaps[name][i], range[j]);
					end
				end
			end
		end
	end
end

function CueMapper.setKeys(self)
	for name, def in pairs(self.instruments) do
		if def.type == "single" then
			self:makeKeyDef(name, def.track, def[1]);

		elseif def.type == "list" then
			for key, pitch in pairs(def[1]) do
				self:makeKeyDef(name ..".".. key, def.track, {pitch});
			end

		elseif def.type == "range" then
			for i, pitches in pairs(self.keyMaps[name]) do
				self:makeKeyDef(name ..".".. i, def.track, pitches);
			end

		end
	end

	for keyName, _ in pairs(self.keyDefs) do
		self.result[keyName] = {};
	end
end

-- A description of which notes a key should listen/respond to:
-- Ex: {{"Piano"}, {108}}  -> Any C8 on any track named "Piano"
--     {{"{10}"}, {38,40}} -> Either snare played on Channel 10
function CueMapper.makeKeyDef(self, name, selectorList, pitches)
	local keyDef = self.keyDefs[name] or {};

	for selector in selectorList:gmatch("[^|]+") do
		local s = self:parseTrackSelector(selector);
		Util.append(keyDef, {
			trackSet = s.trackSet;
			channelSet = s.channelSet;
			pitchSet = (pitches.all)
				and Util.universalSet
				or  Util.Set(pitches);
		});
	end

	self.keyDefs[name] = keyDef;
end

function CueMapper.parseTrackSelector(self, selector) --> track & channel sets
	local trackSet, channelSet = {}, {};
	if selector == "*" then
		trackSet   = Util.universalSet;
		channelSet = Util.universalSet;
	elseif selector:match("^%[%d+%]$") then
		trackSet   = Util.Set({tonumber(selector:sub(2,-2))});
		channelSet = Util.universalSet;
	elseif selector:match("^%{%d+%}$") then
		trackSet   = Util.universalSet;
		channelSet = Util.Set({tonumber(selector:sub(2,-2))});
	else
		trackSet   = Util.Set({self.trackIndices[selector]});
		channelSet = Util.universalSet;
	end
	return { trackSet = trackSet; channelSet = channelSet; };
end

CueMapper.findNoteRange_tab = {};
function CueMapper.getNoteRange(self, selectorList) --> ordered array of pitches
	if self.findNoteRange_tab[selectorList] ~= nil then
		return self.findNoteRange_tab[selectorList];
	end
	
	local set = {};
	for selector in selectorList:gmatch("[^|]+") do
		local s = self:parseTrackSelector(selector);
		
		self:iterateNotes(function( _ , note, trackNum)
			if  s.trackSet[trackNum]
			and s.channelSet[note.channel] then
				set[note.pitch] = true;
			end
		end);
	end
	local result = Util.setFlatten(set);
	Util.sort(result, Util.less);

	self.findNoteRange_tab[selectorList] = result;
	return result;
end

function CueMapper.ticksToSec(self, ticks) --> seconds
	if self.midi.header.divisionType == "second" then
		-- SMPTE Midi files do not respond to tempo-change
		-- events. (Maybe, I don't really have any tests.)
		return ticks / self.midi.header.tickRate;
	end

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
end

function CueMapper.setTempoPoints(self)
	local tempoList = {
		{ticks = 0, microseconds = 5000000},
	};

	self:iterateEvents(function(ticks, event)
		if event.type == "Meta\x51" then
			Util.append(tempoList, {
				ticks = ticks,
				microseconds = Util.parseUint(event.data),
			});
		end
	end);

	for _, tempo in pairs(tempoList) do
		local p = self.tempoPoints[#self.tempoPoints];
		Util.append(self.tempoPoints, {
			ticks = tempo.ticks,
			seconds = (tempo.ticks-p.ticks) * p.slope + p.seconds,
			slope = (tempo.microseconds/1e6) / self.midi.header.tickRate,
		});
	end
end

function CueMapper.iterateEvents(self, f)
	for i, track in pairs(self.midi.tracks) do
		local ticks = 0;
		for j, event in pairs(track.events) do
			ticks = ticks + event.deltaTime;
			f(ticks, event, i, j);
		end
	end
end

function CueMapper.iterateNotes(self, f)
	self:iterateEvents(function(ticks, event, i, j)
		-- In Pipe Dream we only listen for note-on events.
		if event.status//16 ~= 0x9 then return; end
		local pitch, velocity = event.data:byte(1,2);
		local channel = (event.status % 16) + 1;

		-- By convention vel = 0 counts as note-off
		if velocity == 0 then return; end

		local note = {
			pitch = pitch,
			velocity = velocity,
			channel = channel
		};

		f(ticks, note, i, j);
	end);
end

return CueMapper;