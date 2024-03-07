print("Main script starting up ...");

Type       = require(workspace.scripts.Type);
MIDI       = require(workspace.scripts.MIDI);
CueMapper  = require(workspace.scripts.CueMapper);
midiString = require(workspace.input.MIDIs["Pipe Dream.midi"]);
print("Module scripts loaded.");

local midi, cueTable;
local err; (function()
	-- Break early on error (by returning from an anonymous function)
	print("Input MIDI file:", #midiString, "chars long");
	midi, err = Type.new(MIDI.Parser):parse(midiString);
	if err then return; end

	print("Reading tempo data ...");
	cueTable, err = Type.new(CueMapper):read(midi);
	if err then return; end

end) ();
if err then warn(err); end

print("MIDI object:", midi);
print("Cue table:", cueTable);