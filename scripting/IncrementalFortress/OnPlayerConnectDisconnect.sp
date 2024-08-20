public void OnClientPutInServer(int client){
    CurrentPoints[client] = TotalPoints;

    SDKHook(client, SDKHook_GetMaxHealth, OnGetMaxHealth);
}
public void OnClientDisconnect(int client){
    for(int i = 0;i < MaxSlots;++i){
        ResetUpgradesForSlot(client, i);
    }
}