public void OnPluginStart(){
    LoadConfigurationFiles();
    HookEvent("post_inventory_application", Event_InventoryRefresh);
    for(int client = 1;client<=MaxClients;++client){
        if(IsClientConnected(client))
            OnClientPutInServer(client);
    }
    PrintToServer("IF | Incremental Fortress finished loading!");
}