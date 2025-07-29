float ParseShorthand(char[] input, int size){
	int thousands = ReplaceString(input, size, "k", "", false);
	int millions = ReplaceString(input, size, "m", "", false);

	float num = StringToFloat(input);
	if(thousands)
		num*=1000.0;
	if(millions)
		num*=1000000.0;

	return num;
}

int SearchArray(int[] input, int size, int search){
	for(int i = 0; i<size; ++i){
		if(input[i] == search)
			return i;
	}
	return -1;
}

void ResetUpgradesForSlot(int client, int slot){
	int ItemEntity = TF2Util_GetPlayerLoadoutEntity(client, slot);
	if(slot == 4 || slot == 3)
		ItemEntity = client;

	CurrentWeaponDefinitions[client][slot] = -1;
	CurrentWeaponIDs[client][slot] = 0;
	CurrentPoints[client] += PointsSpentOnItem[client][slot];
	PointsSpentOnItem[client][slot] = 0.0;

	if(!IsValidEntity(ItemEntity))
		return;

	for(int i = 0;i < MaxAttributesPerItem; ++i){
		if(UpgradeIDsOnItem[client][slot][i] != -1)
			TF2Attrib_RemoveByName(ItemEntity, UpgradesArray[UpgradeIDsOnItem[client][slot][i]].AttributeName);
			
		UpgradeIDsOnItem[client][slot][i] = -1;
		UpgradeTimesOnItem[client][slot][i] = 0;
	}

	if(slot == 3){
		for(int i = 0; i < MaxCanteenSlots; ++i){
			CurrentCanteenSlots[client][i] = -1;
		}
	}
}

bool PurchaseUpgrade(int client, int slot, int SelectedUpgrade, int rate){
	//Upgrading
	if(rate > 0){
		int Position = GetPositionOfAttribute(client, slot, SelectedUpgrade);
		if(Position == -1){
			PrintToChat(client, "Item ran out of upgrade slots!");
			return false;
		}

		//just to shorten the formulas...
		float scalefactor = UpgradesArray[SelectedUpgrade].CostIncreasePerUpgrade;
		float currentCost = UpgradesArray[SelectedUpgrade].Cost + (scalefactor * UpgradeTimesOnItem[client][slot][Position]);
		char upgradeName[64];
		strcopy(upgradeName, sizeof(upgradeName), UpgradesArray[SelectedUpgrade].DisplayName[0] ? UpgradesArray[SelectedUpgrade].DisplayName : UpgradesArray[SelectedUpgrade].Name);
		if(CurrentPoints[client] < currentCost){
			PrintToChat(client, "Not enough points for %s.", upgradeName);
			return false;
		}
		
		if(IsUpgradeAtMaximum(client, slot, SelectedUpgrade)){
			PrintToChat(client, "You have already reached the maximum value for %s.", upgradeName);
			return false;
		}

		int MaximumPurchases;
		if(scalefactor != 0)
			MaximumPurchases = RoundToFloor( ((-2.0 * currentCost)+scalefactor+SquareRoot(Pow((2.0 * currentCost)-scalefactor, 2.0)+(scalefactor*8.0)*CurrentPoints[client]))/(scalefactor*2.0) );
		else
			MaximumPurchases = RoundToFloor(CurrentPoints[client]/currentCost);

		if(rate > MaximumPurchases)
			rate = MaximumPurchases;

		rate = ClampUpgradeCount(client, slot, SelectedUpgrade, rate);

		float TotalCost = rate * (currentCost + (scalefactor * (rate-1) / 2.0));
		CurrentPoints[client] -= TotalCost;
		UpgradeTimesOnItem[client][slot][Position] += rate;
		PointsSpentOnItem[client][slot] += TotalCost;
		UpgradeIDsOnItem[client][slot][Position] = SelectedUpgrade;

		//PrintToServer("%i times? | %i rate | %i max", UpgradeTimesOnItem[client][slot][Position], rate, MaximumPurchases)
		UpdateItemStats(client, slot);
	}else{//Downgrading
		int times;
		float scalefactor = UpgradesArray[SelectedUpgrade].CostIncreasePerUpgrade;

		int Position = GetPositionOfAttribute(client, slot, SelectedUpgrade, false);
		if(Position == -1){
			PrintToChat(client, "Cannot downgrade an unbought attribute.");
			return false;
		}

		for (; times > rate;)
		{
			if(UpgradeTimesOnItem[client][slot][Position] == 0)
				break;

			float currentCost = UpgradesArray[SelectedUpgrade].Cost + (scalefactor * (UpgradeTimesOnItem[client][slot][Position] - 1) );
			CurrentPoints[client] += currentCost;
			UpgradeTimesOnItem[client][slot][Position]--;
			PointsSpentOnItem[client][slot] -= currentCost;
			times--;
		}

		if(times < 0)
			UpdateItemStats(client, slot);
	}

	return true;
}

