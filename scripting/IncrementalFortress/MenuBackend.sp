public MenuHandler_SlotChoice(Handle menu, MenuAction action, int client, int param){
    switch(action){
        case MenuAction_Select:{
            if(param == 5){
                AwardPointsToPlayers(1);
                UpgradeMenuEntryPoint(client);
            }
            else
                UpgradeMenuShowSubcategories(client, param-1);
        }
        case MenuAction_End:{
            delete menu;
        }
    }
}
public MenuHandler_SubcategoryChoice(Handle menu, MenuAction action, int client, int param){
    switch(action){
        case MenuAction_Select:{
            UpgradeMenuShowUpgrades(client, param, 0);
        }
        case MenuAction_End:{
            delete menu;
        }
        case MenuAction_Cancel:{
            if(param == MenuCancel_ExitBack)
                UpgradeMenuEntryPoint(client);
        }
    }
}
public MenuHandler_UpgradeChoice(Handle menu, MenuAction action, int client, int param){
    switch(action){
        case MenuAction_Select:{
            if (CurrentWeaponIDs[client][CurrentMenuSlot[client]] > 0)
            {
                int Attribute = UpgradeListAttributes[CurrentWeaponIDs[client][CurrentMenuSlot[client]]][CurrentMenuCategory[client]][param];
                PurchaseUpgrade(client, CurrentMenuSlot[client], Attribute, GetUpgradeRate(client));
                if(UpgradesArray[Attribute].Description[0])
                    SendItemInfo(client, UpgradesArray[Attribute].Description);
            }
            UpgradeMenuShowUpgrades(client, CurrentMenuCategory[client],param - (param % 7));
        }
        case MenuAction_End:{
            delete menu;
        }
        case MenuAction_Cancel:{
            if(param == MenuCancel_ExitBack)
                UpgradeMenuShowSubcategories(client, CurrentMenuSlot[client]);
        }
    }
}