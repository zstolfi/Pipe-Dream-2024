Util = require(workspace.scripts.Util);

local MIDI = {
	Parser = {
		result = {
			header = {};
			tracks = {};
		};

		i = 1;
		status = nil;
		bytes = "";
		error = nil;
	};

	statusLength = {
		[0x8] = 2, [0x9] = 2, [0xA] = 2, [0xB] = 2,
		[0xC] = 1, [0xD] = 1, [0xE] = 2
	};
};

function MIDI.Parser.parse(self, base64Str) --> expected MIDI table
	local bytes, err = Util.parseBase64(base64Str);
	if err then return nil, err end
	self.bytes = bytes;
	self.i = 1; self.error = nil;

	self:parseHeader();
	if self.error then return nil, self:errorMessage(); end

	for i=1, self.result.header.trackCount do
		self:parseTrack();
		if self.error then return nil, self:errorMessage(); end
	end
	
	return self.result;
end

function MIDI.Parser.parseHeader(self)
	local chunkType = self:read(4);
	local length    = self:readUint(4);
	local format    = self:readUint(2);
	local ntrks     = self:readUint(2);
	local division  = self:readSint(2);

	self:check(chunkType == "MThd"  , "Input file is not a MIDI file");
	self:check(length   == 6        , "Invalid header length");
	self:check(format    < 3        , "Unknown MIDI format");
	self:check(division ~= 0        , "0 ticks per 1/4-note");
	self:check(division  > 0        , "SMPTE subdivisions are not supported");
	self:check(ntrks     > 0        , "Invalid number of tracks");
	self:check(format~=0 or ntrks==1, "Invalid number of tracks");
	if self.error then return; end

	self.result.header = {
		format = format;
		trackCount = ntrks;
		tickRate = division;
	};
end

function MIDI.Parser.parseTrack(self)
	local chunkType = self:read(4);
	local length    = self:readUint(4);

	self:check(chunkType == "MTrk", "Expected track chunk");
	if self.error then return; end

	local track = {
		eventCount = 0;
		events = {};
	};

	local iEnd = self.i + length;
	while self.i < iEnd do
		self:parseEvent(track.events);
		if self.error then return; end

		track.eventCount = track.eventCount + 1;
	end

	self:check(track.eventCount > 0, "Track chunk contains 0 events");
	table.insert(self.result.tracks, track);
end

function MIDI.Parser.parseEvent(self, eventList)
	local deltaTime = self:readVarLen();

	if (self:peek(1):byte() > 127) then
		self.status = self:read(1):byte();
	end
	self:check(self.status ~= nil, "Expected status byte");
	if self.error then return; end

	local eventType = nil;
	local length = nil;

	local inRange = function(x,a,b) return a <= x and x <= b; end;
	if     inRange(self.status, 0x80, 0xEF) then eventType = "Midi";
	elseif inRange(self.status, 0xF0, 0xF0) then eventType = "SysEx";
	elseif inRange(self.status, 0xFF, 0xFF) then eventType = "Meta";
	end
	self:check(eventType ~= nil, "Unknown status byte");
	if self.error then return; end

	local length = MIDI.statusLength[self.status//16];
	if length == nil then
		if eventType == "Meta" then eventType = eventType .. self:read(1); end
		length = self:readVarLen();
	end

	local data = self:read(length);

	table.insert(eventList, {
		deltaTime = deltaTime;
		type = eventType;
		status = self.status;
		data = data;
	});
end



function MIDI.Parser.peek(self, n) --> binary string
	return self.bytes:sub(self.i, self.i + n-1);
end

function MIDI.Parser.read(self, n) --> binary string
	self.i = self.i + n;
	return self.bytes:sub(self.i - n, self.i-1);
end

function MIDI.Parser.readUint(self, n) --> unsigned integer
	return Util.parseUint(self:read(n));
end

function MIDI.Parser.readSint(self, n) --> signed integer
	return Util.parseSint(self:read(n));
end

function MIDI.Parser.readVarLen(self) --> unsigned integer
	local result = 0;
	while (self:peek(1):byte() > 127) do
		local n = self:read(1):byte() % 128;
		result = 128*result + n;
	end
	return 128*result + self:read(1):byte();
end



function MIDI.Parser.check(self, condition, message)
	if not condition then
		self.error = self.error or message;
	end
end

function MIDI.Parser.errorMessage(self) --> string
	local err = self.error or "Unknown error";
	return "Parsing MIDI failed with error:" .. err
	..     ", at byte: " .. self.i .. ".";
end

return MIDI;