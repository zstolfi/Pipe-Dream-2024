Util = require(workspace.scripts.Util);

local MIDI = {
	parse = function(base64Str)
		local bytes = Util.parseBase64(base64Str);
		-- 	Util.printBytes(bytes);
		
		return {};
	end
};

return MIDI;