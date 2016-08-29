PLUGIN.name = "Voice Flag"
PLUGIN.author = "AleXXX_007"
PLUGIN.desc = "Adds 'V' flag, which allows to use voice chat."
--allowVoice in NutScript config must be  "ON"!!!
nut.flag.add("v", "Access to voice chat.")

hook.Add( "PlayerStartVoice", "VoiceFlagCheck", function( ply )
   if not ply:getChar():hasFlags("v") then
       return false
   end
end )