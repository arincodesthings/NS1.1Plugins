ITEM.name = "Seeds base"
ITEM.model = "models/items/jewels/purses/big_purse.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.desc = "Небольшой мешочек с зерном."
ITEM.PlantModel = "models/aoc_trees/aoc_lowveg14.mdl"
ITEM.BadGathering = {}
ITEM.CommonGathering = {}
ITEM.MasterGathering = {}

ITEM.functions.use = {
	name = "Посадить",
	tip = "useTip",
	icon = "icon16/accept.png",
	onRun = function(item, client)
		local client = item.player
		local trace = client:GetEyeTraceNoCursor()
		if (trace.HitPos:Distance( client:GetShootPos() ) <= 192) then
			if (trace.MatType == 68) then
				local seed = ents.Create("nut_culture")
				seed:SetPos(trace.HitPos + trace.HitNormal)
				seed.BadGathering = item.BadGathering
				seed.CommonGathering = item.CommonGathering
				seed.MasterGathering = item.MasterGathering
				seed:Spawn()
				seed:SetModel(item.PlantModel)
				client:notify("Вы успешно посадили семена")
				
				timer.Simple(math.random(300, 600), function()
					seed:SetModelScale(0.75)
					seed:SetNetworkedBool("Usable", true)
				end)
			else				
				client:notify("Растения можно сажать только в подходящую почву.")
				return false
			end
		else
			client:notify("Вы не можете посадить растение так далеко!")
			return false
		end
	end,
}