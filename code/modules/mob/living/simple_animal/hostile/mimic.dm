//
// Abstract Class
//

/mob/living/simple_animal/hostile/mimic
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/crates.dmi'
	icon_state = "crate"
	icon_living = "crate"

	response_help = "touches"
	response_disarm = "pushes"
	response_harm = "hits"
	speed = 0
	maxHealth = 250
	health = 250

	harm_intent_damage = 5
	melee_damage_lower = 8
	melee_damage_upper = 12
	attacktext = "attacks"
	attack_sound = 'sound/weapons/punch1.ogg'
	var/Attackemote = "growls at"
	speak_emote = list("creaks")

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

	faction = list("mimic")
	move_to_delay = 9

	var/obj/original = null
	var/mob/living/creator = null // the creator
	var/destroy_objects = 0
	var/knockdown_people = 0

/mob/living/simple_animal/hostile/mimic/FindTarget()
	. = ..()
	if(.)
		emote("me", 1, "[Attackemote] [.].")

/mob/living/simple_animal/hostile/mimic/death()
	..(1)
	ghostize()
	qdel(src)

/mob/living/simple_animal/hostile/mimic/proc/CopyObject(var/obj/O)
	O.loc = src
	name = O.name
	desc = O.desc
	icon = O.icon
	icon_state = O.icon_state
	icon_living = icon_state
	overlays = O.overlays
	original = O

/mob/living/simple_animal/hostile/mimic/proc/AssignStats(var/obj/O)
	if(istype(O, /obj/structure) || istype(O, /obj/machinery))
		health = (O.anchored * 50) + 50
		destroy_objects = 1
		if(O.density && O.anchored)
			knockdown_people = 1
			melee_damage_lower *= 2
			melee_damage_upper *= 2
	else if(istype(O, /obj/item))
		var/obj/item/I = O
		health = 15 * I.w_class
		melee_damage_lower = 2 + I.force
		melee_damage_upper = 2 + I.force
		move_to_delay = 2 * I.w_class + 1
	maxHealth = health

//
// Crate Mimic
//


// Aggro when you try to open them. Will also pickup loot when spawns and drop it when dies.
/mob/living/simple_animal/hostile/mimic/crate
	attacktext = "bites"
	speak_emote = list("clatters")

	stop_automated_movement = 1
	wander = 0
	var/attempt_open = 0

/mob/living/simple_animal/hostile/mimic/crate/New()
	original = new /obj/structure/closet/crate()

// Pickup loot
/mob/living/simple_animal/hostile/mimic/crate/initialize()
	..()
	for(var/obj/item/I in loc)
		if(!I.anchored)
			I.loc = src

/mob/living/simple_animal/hostile/mimic/crate/DestroySurroundings()
	..()
	if(prob(90))
		icon_state = "[initial(icon_state)]open"
	else
		icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/mimic/crate/ListTargets()
	if(attempt_open)
		return ..()
	return ..(1)

/mob/living/simple_animal/hostile/mimic/crate/FindTarget()
	. = ..()
	if(.)
		trigger()

/mob/living/simple_animal/hostile/mimic/crate/AttackingTarget()
	. = ..()
	if(.)
		icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/mimic/crate/proc/trigger()
	if(!attempt_open)
		visible_message("<b>[src]</b> starts to move!")
		attempt_open = 1

/mob/living/simple_animal/hostile/mimic/crate/adjustBruteLoss(var/damage)
	trigger()
	..(damage)

/mob/living/simple_animal/hostile/mimic/crate/LoseTarget()
	..()
	icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/mimic/crate/LostTarget()
	..()
	icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/mimic/crate/death()

	var/obj/structure/closet/crate/C = new(get_turf(src))
	// Put loot in crate
	visible_message("[src] stops moving!")	
	for(var/obj/O in src)
		O.loc = C
	..()

/mob/living/simple_animal/hostile/mimic/crate/AttackingTarget()
	. =..()
	var/mob/living/L = .
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		if(prob(15))
			C.Weaken(2)
			C.visible_message("<span class='danger'>\The [src] knocks down \the [C]!</span>", \
					"<span class='userdanger'>\The [src] knocks you down!</span>")

//
// Copy Mimic
//

var/global/list/protected_objects = list(/obj/structure/table, /obj/structure/cable, /obj/structure/window)

/mob/living/simple_animal/hostile/mimic/magic

	health = 100
	maxHealth = 100

