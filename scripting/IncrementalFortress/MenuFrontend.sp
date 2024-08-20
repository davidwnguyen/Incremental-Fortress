void UpgradeMenuEntryPoint(int client){
    Menu UpgradeMenu = CreateMenu(MenuHandler_SlotChoice);
    char MenuTitle[64];
    Format(MenuTitle, sizeof(MenuTitle), "Incremental Fortress | Press Tab | $%.0f/%.0f", CurrentPoints[client], TotalPoints);
    SetMenuTitle(UpgradeMenu, MenuTitle);
    AddMenuItem(UpgradeMenu, "UpgradeBody", "Upgrade Body");
    AddMenuItem(UpgradeMenu, "UpgradePrimary", "Upgrade Primary Slot");
    AddMenuItem(UpgradeMenu, "UpgradeSecondary", "Upgrade Secondary Slot");
    AddMenuItem(UpgradeMenu, "UpgradeMelee", "Upgrade Melee Slot");
    AddMenuItem(UpgradeMenu, "UpgradeCanteen", "Upgrade Canteen");
    AddMenuItem(UpgradeMenu, "IncreasePoints", "Give A Point");
    DisplayMenuAtItem(UpgradeMenu, client, 0, MENU_TIME_FOREVER);
}

void UpgradeMenuShowSubcategories(int client, int slot){
    Menu UpgradeMenu = CreateMenu(MenuHandler_SubcategoryChoice);
    char MenuTitle[64];
    Format(MenuTitle, sizeof(MenuTitle), "Incremental Fortress | Press Tab | $%.0f/%.0f", CurrentPoints[client], TotalPoints);
    SetMenuTitle(UpgradeMenu, MenuTitle);
    SetMenuExitBackButton(UpgradeMenu, true);
    if(slot == -1)
        slot = 4;

    CurrentMenuSlot[client] = slot;
    PrintToServer("%i", CurrentWeaponIDs[client][slot]);
    if (CurrentWeaponIDs[client][slot] > 0)
    {
        char Buffer[128]
        for (int i = 0; i < UpgradeListSubcategoryCount[CurrentWeaponIDs[client][slot]]; ++i)
        {
            Format(Buffer, sizeof(Buffer), "%s", UpgradeListSubcategoryNames[CurrentWeaponIDs[client][slot]][i])
            AddMenuItem(UpgradeMenu, "subcategory", Buffer);
        }
    }
    
    DisplayMenuAtItem(UpgradeMenu, client, 0, MENU_TIME_FOREVER);
}

void UpgradeMenuShowUpgrades(int client, int category, int menupos){
    Menu UpgradeMenu = CreateMenu(MenuHandler_UpgradeChoice);
    char MenuTitle[64];
    Format(MenuTitle, sizeof(MenuTitle), "Incremental Fortress | Press Tab | $%.0f/%.0f", CurrentPoints[client], TotalPoints);
    SetMenuTitle(UpgradeMenu, MenuTitle);
    SetMenuExitBackButton(UpgradeMenu, true);
    CurrentMenuCategory[client] = category;

    if (CurrentWeaponIDs[client][CurrentMenuSlot[client]] > 0)
    {
        char Buffer[64];
        char DisplayBuffer[64];
        char TotalDisplayBuffer[64];
        char MaximumDisplayBuffer[64];
        for (int i = 0; i < MaxAttributesPerCategory; ++i)
        {
            int Attribute = UpgradeListAttributes[CurrentWeaponIDs[client][CurrentMenuSlot[client]]][category][i];
            if(Attribute == -1)
                continue;

            float TotalCost = UpgradesArray[Attribute].Cost + UpgradesArray[Attribute].CostIncreasePerUpgrade * UpgradeTimesOnItem[client][CurrentMenuSlot[client]][GetPositionOfAttribute(client,CurrentMenuSlot[client],Attribute)];
            float Increment = UpgradesArray[Attribute].IncrementPerUpgrade;
            Format(DisplayBuffer, sizeof(DisplayBuffer), UpgradesArray[Attribute].DisplayValue, StrContains(UpgradesArray[Attribute].DisplayValue, "%%") != -1 ? Increment*100.0 : Increment);

            Format(TotalDisplayBuffer, sizeof(TotalDisplayBuffer), UpgradesArray[Attribute].DisplayValue, StrContains(UpgradesArray[Attribute].DisplayValue, "%%") != -1 ? 100.0*(GetUpgradeCurrentValue(client, CurrentMenuSlot[client], Attribute)-UpgradesArray[Attribute].InitialValue) : GetUpgradeCurrentValue(client, CurrentMenuSlot[client], Attribute)-UpgradesArray[Attribute].InitialValue);
            
            Format(MaximumDisplayBuffer, sizeof(MaximumDisplayBuffer), UpgradesArray[Attribute].DisplayValue, StrContains(UpgradesArray[Attribute].DisplayValue, "%%") != -1 ? (UpgradesArray[Attribute].MaximumValue-UpgradesArray[Attribute].InitialValue)*100.0 : UpgradesArray[Attribute].MaximumValue-UpgradesArray[Attribute].InitialValue);

            Format(Buffer, sizeof(Buffer), "%s | $%.0f\n\t%s%s\t[%s%s/%s]", UpgradesArray[Attribute].DisplayName[0] ? UpgradesArray[Attribute].DisplayName : UpgradesArray[Attribute].Name, TotalCost, Increment > 0 ? "+" : "", DisplayBuffer, Increment > 0 ? "+" : "", TotalDisplayBuffer, MaximumDisplayBuffer);
            AddMenuItem(UpgradeMenu, "upgrade", Buffer);
        }
    }
    
    DisplayMenuAtItem(UpgradeMenu, client, menupos, MENU_TIME_FOREVER);
}