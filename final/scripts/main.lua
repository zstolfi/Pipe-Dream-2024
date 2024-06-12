print("Running static tests ...");
require(workspace.Test);

print("Main script starting up ...");

midiName    = "Pipe Dream.midi";
Type        = require(workspace.scripts.Type);
MIDI        = require(workspace.scripts.MIDI);
CueMapper   = require(workspace.scripts.CueMapper);
midiString  = require(workspace.input.MIDIs[midiName]);
instruments = require(workspace.input.Instruments);
print("Module scripts loaded.");

local midi, cueTable;
local err; (function()
	-- Break early on error (by returning from an anonymous function)
	print("Input MIDI file", "'"..midiName.."':", #midiString, "chars long");
	midi, err = Type.new(MIDI.Parser):parse(midiString);
	if err then return; end

	print("Reading tempo data ...");
	cueTable, err = Type.new(CueMapper):read(midi, instruments);
	if err then return; end

end) ();
if err then warn(err); end

print("MIDI object:", midi);
print("Cue table:", cueTable);
