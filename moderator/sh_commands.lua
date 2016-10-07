PLUGIN.commands = {}

local times = {
	{1,"1 Год","1г"},
	{2,"1 Месяц","1м"},
	{3,"1 Неделя","1н"},
	{4,"1 День","1д"},
	{5,"30 Минут","30м"},
	{6,"1 Минута","1м"},
}
local reasons = {
	"Неуважение администрации.",
	"Некорректный RolePlay.",
	"Метагейм.",
	"Пауэргейм.",
	"Неуважительный RP.",
	"Нечестная игра.",
	"Нарушение авторских прав.",
	"Пошел нахуй.",
}

function PLUGIN:GetTimeByString(data)
	if (!data) then
		return 0
	end

	data = string.lower(data)

	local time = 0

	for i = 1, 5 do
		local info = self.timeData[i]

		data = string.gsub(data, "(%d+)"..info[1], function(match)
			local amount = tonumber(match)

			if (amount) then
				time = time + (amount * info[2])
			end

			return ""
		end)
	end

	local seconds = tonumber(string.match(data, "(%d+)")) or 0

	time = time + seconds

	return math.max(time, 0)
end


function PLUGIN:CreateCommand(data, command)
	if (!data or !command) then
		return
	end

	local callback = data.onRun
	local group = data.group
	local syntax = data.syntax or "[none]"
	local hasTarget = data.hasTarget
	local allowDead = data.allowDead

	if (hasTarget == nil) then
		hasTarget = true
	end

	if (allowDead == nil) then
		allowDead = true
	end
	data.onMenu = data.onMenu or function( menu, icon, client, command )
		menu:AddOption(client:Name(), function()
			LocalPlayer():ConCommand( 'say /'..command..' "'..client:Name()..'"' )
		end):SetImage(icon)--nut.schema.Call("GetUserIcon", client) or icon)
	end
	self.commands[command] = data
	
	nut.command.add(command, {
		syntax = (hasTarget and "<string target> " or "")..syntax,
		allowDead = allowDead,
		hasPermission = function(client)
			return self:IsAllowed(client, group)
		end,
		silent = (data.silent or false),
		onRun = function(client, arguments)
			local target

			if (hasTarget) then
				target = nut.command.findPlayer(client, arguments[1])

				if (!IsValid(target)) then
					return
				end
			end

			if (IsValid(target) and !self:IsAllowed(client, target)) then
				client:notify("Цель выше Вас по рангу.")

				return
			end

			if (hasTarget) then
				table.remove(arguments, 1)
			end

			callback(client, arguments, target)
		end
	})
end


local PLUGIN = PLUGIN

PLUGIN:CreateCommand({
	text = "Создать Ранг",
	desc = "Создать новый ранг." ,
	group = "owner",
	syntax = "<string name> [number immunity]",
	hasTarget = false,
	onMenu = function( menu, icon, client, command )
	end,
	onRun = function(client, arguments)
		local name = arguments[1]
		local immunity = tonumber(arguments[2] or "0") or 0

		if (!name) then
			client:notify("Вы не привели название группы.")

			return
		end

		name = string.lower(name)

		PLUGIN:CreateRank(name, immunity)
		client:notify(client:Name().." создал ранг '"..name.."' с иммунитетом "..immunity..".")
	end
}, "newrank")

PLUGIN:CreateCommand({
	text = "Удалить ранг",
	desc = "Удалить существующий ранг." ,
	group = "owner",
	syntax = "<string name>",
	hasTarget = false,
	onMenu = function( menu, icon, client, command )
	end,
	onRun = function(client, arguments)
		local name = arguments[1]

		if (!name) then
			client:notify("Вы должны привести ранг.")

			return
		end

		name = string.lower(name)
		local removed, realName = PLUGIN:RemoveRank(name)

		if (removed) then
			client:notify(client:Name().." удалил ранг '"..realName.."'.")
		else
			client:notify("Этот ранг не существует.", client)
		end
	end
}, "delrank")

PLUGIN:CreateCommand({
	text = "Толкнуть игрока",
	desc = "Толкнуть игрока с заданными силой и уроном." ,
	group = "operator",
	syntax = "[number force]",
	onRun = function(client, arguments, target)
		local power = math.Clamp(tonumber(arguments[1] or "128"), 0, 1000)
		local direction = VectorRand() * power
		direction.z = math.max(power, 128)

		target:SetGroundEntity(NULL)
		target:SetVelocity(direction)
		target:EmitSound("physics/body/body_medium_impact_hard"..math.random(1, 6)..".wav")
		target:ViewPunch(direction:Angle() * (power / 10000))

		client:notify(client:Name().." толкнул "..target:Name().." с силой "..power..".")
	end
}, "slap")

