/*---------------------------------------------------------------------------
Create a shipment from a spawned_weapon
---------------------------------------------------------------------------*/
local function createShipment(ply, args)
	local id = tonumber(args) or -1
	local ent = Entity(id);

	ent = IsValid(ent) and ent or ply:GetEyeTrace().Entity

	if not IsValid(ent) or ent:GetClass() ~= "spawned_weapon" or ent.PlayerUse == false then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""));
		return
	end

	local pos = ent:GetPos();

	if pos:Distance(ply:GetShootPos()) > 130 or not pos:isInSight({ent, ply} , ply) then
		fprp.notify(ply, 1, 4, fprp.getPhrase("distance_too_big"));
		return
	end

	ent.PlayerUse = false

	local shipID
	for k,v in pairs(CustomShipments) do
		if v.entity == ent:GetWeaponClass() then
			shipID = k
			break
		end
	end

	if not shipID then
		fprp.notify(ply, 1, 4, fprp.getPhrase("unable", "/makeshipment", ""));
		return
	end

	local crate = ents.Create(CustomShipments[shipID].shipmentClass or "spawned_shipment");
	crate.SID = ply.SID
	crate:SetPos(ent:GetPos());
	crate.nodupe = true
	crate:SetContents(shipID, ent.dt.amount);
	crate:Spawn();
	crate:SetPlayer(ply);
	crate.clip1 = ent.clip1
	crate.clip2 = ent.clip2
	crate.ammoadd = ent.ammoadd or 0

	SafeRemoveEntity(ent);

	local phys = crate:GetPhysicsObject();
	phys:Wake();
end
fprp.defineChatCommand("makeshipment", createShipment, 0.3);

/*---------------------------------------------------------------------------
Split a shipment in two
---------------------------------------------------------------------------*/
local function splitShipment(ply, args)
	local id = tonumber(args) or -1
	local ent = Entity(id);

	ent = IsValid(ent) and ent or ply:GetEyeTrace().Entity

	if not IsValid(ent) or ent:GetClass() ~= "spawned_shipment" then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""));
		return
	end

	if ent:Getcount() < 2 or ent.locked then
		fprp.notify(ply, 1, 4, fprp.getPhrase("shipment_cannot_split"));
		return
	end

	local pos = ent:GetPos();

	if pos:Distance(ply:GetShootPos()) > 130 or not pos:isInSight({ent, ply} , ply) then
		fprp.notify(ply, 1, 4, fprp.getPhrase("distance_too_big"));
		return
	end

	local count = math.floor(ent:Getcount() / 2);
	ent:Setcount(ent:Getcount() - count);

	ent:StartSpawning();

	local crate = ents.Create("spawned_shipment");
	crate.locked = true
	crate.SID = ply.SID
	crate:SetPos(ent:GetPos());
	crate.nodupe = true
	crate:SetContents(ent:Getcontents(), count);
	crate:SetPlayer(ply);

	crate.clip1 = ent.clip1
	crate.clip2 = ent.clip2
	crate.ammoadd = ent.ammoadd

	crate:Spawn();

	local phys = crate:GetPhysicsObject();
	phys:Wake();
end
fprp.defineChatCommand("splitshipment", splitShipment, 0.3);
