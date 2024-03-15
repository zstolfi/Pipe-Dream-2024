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
		[0xC] = 1, [0xD] = 1, [0xE] = 2,
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
	local tickRate, divType = self:parseTickRate(division);

	self:check(chunkType == "MThd"  , "Input file is not a MIDI file");
	self:check(length    == 6       , "Invalid header length");
	self:check(format     < 3       , "Unknown MIDI format");
	self:check(tickRate  ~= 0       , "0 ticks per second");
	self:check(ntrks      > 0       , "Invalid number of tracks");
	self:check(format~=0 or ntrks==1, "Invalid number of tracks");
	if self.error then return; end

	self.result.header = {
		format = format;
		trackCount = ntrks;
		tickRate = tickRate;
		divisionType = divType;
	};
end

function MIDI.Parser.parseTickRate(self, division)
	if division >= 0 then
		return division, "1/4 note";
	else
		local fps = nil;

		if     division//256 == -24 then fps = 24;
		elseif division//256 == -25 then fps = 25;
		elseif division//256 == -29 then fps = 30/1.001;
		elseif division//256 == -30 then fps = 30;
		end
		self:check(fps ~= nil, "Unknown SMPTE format");
		if self.error then return; end

		-- TODO: Verify (signed % unsigned) is safe.
		return (division % 256) * fps, "second";
	end
end

function MIDI.Parser.parseTrack(self)
	local chunkType = self:read(4);
	local length    = self:readUint(4);

	self:check(chunkType == "MTrk", "Expected track chunk");
	if self.error then return; end

	local track = {
		events = {};
	};

	local iEnd = self.i + length;
	while self.i < iEnd do
		local event = self:parseEvent();
		local isLast = self.i == iEnd;
		if isLast then
			self:check(event.type == "Meta\x2F"
			,     "Track doesn't end with End of Track event.");
		else
			self:check(event.Type ~= "Meta\x2F"
			,     "Track contains premature End of Track event.");
		end
		table.insert(track.events, event);
		if self.error then return; end
	end

	self:check(#track.events > 0, "Track chunk contains 0 events");
	table.insert(self.result.tracks, track);
end

function MIDI.Parser.parseEvent(self) --> expected event
	local deltaTime = self:readVarLen();

	if (self:peek(1):byte() > 127) then
		self.status = self:read(1):byte();
	end
	self:check(self.status ~= nil, "Expected status byte");
	if self.error then return; end

	local eventType = nil;
	local length = nil;

	if     self.status >= 0x80
	and    self.status <= 0xEF then eventType = "Midi";
	elseif self.status == 0xF0 then eventType = "SysEx";
	elseif self.status == 0xF7 then eventType = "SysEx";
	elseif self.status == 0xFF then eventType = "Meta";
	end

	self:check(eventType ~= nil, "Unknown status byte");
	if self.error then return; end

	local length = MIDI.statusLength[self.status//16];
	if length == nil then
		if eventType == "Meta" then
			eventType = eventType .. self:read(1);
		end
		length = self:readVarLen();
	end

	local data = self:read(length);
	if self:isText(eventType) then
		data = data:match("^([^%z]*)");
	end

	return {
		deltaTime = deltaTime;
		type = eventType;
		status = self.status;
		data = data;
	};
end

function MIDI.Parser.isText(self, eventType)
	return eventType:match("Meta.") and Util.inRange(eventType:byte(5,5), 1, 7)
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