Util = require(workspace.scripts.Util);

local MIDI = {

	Parser = {
		-- Unusable table.clone function, I'll have to
		-- rewrite my own 'deep copy' version soon ...
		new = function(self) return table.clone(self); end;

		result = {
			header = {};
			tracks = { {} };
		};

		i = 0;
		done = false;
		error = nil;

		parse = function(self, base64Str) --> expected MIDI table
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
		end;

		parseHeader = function(self, bytes)
			table.insert(self.result.header, "Header Data!");
		end;

		parseTrack = function(self, bytes)
			table.insert(self.result.tracks[1], "Track Data!");
			self.done = true;
		end;
	},
};

return MIDI;