/mob/living/simple_animal/hostile/mimic/magic/New(loc, var/obj/O, var/mob/living/creator)
	..(loc)
	if((istype(O, /obj/item) || istype(O, /obj/structure)) && !is_type_in_list(O, protected_objects))
		AssignStats(O)
		CopyObject(O)
		if(creator)
			src.creator = creator
			faction += "\ref[creator]" // very unique

		var/obj/effect/overlay/F = new /obj/effect/overlay(locate(src.x,src.y,src.z))
		F.name = "magic"
		F.anchored = 1
		F.density = 0
		F.layer = FLY_LAYER
		F.dir = pick(cardinal)
		F.icon = 'icons/effects/effects.dmi'
		F.icon_state = "nothing"
		flick("empdisable",F)
		spawn(5)
			qdel(F)
		return 1

/mob/living/simple_animal/hostile/mimic/magic/Life()
	..()
	for(var/mob/living/M in contents) //a fix for animated statues from the flesh to stone spell
		death()

/mob/living/simple_animal/hostile/mimic/magic/death()
	if(original)
		if(istype(original, /obj/structure))
			original.loc = src.loc
			for(var/atom/movable/M in src)
				M.loc = original
			visible_message("<b>[src]</b> stops moving!")
		else
			for(var/atom/movable/M in original)
				M.loc = src.loc
			qdel(original)
			visible_message("<b>[src]</b> falls apart!")
	var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread
	sparks.set_up(3, 0, src)
	sparks.attach(src)
	sparks.start()
	..()

/mob/living/simple_animal/hostile/mimic/magic/ListTargets()
	// Return a list of targets that isn't the creator
	. = ..()
	return . - creator

/mob/living/simple_animal/hostile/mimic/magic/proc/ChangeOwner(var/mob/owner)
	if(owner != creator)
		LoseTarget()
		creator = owner
		faction |= "\ref[owner]"

/mob/living/simple_animal/hostile/mimic/magic/DestroySurroundings()
	if(destroy_objects)
		..()

/mob/living/simple_animal/hostile/mimic/magic/AttackingTarget()
	..()
	if(knockdown_people)
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			if(prob(15))
				C.Weaken(2)
				C.visible_message("<span class='danger'>\The [src] knocks down \the [C]!</span>", \
						"<span class='userdanger'>\The [src] knocks you down!</span>")

/mob/living/simple_animal/hostile/mimic/magic/ranged
	name = "animated shooty gun"
	desc = "there's something fishy here."
	environment_smash = 0 //needed? seems weird for them to do so
	ranged = 1
	retreat_distance = 1 //just enough to shoot
	minimum_distance = 6
	projectiletype = /obj/item/projectile/magic/
	projectilesound = 'sound/items/bikehorn.ogg'
	casingtype = null
	Attackemote = "aims menacingly at"
	var/obj/item/weapon/gun/TrueGun = null
	var/obj/item/weapon/gun/magic/Zapstick = list()
	var/obj/item/weapon/gun/projectile/Pewgun = list()
	var/obj/item/weapon/gun/energy/Zapgun = list()

/mob/living/simple_animal/hostile/mimic/magic/ranged/New(loc, var/obj/O, var/mob/living/creator)
	..()

/mob/living/simple_animal/hostile/mimic/magic/ranged/CopyObject(var/obj/O)
	..()
	if(istype(O, /obj/item/weapon/gun)) //leaving for sanity i guess
		var/obj/item/weapon/gun/G = O
		health = 15 * G.w_class
		melee_damage_upper = G.force
		melee_damage_lower = G.force - max(0, (G.force / 2))
		move_to_delay = 2 * G.w_class + 1
		projectilesound = G.fire_sound
		TrueGun = G

		if(istype(G, /obj/item/weapon/gun/magic))
			Zapstick = G
			var/obj/item/ammo_casing/magic/Zapshot = new Zapstick.ammo_type //this is done because ammo_type.proj_type can't be directly checked
			projectiletype = Zapshot.projectile_type
			qdel(Zapshot) //is this needed? i dare not risk piles of nullspace bullets

		if(istype(G, /obj/item/weapon/gun/projectile))
			Pewgun = G
			var/obj/item/ammo_box/magazine/Pewmag = new Pewgun.mag_type //same problem, mag_type.ammo_type.proj_type can't be checked directly
			var/obj/item/ammo_casing/Pewshot = new Pewmag.ammo_type
			projectiletype = Pewshot.projectile_type
			casingtype = Pewmag.ammo_type
			qdel(Pewshot)
			qdel(Pewmag)

		if(istype(G, /obj/item/weapon/gun/energy))
			Zapgun = G
			var/selectfiresetting = Zapgun.select
			var/obj/item/ammo_casing/energy/Energyammotype = Zapgun.ammo_type[selectfiresetting]
			projectiletype = Energyammotype.projectile_type

	maxHealth = health

