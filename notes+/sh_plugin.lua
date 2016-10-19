local PLUGIN = PLUGIN
PLUGIN.name = "Notes+"
PLUGIN.author = "AleXXX_007"
PLUGIN.desc = "Write text on notes and pick up them like items."
NOTELIMIT = 10000
WRITINGDATA = WRITINGDATA or {}

nut.util.include("cl_vgui.lua")

if (CLIENT) then
	netstream.Hook("receiveNote", function(id, contents, write)
		local note = vgui.Create("noteRead")
		note:allowEdit(write)
		note:setText(contents)
		note.id = id
	end)
else	
	netstream.Hook("noteSendText", function(client, id, contents)
		if (string.len(contents) <= NOTELIMIT) then
			for k, v in pairs(nut.item.instances) do
				if v.uniqueID == "note" and v.id == id then
					v:setData("text", contents)
				end
			end
		end
	end)	
end
