local PLUGIN = PLUGIN
PLUGIN.name = "Notes+"
PLUGIN.author = "AleXXX_007"
PLUGIN.desc = "Write text on notes and pick up them like items."
NOTELIMIT = 10000
WRITINGDATA = WRITINGDATA or {}

nut.util.include("cl_vgui.lua")

if (CLIENT) then
	netstream.Hook("receiveNote", function(id, contents, write, placed)
		local note = vgui.Create("noteRead")
		note:allowEdit(write)
		note:setText(contents)
		note.id = id
		if placed == 1 then
			note:placed(false, false)
		else
			note:placed(true, write)
		end
	end)
else	
	netstream.Hook("noteSendText", function(client, id, contents)
		if (string.len(contents) <= NOTELIMIT) then
			WRITINGDATA[id] = contents
		end
	end)	
end