PLUGIN.name = "Pac Flag"
PLUGIN.author = "AleXXX_007"
PLUGIN.desc = "Adds 'P' flag, which allows to use PAC 3 editor."

nut.flag.add("P", "Access to PAC 3 editor.")

hook.Add( "PrePACEditorOpen", "FlagCheck", function( client )
   if not client:getChar():hasFlags("P") then
       return false
   end
end )