int ClampUpgradeCount(int client, int slot, int SelectedUpgrade, int increase){
	float CurrentValue = (UpgradeTimesOnItem[client][slot][GetPositionOfAttribute(client,slot,SelectedUpgrade)] * UpgradesArray[SelectedUpgrade].IncrementPerUpgrade) + UpgradesArray[SelectedUpgrade].InitialValue;
	if(UpgradesArray[SelectedUpgrade].IncrementPerUpgrade > 0){
		int overflow = RoundFloat( (CurrentValue + increase*UpgradesArray[SelectedUpgrade].IncrementPerUpgrade - UpgradesArray[SelectedUpgrade].MaximumValue) / UpgradesArray[SelectedUpgrade].IncrementPerUpgrade);
		if(overflow > 0)
			increase -= overflow;
	}else{
		float increment = -UpgradesArray[SelectedUpgrade].IncrementPerUpgrade;
		int overflow = RoundFloat( ( (increase*increment - CurrentValue) / increment) + (UpgradesArray[SelectedUpgrade].MaximumValue/increment));
		//PrintToServer("%i overflow? | %.2f what | %i inc | %.2f increment", overflow, ( (CurrentValue + (increase*increment) - UpgradesArray[SelectedUpgrade].InitialValue) / increment), increase, increment);
		if(overflow > 0)
			increase -= overflow;
	}
	return increase;
}

bool IsUpgradeAtMaximum(int client, int slot, int SelectedUpgrade){
	float CurrentValue = (UpgradeTimesOnItem[client][slot][GetPositionOfAttribute(client,slot,SelectedUpgrade)] * UpgradesArray[SelectedUpgrade].IncrementPerUpgrade) + UpgradesArray[SelectedUpgrade].InitialValue;
	return (CurrentValue >= UpgradesArray[SelectedUpgrade].MaximumValue && UpgradesArray[SelectedUpgrade].IncrementPerUpgrade > 0) || (CurrentValue <= UpgradesArray[SelectedUpgrade].MaximumValue && UpgradesArray[SelectedUpgrade].IncrementPerUpgrade < 0)
}

float GetUpgradeCurrentValue(int client, int slot, int SelectedUpgrade){
	//PrintToServer("%i position?", GetPositionOfAttribute(client,slot,SelectedUpgrade));
	float CurrentValue = (UpgradeTimesOnItem[client][slot][GetPositionOfAttribute(client,slot,SelectedUpgrade)] * UpgradesArray[SelectedUpgrade].IncrementPerUpgrade) + UpgradesArray[SelectedUpgrade].InitialValue;
	if(IsUpgradeAtMaximum(client, slot, SelectedUpgrade)){
		CurrentValue = UpgradesArray[SelectedUpgrade].MaximumValue;
	}
	return CurrentValue;
}

void UpdateItemStats(int client, int slot){
	int ItemEntity = CurrentWeaponEntities[client][slot];
	if(slot == 4 || slot == 3)
		ItemEntity = client;

	if(!IsValidEntity(ItemEntity))
		return;

	for(int i = 0; i < MaxAttributesPerItem; ++i){
		if(UpgradeIDsOnItem[client][slot][i] != -1){
			TF2Attrib_SetByName(ItemEntity, UpgradesArray[UpgradeIDsOnItem[client][slot][i]].AttributeName, GetUpgradeCurrentValue(client, slot, UpgradeIDsOnItem[client][slot][i]));
		}
	}

	//NOW WE DO THE CANTEEN SLOPPA
	if(ItemEntity == client){
		for(int i = 0; i < MaxCanteenSlots; ++i){
			CurrentCanteenSlots[client][i] = -1;
		}

		int canteenSize = TrieSnapshotLength(CanteenSnapshot);
		char keyvalue[64];
		int currentSlot = 0;
		for(int i = 0; i < canteenSize && currentSlot < MaxCanteenSlots; ++i){
			GetTrieSnapshotKey(CanteenSnapshot, i, keyvalue, sizeof(keyvalue));
			int value = TF2Attrib_HookValueInt(0, keyvalue, ItemEntity);
			if(value > 0){
				CurrentCanteenSlots[client][currentSlot] = i;
				currentSlot++;
			}
		}
	}
}

void AwardPointsToPlayers(int amount){
	for(int i=1;i<=MaxClients;++i){
		if(IsClientConnected(i))
			CurrentPoints[i] += amount;
	}
	TotalPoints += amount;
	PrintToChatAll("Awarded %i Points to All Players.", amount);
	PrintToChatAll("New Multipliers: %.2fx Health, %.2fx Damage, %.2fx Heal", GetHealthPointScaling(), GetDamagePointScaling(), GetHealingPointScaling());
	//UpdatePlayerMaxHealth();
}

float GetHealthPointScaling(){
	return Pow(1.06, TotalPoints) * 1+(0.15*TotalPoints);
}
float GetDamagePointScaling(){
	return Pow(1.06, TotalPoints) * 1+(0.05*TotalPoints);
}
float GetHealingPointScaling(){
	return Pow(1.06, TotalPoints) * 1+(0.03*TotalPoints);
}

