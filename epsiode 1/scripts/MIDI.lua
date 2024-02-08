Util = require(workspace.scripts.Util);

local MIDI = {
	Parser = {
		result = {
			header = {};
			tracks = { {} };
		};

		i = 0;
		done = false;
		error = nil;
	};
};

function MIDI.Parser.parse(self, base64Str) --> expected MIDI table
	local bytes, err = Util.parseBase64(base64Str);
	if err then return nil, err end

	self:parseHeader(bytes);
	if self.error then return nil, self.error end

	repeat
		self:parseTrack(bytes);
	until (self.done);
	
	if self.error then
		return nil, self.error;
	end
	return self.result;
end

function MIDI.Parser.parseHeader(self, bytes)
	self:check(bytes:sub(1,4) == "MThd"    , "Input file is not a MIDI file");
	local length   = Util.parseU32(bytes:sub( 5, 8));
	local format   = Util.parseU16(bytes:sub( 9,10));
	local ntrks    = Util.parseU16(bytes:sub(11,12));
	local division = Util.parseS16(bytes:sub(13,14));

	self:check(length   == 6, "Invalid header length");
	self:check(format    < 3, "Unknown MIDI format");
	self:check(division ~= 0, "0 ticks per 1/4-note");
	self:check(division  > 0, "SMPTE subdivisions are not supported");
	self:check(not (format==0 and ntrks~=1), "Invalid number of tracks");
	if self.error then return; end

	self.i = 15;
	self.result.header = {
		format = format;
		trackCount = ntrks;
		tickFrequency = division;
	};
end

function MIDI.Parser.parseTrack(self, bytes)
	table.insert(self.result.tracks[1], "Track Data!");
	self.done = true;
end

function MIDI.Parser.check(self, condition, message)
	if not condition then
		self.error = message;
		self.done = true;
	end
end

return MIDI;