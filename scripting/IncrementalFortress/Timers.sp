Action Timer_100MS(Handle timer){
    for(int client = 1; client <= MaxClients; ++client){
        if(!IsClientConnected(client))
            continue;
        
        if(CurrentCanteenCooldowns[client] > GetGameTime()){
            SetHudTextParams(0.01, 0.01, 0.1, 255, 255, 255, 255);
            ShowSyncHudText(client, CanteenCooldownHUD, "Canteen Cooldown: %.2fs", CurrentCanteenCooldowns[client] - GetGameTime());
        }
    }
    return Plugin_Continue;
}