public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2]){
    if(buttons & IN_SCORE && NextMenuServing[client] <= GetGameTime()){
        UpgradeMenuEntryPoint(client);
        NextMenuServing[client] = GetGameTime() + 0.5;
    }
    CurrentButtons[client] = buttons;

    return Plugin_Continue;
}