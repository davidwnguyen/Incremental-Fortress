public MenuHandler_SlotChoice(Handle menu, MenuAction action, int client, int param){
    switch(action){
        case MenuAction_Select:{
            switch(param){
                case 5:{
                    CanteenMenu(client);
                }
                case 6:{
                    AwardPointsToPlayers(1);
                    UpgradeMenuEntryPoint(client);
                }
                default:{
                    UpgradeMenuShowSubcategories(client, param-1);
                }
            }
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
                    SendUpgradeDescription(client, UpgradesArray[Attribute].Description, GetUpgradeCurrentValue(client, CurrentMenuSlot[client], Attribute));
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

public MenuHandler_CanteenMenu(Handle menu, MenuAction action, int client, int param){
    switch(action){
        case MenuAction_Select:{
            if (CurrentCanteenSlots[client][param] > -1)
            {
                OnUseCanteenID(client, CurrentCanteenSlots[client][param]);
            }
            CanteenMenu(client);
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