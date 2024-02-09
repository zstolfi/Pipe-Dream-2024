print("Main script starting up ...");

Type       = require(workspace.scripts.Type);
MIDI       = require(workspace.scripts.MIDI);
midiString = require(workspace.input.MIDIs["Pipe Dream.midi"]);
print("Module scripts loaded.");

print("Input MIDI file:", #midiString, "chars long");
local midi, err = Type.new(MIDI.Parser):parse(midiString);

if not err then
	print("MIDI object:", midi);
else
	warn("Parsing failed with error:", err);
end