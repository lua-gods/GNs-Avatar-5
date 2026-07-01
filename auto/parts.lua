local PARTS = {
	BASE        = models.player.Base,
	TORSO       = models.player.Base.Torso,
	WAIST       = models.player.Base.Torso.Waist,
	CHEST       = models.player.Base.Torso.Waist.Chest,
	LEFT_ARM    = models.player.Base.Torso.Waist.Chest.LeftArm,
	LEFT_ELBOW  = models.player.Base.Torso.Waist.Chest.LeftArm.LeftElbow,
	RIGHT_ARM   = models.player.Base.Torso.Waist.Chest.RightArm,
	RIGHT_ELBOW = models.player.Base.Torso.Waist.Chest.RightArm.RightElbow,
	CAPE        = models.player.Base.Torso.Waist.Chest.Cape,
	HEAD        = models.player.Base.Torso.Waist.Chest.Head,
	HIPS        = models.player.Base.Hips,
	LEFT_LEG    = models.player.Base.Hips.LeftLeg,
	LEFT_Knee   = models.player.Base.Hips.LeftLeg.LeftKnee,
	RIGHT_LEG   = models.player.Base.Hips.RightLeg,
	RIGHT_KNEE  = models.player.Base.Hips.RightLeg.RightKnee,
	
	_BODY_TOP    = models.player.Base.Torso.Waist.Chest.BodyTop,
	_BODY_BOTTOM = models.player.Base.Torso.Waist.BodyBottom,
}
return PARTS