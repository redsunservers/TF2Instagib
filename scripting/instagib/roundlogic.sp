// -------------------------------------------------------------------
void RoundLogic_Init()
{
	RefreshRequiredEnts();
	
	g_MapHasRoundSetup = (MapRoundSetupTime() > 0) ? true : false;
}

// -------------------------------------------------------------------
void ResetScore()
{
	for (int i = 1; i <= MaxClients; i++) {
		g_Killcount[i] = 0;
	}
	
	SetScore(TFTeam_Red, 0);
	SetScore(TFTeam_Blue, 0);
}

void RefreshRequiredEnts()
{
	g_PDLogicEnt = FindEntityByClassname(-1, "tf_logic_player_destruction");
	g_GamerulesEnt = FindEntityByClassname(-1, "tf_gamerules");
	
	if (g_PDLogicEnt == -1) {
		ThrowError("Couldn't find tf_logic_player_destruction");
	} else if (g_GamerulesEnt == -1) {
		g_GamerulesEnt = CreateEntityByName("tf_gamerules");
		DispatchSpawn(g_GamerulesEnt);
	}
	
	SetEntPropFloat(g_PDLogicEnt, Prop_Data, "m_flFinaleLength", 0.0); // No dumb PD round finale timer
}

int MapRoundSetupTime()
{
	int ent = FindEntityByClassname(-1, "team_round_timer");
	
	return (ent != -1) ? GetEntProp(ent, Prop_Data, "m_nSetupTimeLength") : 0;
}

void ChangeRespawnTime(TFTeam team, int time)
{
	char input[32];
	
	input = (team == TFTeam_Red) ? "SetRedTeamRespawnWaveTime" : "SetBlueTeamRespawnWaveTime";
	
	SetVariantInt(time);
	AcceptEntityInput(g_GamerulesEnt, input);
}

void SetMaxScore(int score)
{
	SetEntProp(g_PDLogicEnt, Prop_Data, "m_nMaxPoints", score);
	
	SetScore(TFTeam_Red, 0);
	SetScore(TFTeam_Blue, 0);
	
	g_MaxScore = score;
}

void AddScore(TFTeam team, int points)
{
	char input[32];
	
	input = (team == TFTeam_Red) ? "ScoreRedPoints" : "ScoreBluePoints";
	
	if (points < 0) {
		int score = InstagibGetTeamScore(team);
		
		SetScore(team, score+points);
	} else {
		while (points) {
			--points;
			SetVariantInt(1);
			AcceptEntityInput(g_PDLogicEnt, input);
		}
	}
}

void SetScore(TFTeam team, int points)
{
	char input[32];
	
	input = (team == TFTeam_Red) ? "m_nRedTargetPoints" : "m_nBlueTargetPoints";
	
	SetEntProp(g_PDLogicEnt, Prop_Send, input, points-1);
	AddScore(team, 1); // Add 1 point for the neat sound effect
}

void ForceWin(TFTeam team)
{
	/* This kills the server on koth maps
	int ent = FindEntityByClassname(-1, "game_round_win");
	
	if (ent == -1) {
		ent = CreateEntityByName("game_round_win");
		DispatchSpawn(ent);
	}
	
	SetVariantInt(view_as<int>(team));
	AcceptEntityInput(ent, "SetTeam");
	AcceptEntityInput(ent, "RoundWin");
	*/
	
	int flags = GetCommandFlags("mp_forcewin");
	SetCommandFlags("mp_forcewin", flags & ~FCVAR_CHEAT ); 
	ServerCommand("mp_forcewin %i", team);
}

public Action ForceWinListener(int client, const char[] command, int argc)
{
	if (!client) {
		int flags = GetCommandFlags("mp_forcewin");
		SetCommandFlags("mp_forcewin", flags | FCVAR_CHEAT );
	}
}

void Stalemate()
{
	ForceWin(TFTeam_Unassigned);
}