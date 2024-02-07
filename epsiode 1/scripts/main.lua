print("Main script starting up");
local MIDI       = require(workspace.scripts.MIDI);
local midiString = require(workspace.input.MIDIs["test.midi"]);

print("Input MIDI file:", #midiString, "chars long");
local midi, err = MIDI.parse(midiString);

if not err then
	print("MIDI object:", midi);
else
	error("Parsing failed with error:", err);
end