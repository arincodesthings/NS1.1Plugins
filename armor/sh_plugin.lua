PLUGIN.name = "armor"
PLUGIN.author = "Ice_Eagle"
PLUGIN.desc = "Add armor to ns 1.1."

function PLUGIN:EntityTakeDamage(target,dmginfo)
	if (target:IsPlayer() and dmginfo:IsFallDamage() == false) then
	local inv = target:getChar():getInv() 
		if target:getChar():getData("armored") then
			for k, v in pairs(inv:getItems()) do
				local itemTable = nut.item.instances[v.id]
				if (itemTable.isCloth and itemTable:getData("equip")) then
					local ric = itemTable.ric  
					local dmgsteal = itemTable.dmgsteal
					math.randomseed( os.time() )
					local chance = math.random(100)
					if (chance <= ric) then
						dmginfo:ScaleDamage(0 )
					end
					dmginfo:ScaleDamage(1 - (dmgsteal / 100) )
				end
			end
		end
	end 
end
--hook.add("EntityTakeDamage","playerArmor", PLUGIN:takeDamage(target, dmginfo))