/mob/living/carbon/death(gibbed)
	silent = 0
	med_hud_set_health()
	med_hud_set_status()
	ticker.total_deaths++ //We only want to log carbon animals deaths.
	..(gibbed)