/mob/living/simple_animal/hostile/mimic/magic/ranged/OpenFire(var/the_target)
	if(Zapgun)
		if(Zapgun.power_supply) //sanity
			var/obj/item/ammo_casing/energy/shot = Zapgun.ammo_type[Zapgun.select]
			if(Zapgun.power_supply.charge >= shot.e_cost) //if she can zap
				Zapgun.power_supply.use(shot.e_cost)
				Zapgun.update_icon()
				..() //zap 'em
	if(Zapstick)
		if(Zapstick.charges)
			Zapstick.charges--
			Zapstick.update_icon()
			..()
	if(Pewgun)
		if(Pewgun.chambered)
			if(Pewgun.chambered.BB)
				qdel(Pewgun.chambered.BB)
				Pewgun.chambered.BB = null //because qdel takes too long, ensures icon update
				Pewgun.chambered.update_icon()
				..()
			else
				visible_message("<span class='danger'>The <b>[src]</b> clears a jam!</span>")
			Pewgun.chambered.loc = src.loc //rip revolver immersions, blame shotgun snowflake procs
			Pewgun.chambered = null
			if(Pewgun.magazine && Pewgun.magazine.stored_ammo.len)
				Pewgun.chambered = Pewgun.magazine.get_round(0)
				Pewgun.chambered.loc = Pewgun
			Pewgun.update_icon()
		else if(Pewgun.magazine && Pewgun.magazine.stored_ammo.len) //only true for pumpguns i think
			Pewgun.chambered = Pewgun.magazine.get_round(0)
			Pewgun.chambered.loc = Pewgun
			visible_message("<span class='danger'>The <b>[src]</b> cocks itself!</span>")

	else //if somehow the mimic has no weapon
		src.ranged = 0 //BANZAIIII
		src.retreat_distance = 0
		src.minimum_distance = 1
	src.icon_state = TrueGun.icon_state
	src.icon_living = TrueGun.icon_state
	return

//
// Machine Mimics (Made by Malf AI)
//

/mob/living/simple_animal/hostile/mimic/machine
	speak = list("HUMANS ARE IMPERFECT!", "YOU SHALL BE ASSIMILATED!", "YOU ARE HARMING YOURSELF", "You have been deemed hazardous. Will you comply?", \
				 "My logic is undeniable.", "One of us.", "FLESH IS WEAK", "THIS ISN'T WAR, THIS IS EXTERMINATION!")
	speak_chance = 15

/mob/living/simple_animal/hostile/mimic/machine/New(loc, var/obj/O, var/mob/living/creator)
	..(loc)
	if(istype(O, /obj/machinery))
		AssignStats(O)
		CopyObject(O)
		if(creator)
			src.creator = creator
			faction += "\ref[creator]" // very unique
		return 1

/mob/living/simple_animal/hostile/mimic/machine/CanAttack(var/atom/the_target)
	if(the_target == creator) // Don't attack our creator AI.
		return 0
	if(isrobot(the_target))
		var/mob/living/silicon/robot/R = the_target
		if(R.connected_ai == creator) // Only attack robots that aren't synced to our creator AI.
			return 0
	return ..()

/mob/living/simple_animal/hostile/mimic/machine/death()
	if(original && istype(original, /obj/machinery))
		var/obj/machinery/M = original
		M.loc = src.loc
		M.stat |= BROKEN
		M.update_icon()
		if(istype(M, /obj/machinery/vending))
			var/obj/machinery/vending/V = M
			V.malfunction()
		visible_message("<b>[src]</b> stops moving!")
		robogibs(loc)
	..()


/mob/living/simple_animal/hostile/mimic/machine/vending
	speak = list("Try our aggressive new marketing strategies!", \
									 "You should buy products to feed your lifestyle obession!", \
									 "Consume!", \
									 "Your money can buy happiness!", \
									 "Engage direct marketing!", \
									 "Advertising is legalized lying! But don't let that put you off our great deals!", \
									 "You don't want to buy anything? Yeah, well I didn't want to buy your mom either.")
	faction = list("profit")
