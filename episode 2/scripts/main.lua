print("Main script starting up ...");

Type       = require(workspace.scripts.Type);
MIDI       = require(workspace.scripts.MIDI);
midiString = require(workspace.input.MIDIs["Pipe Dream.midi"]);
print("Module scripts loaded.");

print("Input MIDI file:", #midiString, "chars long");
local midi, error = Type.new(MIDI.Parser):parse(midiString);

if not error then
	print("MIDI object:", midi);
else
	warn("Parsing failed with error:", error);
end