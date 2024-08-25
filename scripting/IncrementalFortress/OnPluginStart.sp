public void OnPluginStart(){
    LoadConfigurationFiles();

    LoadGameData();

    CanteenCooldownHUD = CreateHudSynchronizer();
    
    HookEvent("post_inventory_application", Event_InventoryRefresh);

    CreateTimer(0.1, Timer_100MS, _, TIMER_REPEAT);

    for(int client = 1;client<=MaxClients;++client){
        if(IsClientConnected(client))
            OnClientPutInServer(client);
    }

    PrintToServer("IF | Incremental Fortress finished loading!");
}