ITEM.name = "Example Seeds"
ITEM.model = "models/props_lab/box01a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.desc = "Just for testing."
ITEM.plant = "nut_exampleplant"

ITEM.functions.use = {
	name = "Plant",
	tip = "useTip",
	icon = "icon16/accept.png",
	onRun = function(item, client)
		local client = item.player
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector()*96
			data.filter = client
		local trace = util.TraceLine(data)

		if (trace.HitPos) then
			local seed = ents.Create(item.plant)
			seed:SetPos(trace.HitPos + trace.HitNormal) //* 10
			seed:Spawn()
			client:notify("Seeds planted")

			--main function
			local random_growing = math.random(180, 600) -- Growing time
			timer.Simple(random_growing, function()
			seed:SetModelScale(0.75) -- Object size scale
			seed:SetNetworkedBool("Usable", true) end)

			hook.Run("OnSeedCreated", seed, item)
		end

		return true
	end,
}