public Event_InventoryRefresh(Handle event, const char[] name, bool dontBroadcast){
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    if(0 >= client > MaxClients)
        return;

    if(CurrentWeaponIDs[client][4] != _:TF2_GetPlayerClass(client)){
        ResetUpgradesForSlot(client, 4);
        CurrentWeaponIDs[client][4] = _:TF2_GetPlayerClass(client);

        ResetUpgradesForSlot(client, 3);
        GetTrieValue(CategoryListTrie, "canteen", CurrentWeaponIDs[client][3]);
    }
    for(int i = 0;i < 3;++i){
        int WeaponID = TF2Util_GetPlayerLoadoutEntity(client, i);
        int DefinitionID;

        if(TF2_GetPlayerClass(client) == TFClass_Spy){
            if(i == 0){
                WeaponID = TF2Util_GetPlayerLoadoutEntity(client, TFWeaponSlot_Secondary);
            }else if(i == 1){
                WeaponID = TF2Util_GetPlayerLoadoutEntity(client, TFWeaponSlot_PDA);
            }
        }

        if(IsValidEntity(WeaponID)){
            DefinitionID = GetEntProp(WeaponID, Prop_Send, "m_iItemDefinitionIndex");
        }else{
            return;
        }

        if(CurrentWeaponDefinitions[client][i] != DefinitionID){
            CurrentWeaponDefinitions[client][i] = DefinitionID;
            ResetUpgradesForSlot(client, i);
        }
        if(CurrentWeaponEntities[client][i] != WeaponID){
            CurrentWeaponEntities[client][i] = WeaponID;
        }

        char WeaponClassname[64];
        GetEntityClassname(WeaponID, WeaponClassname, sizeof(WeaponClassname));
        GetTrieValue(WeaponListTrie, WeaponClassname, CurrentWeaponIDs[client][i]);
        if(CurrentWeaponIDs[client][i] == 0){
            CategoryExceptionsMap.GetString(DefinitionID, WeaponClassname, sizeof(WeaponClassname));
            GetTrieValue(CategoryListTrie, WeaponClassname, CurrentWeaponIDs[client][i]);
        }
    }
}

public Action OnGetMaxHealth(int client, int &maxhealth){
    if(TotalPoints > 0){
        maxhealth = RoundToCeil( GetHealthPointScaling() * maxhealth);
    }
    return Plugin_Changed;
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] weaponname, bool& result){
    int critRating = TF2Attrib_HookValueInt(0, "critical_rating", client);
    if(critRating > 0){
        float critRate = critRating/(critRating+200.0);
        if(critRate >= GetRandomFloat()){
            result = true;
        }
    }
    return Plugin_Handled;
}

public Action TF2_OnTakeHealthPre(int client, float &flAmount, int &flags){
    if(TotalPoints > 0){
        flAmount *= GetHealingPointScaling();
    }
    return Plugin_Changed;
}