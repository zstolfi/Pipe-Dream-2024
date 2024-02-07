print("Main script starting up");
local MIDI       = require(workspace.scripts.MIDI);
local midiString = require(workspace.input.MIDIs["test.midi"]);

print("bf:", MIDI.Parser.result);
print("Input MIDI file:", #midiString, "chars long");
local midi, err = MIDI.Parser:new():parse(midiString);

if not err then
	print("MIDI object:", midi, ":D");
	print("af:", MIDI.Parser.result);
else
	error("Parsing failed with error:", err);
end