PLUGIN:CreateCommand({
	text = "Убить игрока",
	desc = "Убить игрока именем Модератора.",
	group = "operator",
	onRun = function(client, arguments, target)
		target:Kill()

		client:notify(client:Name().." убил "..target:Name()..".")
	end
}, "slay")

PLUGIN:CreateCommand({
	text = "Заморозить игрока",
	desc = "Игрок теряет контроль над персонажем.",
	group = "operator",
	onRun = function(client, arguments, target)
		target:Lock()

		client:notify(client:Name().." заморозил "..target:Name()..".")
	end
}, "freeze")

PLUGIN:CreateCommand({
	text = "Разморозить игрока",
	desc = "Возвращает игроку контроль над персонажем.",
	group = "operator",
	onRun = function(client, arguments, target)
		target:UnLock()

		client:notify(client:Name().." разморозил "..target:Name()..".")
	end
}, "unfreeze")

PLUGIN:CreateCommand({
	text = "Поджечь игрока",
	desc = "Игрок воспламеняется.",
	group = "admin",
	syntax = "[number time]",
	onRun = function(client, arguments, target)
		local time = math.max(tonumber(arguments[1] or "5"), 1)
		target:Ignite(time)

		client:notify(client:Name().." поджег "..target:Name().." на "..time.." секунд.")
	end
}, "ignite")

PLUGIN:CreateCommand({
	text = "Потушить игрока",
	desc = "Потушить огонь на игроке.",
	group = "admin",
	syntax = "[number time]",
	onRun = function(client, arguments, target)
		target:Extinguish()

		client:notify(client:Name().." потушил "..target:Name()..".")
	end
}, "unignite")

PLUGIN:CreateCommand({
	text = "Установить здоровье",
	desc = "Установить уровень здоровья игрока.",
	group = "operator",
	syntax = "[number health]",
	onMenu = function( menu, icon, client, command )
		local submenu = menu:AddSubMenu( client:Name() )
		for i = 1, 10 do
			submenu:AddOption(i*10, function()
				LocalPlayer():ConCommand( 'say /'..command..' "'..client:Name()..'" '.. i*10 )
			end):SetImage(icon)--nut.schema.Call("GetUserIcon", client) or icon)
		end
	end,
	onRun = function(client, arguments, target)
		-- No point of 0 HP, might as well just slay.
		local health = math.max(tonumber(arguments[1] or "100"), 1)
		target:SetHealth(health)

		client:notify(client:Name().." установил здоровье "..target:Name().." на "..health..".")
	end
}, "hp")

PLUGIN:CreateCommand({
	text = "Изъять оружие",
	desc = "Удалить все оружие игрока.",
	group = "admin",
	onRun = function(client, arguments, target)
		target:StripWeapons()

		client:notify(client:Name().." удалил оружие "..target:Name()..".")
	end
}, "strip")

PLUGIN:CreateCommand({
	text = "Выдать стандартное оружие",
	desc = "Выдать игроку оружие по умолчанию.",
	group = "admin",
	onRun = function(client, arguments, target)
		--target:SetMainBar()
		target:StripWeapons()
		client:SetModel(client:getChar():getModel())
		target:Give("nut_hands")
		target:SetWalkSpeed(nut.config.get("walkSpeed"))
		target:SetRunSpeed(nut.config.get("runSpeed"))
		target:setWepRaised(false)

		nut.flag.onSpawn(target)
		nut.attribs.setup(target)

		client:notify(client:Name().." выдал оружие по умолчанию "..target:Name()..".")
	end
}, "arm")

PLUGIN:CreateCommand({
	text = "Установить броню",
	desc = "Установить уровень брони игрока.",
	group = "operator",
	syntax = "[number armor]",
	onMenu = function( menu, icon, client, command )
		local submenu = menu:AddSubMenu( client:Name() )
		for i = 1, 10 do
			submenu:AddOption(i*10, function()
				LocalPlayer():ConCommand( 'say /'..command..' "'..client:Name()..'" '.. i*10 )
			end):SetImage(icon)--nut.schema.Call("GetUserIcon", client) or icon)
		end
	end,
	onRun = function(client, arguments, target)
		local armor = math.max(tonumber(arguments[1] or "100"), 0)
		target:SetArmor(armor)

		client:notify(client:Name().." установил уровень брони персонажа "..target:Name().." на "..armor..".")
	end
}, "armor")

