// -------------------------------------------------------------------
void Commands_Init()
{
	RegConsoleCmd("kill", Command_BlockSuicide);
	RegConsoleCmd("explode", Command_BlockSuicide);
	RegConsoleCmd("autoteam", Command_BlockAutoTeam);
	RegConsoleCmd("instagib", Command_Settings);
	
	RegAdminCmd("forceround", Command_ForceRound, ADMFLAG_CHEATS);
	RegAdminCmd("instagibcfg", Command_ReloadConfig, ADMFLAG_CHEATS);
	RegAdminCmd("instagibedit", Command_EditMode, ADMFLAG_CHEATS);
	RegAdminCmd("instagibtime", Command_SetRoundTime, ADMFLAG_CHEATS);
	
	CreateConVar("instagib_version", INSTAGIB_VERSION, "Instagib version.", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	AddCommandListener(ForceWinListener, "mp_forcewin");
}

// -------------------------------------------------------------------
public Action Command_BlockSuicide(int client, int args)
{
	return (!g_CurrentRound.AllowKillbind) ? Plugin_Handled : Plugin_Continue;
}

public Action Command_BlockAutoTeam(int client, int args)
{
	return (g_CurrentRound.FreeForAll) ? Plugin_Handled : Plugin_Continue;
}

public Action Command_Settings(int client, int args)
{
	if (args > 0) {
		char arg1[256];
		GetCmdArg(1, arg1, sizeof(arg1));
		
		if (StrEqual(arg1, "viewmodel", false)) {
			char arg2[128];
			GetCmdArg(2, arg2, sizeof(arg2));
			
			int value = StringToInt(arg2);
			
			if (value < 0 || value > 255 || args < 2) {
				InstagibPrintToChat(true, client, "Usage: {/instagib viewmodel (0-255)}.");
			} else {
				SetClientCookie(client, g_PrefViewmodel, arg2);
				g_ClientPrefs[client].ViewmodelAlpha = value;
				
				if (IsValidEntity(g_MainWeaponEnt[client])) {
					SetEntityRenderColor(g_MainWeaponEnt[client], .a = value);
				}
				
				InstagibPrintToChat(true, client, "Weapon's transparency was set to %i.", value);
			}
			
			return Plugin_Handled;
		}
	}
	
	Menu_Main(client);
	
	return Plugin_Handled;
}

public Action Command_ForceRound(int client, int args)
{
	if (!args) {
		Menu_ForceRound(client, "Select a Round");
	} else {
		char argstr[128];
		GetCmdArgString(argstr, sizeof(argstr));
		
		bool result = InstagibForceRound(argstr, true, client);
		
		if (!result && client) {
			InstagibPrintToChat(true, client, "Round {%s} was not found!", argstr);
		} else if (!result && !client) {
			PrintToServer("Round \"%s\" was not found!", argstr);
		}
	}
	
	return Plugin_Handled;
}

public Action Command_ReloadConfig(int client, int args)
{
	LoadConfig();
	LoadMapConfig(GetMapName());
	
	Rounds_Reload();
	
	if (client) {
		InstagibPrintToChat(true, client, "Reloaded config.");
	} else {
		PrintToServer("Reloaded config.");
	}
	
	return Plugin_Handled;
}

public Action Command_EditMode(int client, int args)
{
	ToggleEditMode(client);
	return Plugin_Handled;
}

public Action Command_SetRoundTime(int client, int args)
{
	if (args) {
		char arg[64];
		GetCmdArgString(arg, sizeof(arg));
		
		int time = StringToInt(arg);
		if (time > 0) {
			g_RoundTimeLeft = time;
		}
	}
	return Plugin_Handled;
}

// Return the cheat flag to the mp_forcewin command after it's been called by the server :)
public Action ForceWinListener(int client, const char[] command, int argc)
{
	if (!client) {
		int flags = GetCommandFlags("mp_forcewin");
		SetCommandFlags("mp_forcewin", flags | FCVAR_CHEAT);
	}
	return Plugin_Continue;
}