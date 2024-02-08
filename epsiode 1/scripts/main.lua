print("Main script starting up ...");
Type       = require(workspace.scripts.Type);
MIDI       = require(workspace.scripts.MIDI);
midiString = require(workspace.input.MIDIs["test.midi"]);
print("Module scripts loaded.");

print("bf:", MIDI.Parser.result);
print("Input MIDI file:", #midiString, "chars long");
local midi, err = Type.new(Parser):parse(midiString);

if not err then
	print("MIDI object:", midi, ":D");
	print("af:", MIDI.Parser.result);
else
	error("Parsing failed with error:", err);
end