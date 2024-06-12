Util = require(workspace.scripts.Util);

local Type = {};

function Type.new(T)
	return Util.deepCopy(T);
end

return Type;
