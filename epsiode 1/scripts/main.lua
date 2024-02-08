print("Main script starting up ...");
Type       = require(workspace.scripts.Type);
MIDI       = require(workspace.scripts.MIDI);
midiString = require(workspace.input.MIDIs["test.midi"]);
print("Module scripts loaded.");

print("bf:", MIDI.Parser.result);
print("Input MIDI file:", #midiString, "chars long");
local midi, err = Type.new(MIDI.Parser):parse(midiString);

if not err then
	print("MIDI object:", midi);
	print("af:", MIDI.Parser.result);
else
	warn("Parsing failed with error:", err);
end