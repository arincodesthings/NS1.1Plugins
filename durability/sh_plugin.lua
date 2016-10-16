PLUGIN.name = "Durability"
PLUGIN.author = "AleXXX_007"
PLUGIN.desc = "Adds durability for all weapons."

if (SERVER) then
	function PLUGIN:EntityFireBullets(entity, bullet)
		if (entity:IsPlayer()) then
		local weapon = entity:GetActiveWeapon()
		
			if (weapon) then
				local items = entity:getChar():getInv():getItems()
				for k, v in pairs(items) do
					if v.isWeapon and v.class == weapon:GetClass() then
					
					local chance = math.random(1, 8)
						if chance == 1 and v:getData("durability", 100) > 0 then
							v:setData("durability", v:getData("durability") - 1)
						elseif chance == 1 and v:getData("durability", 100) == 0 then
							entity:notify("Оружие пришло в негодность!")
							v:setData("equip", nil)

							entity.carryWeapons = entity.carryWeapons or {}

							local weapon = entity.carryWeapons[v.weaponCategory]

							if (IsValid(weapon)) then
								v:setData("ammo", weapon:Clip1())

								entity:StripWeapon(v.class)
								entity.carryWeapons[v.weaponCategory] = nil
								entity:EmitSound("items/ammo_pickup.wav", 80)
								if (v.pacData) then
									entity:getChar():removePart(v.uniqueID)
								end
							end
						end
						bullet.Damage = (bullet.Damage / 100) * v:getData("durability")
						bullet.Spread = bullet.Spread * (1 + (1 - ((1 / 100) * v:getData("durability"))));
					end
				end
			end;
		end;
	end
end