PLUGIN:CreateCommand({
	text = "Телепортировать игрока",
	desc = "Телепортировать игрока А к игроку Б.",
	group = "admin",
	syntax = "[bool toAimPos]",
	onRun = function(client, arguments, target)
		local position = client:GetEyeTraceNoCursor().HitPos
		local toAimPos = util.tobool(arguments[1])

		if (!toAimPos) then
			local data = {}
				data.start = client:GetShootPos() + client:GetAimVector() * 32
				data.endpos = client:GetShootPos() + client:GetAimVector() * 72
				data.filter = client
			local trace = util.TraceLine(data)

			position = trace.HitPos
		end

		if (position) then
			target:SetPos(position)
			client:notify(client:Name().." телепортировал "..target:Name().." к "..(toAimPos and "к себе" or "его позиции")..".")
		else
			client:notify(target:Name().." не может быть телепортирован.")
		end
	end
}, "tp")

PLUGIN:CreateCommand({
	text = "Телепортироваться к игроку",
	desc = "Телепортироваться к игроку.",
	group = "admin",
	syntax = "[bool toAimPos]",
	onRun = function(client, arguments, target)
		local position = target:GetEyeTraceNoCursor().HitPos
		local toAimPos = util.tobool(arguments[1])

		if (!toAimPos) then
			local data = {}
				data.start = target:GetShootPos() + target:GetAimVector() * 32
				data.endpos = target:GetShootPos() + target:GetAimVector() * 72
				data.filter = target
			local trace = util.TraceLine(data)

			position = trace.HitPos
		end

		if (position) then
			client:SetPos(position)
			client:notify(client:Name().." телепортировался к позиции "..target:Name()".")
		else
			client:notify("Позиция для Вас не найдена.", client)
		end
	end
}, "goto")

PLUGIN:CreateCommand({
	text = "Отключить игрока",
	desc = "Отключить игрока от сервера.",
	group = "admin",
	syntax = "[string reason]",
	onMenu = function( menu, icon, client, command )
		local submenu = menu:AddSubMenu( client:Name() )
		for _, why in pairs( reasons ) do
			submenu:AddOption(why, function()
				LocalPlayer():ConCommand( 'say /'..command..' "'..client:Name()..'" '.. why )
			end):SetImage(icon)--nut.schema.Call("GetUserIcon", client) or icon)
		end
	end,
	onRun = function(client, arguments, target)
		local reason = "без причины"

		if (#arguments > 0) then
			reason = table.concat(arguments, " ")
		end
		
		local name = target:Name()

		target:Kick("Отключен "..client:Name().." ("..client:SteamID()..") по причине: "..reason)
		client:notify(client:Name().." отключил "..name.." за "..reason..".")
	end
}, "kick")

PLUGIN:CreateCommand({
	text = "Заблокировать игрока",
	desc = "Отключить игрока и запретить ему подключаться к серверу.",
	group = "admin",
	hasTarget = false,
	syntax = "[string time] [string reason]",
	onMenu = function( menu, icon, client, command )
		local submenu = menu:AddSubMenu( client:Name() )
		for _, why in pairs( reasons ) do
			local reasonmenu = submenu:AddSubMenu( why )
			for _, tdat in SortedPairsByMemberValue( times, 1 ) do
				reasonmenu:AddOption(tdat[2], function()
					LocalPlayer():ConCommand( 'say /'..command..' "'..client:Name()..'" "'.. tdat[3] .. '" "'.. why .. '"' )
				end):SetImage(icon)--nut.schema.Call("GetUserIcon", client) or icon)
			end
		end
	end,
	onRun = function(client, arguments)
		local target = nut.command.findPlayer(client, arguments[1], true)
		local targetname
		if (!target or !target:IsValid()) then
			if (string.StartWith(arguments[1], "STEAM_0")) then
				targetname = arguments[1]
				table.remove(arguments, 1)
			else
				client:notify(nut.lang.Get("no_ply"))
				return
			end
		else
			if (target == client) then
				client:notify("Вы попытались заблокировать себя. Введите другое имя.")
				return
			end
			targetname = target:Name()
			table.remove(arguments, 1)
		end
		local time = PLUGIN:GetTimeByString(arguments[1])
		table.remove(arguments, 1)

		local reason = "no reason"
		if (#arguments > 0) then
			reason = table.concat(arguments, " ")
		end
		
		local timetext
		if time == 0 then
			timetext = "перманентно"
		else
			timetext = PLUGIN:SecondsToFormattedString(time)
		end

		local bantext = Format("%s заблокировал на %s (%s)", targetname, timetext, reason)
		nut.util.AddLog(bantext, LOG_FILTER_MAJOR)
		nut.util.Notify(bantext, unpack(player.GetAll()))

		local steamid
		if target and target:IsValid() then
			steamid = target:SteamID()
		else
			steamid = targetname
		end
		PLUGIN:BanPlayer(steamid, time, reason)
	end
}, "ban")

