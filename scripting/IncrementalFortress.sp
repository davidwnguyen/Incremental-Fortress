/**
*** okay gnutard
**/

#include <anymap>
#include <sourcemod>
#include <sdkhooks>
#include <tf2attributes>
#include <tf2>
#include <tf2_stocks>
#include <tf2utils>
#include <tf2items>
#include <tf_econ_data>
#include <tf_econ_dynamic>
#include <tf_ontakedamage>
#include <takehealth_proxy>
#include <vscript>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
    name		= "Incremental Fortress",
    author		= "Telia",
    description = "A very opinionated upgrade and incremental style TF2 mod",
    version		= "INDEV",
    url			= "https://github.com/kurwabomber"
};

#include "IncrementalFortress/Enums.sp"
#include "IncrementalFortress/GlobalVariables.sp"
#include "IncrementalFortress/Functions.sp"
#include "IncrementalFortress/ConfigSystem.sp"
#include "IncrementalFortress/DamageSystem.sp"
#include "IncrementalFortress/Events.sp"
#include "IncrementalFortress/OnPlayerConnectDisconnect.sp"
#include "IncrementalFortress/OnGiveNamedItem.sp"
#include "IncrementalFortress/OnPluginStart.sp"
#include "IncrementalFortress/RuntimeLoops.sp"
#include "IncrementalFortress/MenuFrontend.sp"
#include "IncrementalFortress/MenuBackend.sp"