
///////////////
//DRONE VERBS//
///////////////
//Drone verbs that appear in the Drone tab and on buttons


/mob/living/simple_animal/drone/verb/check_laws()
	set category = "Drone"
	set name = "Check Laws"

	src << "<b>Drone Laws</b>"
	src << laws

/mob/living/simple_animal/drone/verb/toggle_light()
	set category = "Drone"
	set name = "Toggle drone light"
	if(light_on)
		AddLuminosity(-4)
	else
		AddLuminosity(4)

	light_on = !light_on

	src << "<span class='notice'>Your light is now [light_on ? "on" : "off"].</span>"

/mob/living/simple_animal/drone/verb/drone_ping()
	set category = "Drone"
	set name = "Drone ping"

	var/alert_s = input(src,"Alert severity level","Drone ping",null) as null|anything in list("Low","Medium","High","Critical")

	var/area/A = get_area(loc)

	if(isSSD(src))
		return

	if(alert_s && A && stat != DEAD)
		var/msg = "<span class='boldnotice'>DRONE PING: [name]: [alert_s] priority alert in [A.name]!</span>"
		alert_drones(msg)


/mob/living/simple_animal/drone/verb/toggle_statics()
	set name = "Change Vision Filter"
	set desc = "Change the filter on the system used to remove non drone beings from your viewscreen."
	set category = "Drone"

	if(!seeStatic)
		src << "<span class='warning'>You have no vision filter to change!</span>"
		return

	var/selectedStatic = input("Select a vision filter", "Vision Filter") as null|anything in staticChoices
	if(selectedStatic in staticChoices)
		staticChoice = selectedStatic

	updateSeeStaticMobs()

//////////////////////
// SCOUT DRONE VERBS//
//////////////////////



/mob/living/simple_animal/drone/syndiscout/verb/terminate_link()
	set name = "Terminate Link"
	set desc = "Disconnects you immediately from the drone terminal."
	set category = "Drone"

	switch(alert("Select an option.","Terminate Link", "Proceed","Deny"))
		if("Proceed")
			src << "<span class='warning'>You decide to terminate the control link you have on the drone.</span>"
			src.mind.transfer_to(observer)
			src.observer = null
			src.observing = !src.observing
		if("Deny")
			return

/mob/living/simple_animal/drone/syndiscout/verb/hide()
	set name = "Hide"
	set desc = "Become invisible to the common eye."
	set category = "Drone"

	if(src.stat != CONSCIOUS)
		return

	if (src.layer != TURF_LAYER+0.2)
		src.layer = TURF_LAYER+0.2
		src.visible_message("<span class='name'>[src] ducks for cover!</span>", \
						"<span class='noticealien'>You are now hiding.</span>")
	else
		src.layer = MOB_LAYER
		src.visible_message("[src] slowly peaks up from the ground...", \
					"<span class='noticealien'>You stop hiding.</span>")
	return 1