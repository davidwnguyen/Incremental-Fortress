public Action TF2_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom, CritType &critType) {
	return Plugin_Continue;
}
public Action TF2_OnTakeDamageModifyRules(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom, CritType &critType){
	float resist, pierce;
	if(0 < victim <= MaxClients){
		if(0 < attacker <= MaxClients){
			pierce = TF2Attrib_HookValueFloat(0.0, "resistance_piercing", attacker);
			damage *= GetDamagePointScaling();
		}

		if(damagetype & DMG_SHOCK){
			resist = TF2Attrib_HookValueFloat(1.0, "electric_resistance", victim);
		}else if(damagetype & DMG_BURN || damagetype & DMG_IGNITE){
			resist = TF2Attrib_HookValueFloat(1.0, "fire_resistance", victim);
		}else if(damagetype & DMG_BLAST){
			resist = TF2Attrib_HookValueFloat(1.0, "blast_resistance", victim);
		}else{
			resist = TF2Attrib_HookValueFloat(1.0, "physical_resistance", victim);
		}

		if(damagetype & DMG_FALL){
			damage *= TF2Attrib_HookValueFloat(1.0, "fall_damage_reduction", victim);
		}

		if(critType == CritType_Crit){
			//Reduce crits to only double damage.
			PrintToServer("yeah?");
			damage /= 3.0;

			float critNullify = TF2Attrib_HookValueFloat(0.0, "critical_nullify_rating", victim);
			float critRating = TF2Attrib_HookValueFloat(0.0, "critical_rating", attacker);
			if(critNullify/(critNullify+800) >= GetRandomFloat()){
				critType = CritType_None;
			}else{
				damage += damage*(critRating/critNullify);
			}
		}
		PrintToServer("%.2f resist, %.2f pierce", resist, pierce);
		damage *= resist + pierce;
	}
	return Plugin_Changed;
}