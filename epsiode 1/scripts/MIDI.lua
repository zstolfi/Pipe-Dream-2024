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
	local bytes = Util.parseBase64(base64Str);

	-- Check the file's 'magic bytes' before continuing.
	if bytes:sub(1,4) ~= "MThd" then
		return nil, "Input file is not a MIDI file";
	end

	self:parseHeader(bytes);
	repeat
		self:parseTrack(bytes);
	until (self.done);
	
	return self.result;
end

function MIDI.Parser.parseHeader(self, bytes)
	table.insert(self.result.header, "Header Data!");
end

function MIDI.Parser.parseTrack(self, bytes)
	table.insert(self.result.tracks[1], "Track Data!");
	self.done = true;
end

return MIDI;