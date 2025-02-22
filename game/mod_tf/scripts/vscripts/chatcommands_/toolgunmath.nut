function FindEntityForward(pMe, fHull){
	local mymask;
	if(fHull){
		mymask = 33570827
	} else {
		mymask = 1174421507
	}
	local tr =
	{
		start = pMe.EyePosition(),
		end = pMe.EyePosition() + (pMe.EyeAngles().Forward() * 32768.0),
		ignore = pMe
		mask = 33570827
	};
	TraceLineEx(tr)
	if ( tr.fraction != 1.0 && tr.enthit.tostring().find("([0]") != 0)
	{
		return tr.enthit
	}
	return null;
}
function FindEntityNearestFacing( vOrigin, vFacing, fThreshold )
{
	local bestDot = fThreshold,
		best_ent, ent = Entities.First();

	while ( ent = Entities.Next(ent) )
	{
		// skip all point sized entitites
		if (!ent.GetBoundingMaxs().x && !ent.GetBoundingMaxs().y && !ent.GetBoundingMaxs().z)
			continue;

		local to_ent = ent.GetOrigin() - vOrigin;

		to_ent.Norm();

		local dot = vFacing.Dot(to_ent);

		if ( dot > bestDot )
		{
			bestDot = dot;
			best_ent = ent;
		};
	}

	return best_ent;
}

function FindPickerEntity(pPlayer){
	local pEntity = FindEntityForward(pPlayer, true)
	if(!pEntity){
		local forward = pPlayer.GetForwardVector();
		local origin = pPlayer.GetOrigin();
		pEntity = FindEntityNearestFacing(origin, forward, 0.95)
	}
	return pEntity;
}