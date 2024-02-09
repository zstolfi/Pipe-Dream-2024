print("Main script starting up ...");

Util       = require(workspace.scripts.Util);
midiString = require(workspace.input.MIDIs["Prelude in C.midi"]);
print("Module scripts loaded.");

print("Input Base64:", #midiString, "chars long");
print({midiString});

local bytes, err = Util.parseBase64(midiString);
if not err then
	print("Decoded bytes:", #bytes, "chars long");
	print({Util.bytesToString(bytes)});
else
	warn("Parsing Base64 failed with error:", err);
end