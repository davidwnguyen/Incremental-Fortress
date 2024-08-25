public Action TF2_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom, CritType &critType) {
	damagetype |= DMG_SLASH;
	return Plugin_Changed;
}
public Action TF2_OnTakeDamageModifyRules(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom, CritType &critType){
	float resist = 1.0, pierce = 0.0;
	if(0 < victim <= MaxClients){
		if(0 < attacker <= MaxClients){
			pierce = TF2Attrib_HookValueFloat(0.0, "resistance_piercing", attacker);
			damage *= GetDamagePointScaling();
		}

		//Vaccinator trash
		VaccinatorDamageReductions(victim, damagetype, resist, pierce);
		damage *= resist;

		if(TF2_IsPlayerInCondition(victim, TFCond_DefenseBuffed)){
			resist = 0.65;
			ConsumePierce(resist, pierce);
			damage *= resist;
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
		ConsumePierce(resist, pierce);
		damage *= resist;

		if(damagetype & DMG_FALL){
			damage *= TF2Attrib_HookValueFloat(1.0, "fall_damage_reduction", victim);
		}

		if(critType == CritType_Crit){
			//Reduce crits to only double damage.
			damage /= 3.0;

			float critNullify = TF2Attrib_HookValueFloat(0.0, "critical_nullify_rating", victim);
			float critRating = TF2Attrib_HookValueFloat(0.0, "critical_rating", attacker);
			if(critNullify/(critNullify+800) >= GetRandomFloat()){
				critType = CritType_None;
			}else{
				damage += damage*((1+critRating/200.0)/(1+critNullify/200));
			}
		}
		PrintToChat(victim, "Final Damage: %.2f", damage);
	}
	return Plugin_Changed;
}

void VaccinatorDamageReductions(int victim, int damagetype, float &resist, float &pierce){
	resist = 1.0;
	if(damagetype & DMG_BLAST){
		if(TF2_IsPlayerInCondition(victim, TFCond_UberBlastResist)){
			resist = 0.33;
			ConsumePierce(resist, pierce);
		}
		else if(TF2_IsPlayerInCondition(victim, TFCond_SmallBlastResist)){
			resist = 0.75;
			ConsumePierce(resist, pierce);
		}
	}
	else if(damagetype & DMG_BURN | DMG_IGNITE){
		if(TF2_IsPlayerInCondition(victim, TFCond_UberFireResist)){
			resist = 0.33;
			ConsumePierce(resist, pierce);
		}
		else if(TF2_IsPlayerInCondition(victim, TFCond_SmallFireResist)){
			resist = 0.75;
			ConsumePierce(resist, pierce);
		}
	}
	else if(damagetype & DMG_BULLET){
		if(TF2_IsPlayerInCondition(victim, TFCond_UberBulletResist)){
			resist = 0.33;
			ConsumePierce(resist, pierce);
		}
		else if(TF2_IsPlayerInCondition(victim, TFCond_SmallBulletResist)){
			resist = 0.75;
			ConsumePierce(resist, pierce);
		}
	}
}