PLUGIN:CreateCommand({
	text = "Изменить карту сервера",
	desc = "Изменить серверную карту.",
	group = "superadmin",
	syntax = "<string map> [number time]",
	hasTarget = false,
	onMenu = function( menu, icon, client, command )
	end,
	onRun = function(client, arguments)
		local map = arguments[1]
		local time = math.Clamp(tonumber(arguments[2] or "5"), 5, 60)

		if (!map) then
			client:notify("Вы должны представить карту.")

			return
		end

		map = string.lower(map)

		if (!file.Exists("maps/"..map..".bsp", "GAME")) then
			client:notify("Карта недействительна.")

			return
		end

		client:notify(client:Name().." изменил карту на "..map..". Смена карты произойдет через "..time.." секунд.")

		timer.Create("nut_ChangeMap", time, 1, function()
			game.ConsoleCommand("changelevel "..map.."\n")
		end)
	end
}, "map")

PLUGIN:CreateCommand({
	text = "Разблокировать игрока",
	desc = "Позволить заблокированному игроку подключаться к серверу.",
	group = "admin",
	hasTarget = false,
	syntax = "<string steamID>",
	onMenu = function( menu, icon, client, command )
	end,
	onRun = function(client, arguments, target)
		local steamID = arguments[1]

		if (!steamID) then
			client:notify(nut.lang.Get("missing_arg", 1))

			return
		end

		local result = PLUGIN:UnbanPlayer(steamID)

		if (result) then
			local bantext = Format("%s разблокировал %s ", client:Name(), steamID)
			nut.util.AddLog(bantext, LOG_FILTER_MAJOR)
			nut.util.Notify(bantext, unpack(player.GetAll()))
		else
			client:notify("Блокировка по данному SteamID не найдена.")
		end
	end
}, "unban")

PLUGIN:CreateCommand({
	text = "Установить ранг",
	desc = "Установить ранг игроку.",
	group = "owner",
	syntax = "<string name/steamID> [string group]",
	hasTarget = false,
	onMenu = function( menu, icon, client, command )
		local submenu = menu:AddSubMenu( client:Name() )
		for uid, power in pairs( PLUGIN.ranks ) do
			submenu:AddOption(uid, function()
				LocalPlayer():ConCommand( 'say /'..command..' "'..client:Name()..'" '.. uid )
			end):SetImage(icon)--.schema.Call("GetUserIcon", client) or icon)
		end
	end,
	onRun = function(client, arguments)
		local steamID = arguments[1]
		local group = arguments[2] or "user"

		if (!steamID) then
			client:notify(L("invalidArg", client, 1))

			return
		end

		local target

		-- If a player's name is passed since it is not a valid SteamID.
		if (!string.find(steamID, "STEAM_0:[01]:[0-9]+")) then
			target = nut.command.findPlayer(client, steamID)

			if (!IsValid(target)) then
				return
			end

			steamID = target:SteamID()
		end

		PLUGIN:SetUserGroup(steamID, group, target)
		client:notify(client:Name().." изменил группу "..(IsValid(target) and target:Name() or steamID).." на "..group..".")
	end
}, "rank")

if (SERVER) then
	concommand.Add("nut_setowner", function(client, command, arguments)
		if (!IsValid(client) or (IsValid(client) and client:IsListenServerHost())) then
			local steamID = arguments[1]

			if (!steamID) then
				print("You did not provide a valid player or SteamID.")

				return
			end

			local target

			-- If a player's name is passed since it is not a valid SteamID.
			if (!string.find(steamID, "STEAM_0:[01]:[0-9]+")) then
				target = nut.util.findPlayer(steamID)

				if (!IsValid(target)) then
					print("You did not provide a valid player.")

					return
				end

				steamID = target:SteamID()
			end

			PLUGIN:SetUserGroup(steamID, "owner", target)
			print("You have made "..(IsValid(target) and target:Name() or steamID).." an owner.")

			if (IsValid(target)) then
				target:notify("Вы были назначены владельцем сервера.")
			end
		else
			client:ChatPrint("Эту команду нужно вводить в консоль сервера.")
		end
	end)
end