/*void UpdatePlayerMaxHealth(){
	for(int i = 1; i <= MaxClients; ++i){
		if(!IsClientConnected(i))
			continue;

		int maxHP = GetPlayerInitialMaxHP(i);
		TF2Attrib_SetByName(i, "max health additive penalty", maxHP * (GetHealthPointScaling() - 1));
	}
}*/
int GetPositionOfAttribute(int client, int slot, int SelectedUpgrade, bool ShouldSeek = true){
	int Position = SearchArray(UpgradeIDsOnItem[client][slot], MaxAttributesPerItem, SelectedUpgrade);
	if(ShouldSeek && Position == -1)
		Position = SearchArray(UpgradeIDsOnItem[client][slot], MaxAttributesPerItem, -1);
	return Position;
}

int GetUpgradeRate(int client){
	int rate = 1;
	if(CurrentButtons[client] & IN_DUCK)
		rate *= 10;
	if(CurrentButtons[client] & IN_JUMP)
		rate *= -1;

	return rate;
}

void OnUseCanteenID(int client, int id){
	if(CurrentCanteenCooldowns[client] > GetGameTime()){
		PrintHintText(client, "Canteen is not off cooldown.");
		return;
	}

	char AttributeBuffer[64];
    char DisplayBuffer[64];
	GetTrieSnapshotKey(CanteenSnapshot, id, AttributeBuffer, sizeof(AttributeBuffer));
	GetTrieString(CanteenListTrie, AttributeBuffer, DisplayBuffer, sizeof(DisplayBuffer));
	float value = TF2Attrib_HookValueFloat(0.0, AttributeBuffer, client);
	float cdreduction = TF2Attrib_HookValueFloat(1.0, "canteen_recharge_rate_bonus", client);
	if(value <= 0){
		PrintToServer("bruh what");
		return;
	}
	PrintHintText(client, "Used %s LVL %.0f!", DisplayBuffer, value);
	OnCanteenUsed(AttributeBuffer, client, value, cdreduction);
}

void SendUpgradeDescription(int client, const char[] text, float value)
{
	char formula[64];
	char result[64];
	char ValueAsString[32];
	char textCopy[256];
	strcopy(textCopy, sizeof(textCopy), text);

	FloatToString(value, ValueAsString, sizeof(ValueAsString));

	int FormulaStartLocation = FindCharInString(textCopy, '[');
	while(FormulaStartLocation != -1){
		strcopy(formula, FindCharInString(textCopy[FormulaStartLocation+1], ']')+1, textCopy[FormulaStartLocation+1]); 
		strcopy(result, sizeof(result), formula);
		ReplaceString(result, sizeof(result), "{VALUE}", ValueAsString);
		Format(result, sizeof(result), "return %s;", result);
		HSCRIPT script = VScript_CompileScript(result);
		
		VScriptExecute execute = new VScriptExecute(script);
		execute.Execute();
		Format(result, sizeof(result), "%.1f",execute.ReturnValue);
		ReplaceStringEx(textCopy, 256, "[", "");
		ReplaceStringEx(textCopy, 256, "]", "");
		ReplaceStringEx(textCopy, 256, formula, result);
		FormulaStartLocation = FindCharInString(textCopy, '[');
	}

	SendItemInfo(client, textCopy);
}

void ConsumePierce(float& resist, float& pierce){
	if(pierce > 1-resist){
		pierce -= 1-resist;
		resist = 1.0;
	}else{
		resist += pierce;
		pierce = 0.0;
	}
}

stock void SendItemInfo(int client, const char[] text)
{
	char itemText[256];
	Format(itemText, sizeof(itemText), text);

	Handle hBuffer = StartMessageOne("KeyHintText", client);
	BfWriteByte(hBuffer, 1);
	BfWriteString(hBuffer, itemText);
	EndMessage();
}

/*int GetPlayerInitialMaxHP(int client){
	int maxHP = 0;
	switch(TF2_GetPlayerClass(client)){
		case TFClass_Scout, TFClass_Sniper, TFClass_Spy: {maxHP = 125;}
		case TFClass_Soldier: {maxHP = 200;}
		case TFClass_Pyro, TFClass_DemoMan: {maxHP = 175;}
		case TFClass_Heavy: {maxHP = 300;}
		case TFClass_Engineer, TFClass_Medic: {maxHP = 150;}
	}
	for(int slot = 0; slot < MaxSlots; ++slot){
		int weapon = TF2Util_GetPlayerLoadoutEntity(client, slot);
		if(!IsValidEntity(weapon))
			continue;

		//maxHP += TF2Attrib_HookValueInt(0, "add_maxhealth", weapon);
	}
	PrintToServer("%i", maxHP);
	return maxHP;
}*/

/*
float GetAttributeValue(int entity, char[] name, float init=1.0){
	float value = init;
	Address addr = TF2Attrib_GetByName(entity, name);
	if(addr != Address_Null){
		value = TF2Attrib_GetValue(addr);
	}
	return value;
}
*/