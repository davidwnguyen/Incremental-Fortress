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
	CancelClientMenu(client);

	int ItemEntity = TF2Util_GetPlayerLoadoutEntity(client, slot);
	if(slot == 4 || slot == 3)
		ItemEntity = client;

	if(!IsValidEntity(ItemEntity))
		return;

	CurrentWeaponIDs[client][slot] = 0;
	CurrentPoints[client] += PointsSpentOnItem[client][slot];
	PointsSpentOnItem[client][slot] = 0.0;
	for(int i = 0;i < MaxAttributesPerItem; ++i){
		if(UpgradeIDsOnItem[client][slot][i] != -1)
			TF2Attrib_RemoveByName(ItemEntity, UpgradesArray[UpgradeIDsOnItem[client][slot][i]].AttributeName);
			
		UpgradeIDsOnItem[client][slot][i] = -1;
		UpgradeTimesOnItem[client][slot][i] = 0;
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
		if(CurrentPoints[client] < currentCost){
			PrintToChat(client, "Not enough points for %s.", UpgradesArray[SelectedUpgrade].Name);
			return false;
		}
		
		if(IsUpgradeAtMaximum(client, slot, SelectedUpgrade)){
			PrintToChat(client, "You have already reached the maximum value for %s.", UpgradesArray[SelectedUpgrade].Name);
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
}

void AwardPointsToPlayers(int amount){
	for(int i=1;i<=MaxClients;++i){
		if(IsClientConnected(i))
			CurrentPoints[i] += amount;
	}
	TotalPoints += amount;
	PrintToChatAll("Awarded %i Points to All Players.", amount);
	PrintToChatAll("New Multipliers: %.2fx Health, %.2fx Damage, %.2fx Heal", GetHealthPointScaling(), GetDamagePointScaling(), GetHealingPointScaling());
}

float GetHealthPointScaling(){
	return Pow(1.075, TotalPoints) + 0.1*TotalPoints;
}
float GetDamagePointScaling(){
	return Pow(1.05, TotalPoints) + 0.05*TotalPoints;
}
float GetHealingPointScaling(){
	return Pow(1.035, TotalPoints) + 0.04*TotalPoints;
}

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

stock void SendItemInfo(int client, const char[] text)
{
	char itemText[256];
	Format(itemText, sizeof(itemText), text);

	Handle hBuffer = StartMessageOne("KeyHintText", client);
	BfWriteByte(hBuffer, 1);
	BfWriteString(hBuffer, itemText);
	EndMessage();
}

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