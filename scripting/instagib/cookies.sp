// -------------------------------------------------------------------
void Cookies_Init()
{
	g_PrefMusic = new Cookie("instagib_music", "Whether Instagib should play round music.", CookieAccess_Public);
	g_PrefBhop = new Cookie("instagib_bhop", "Whether you have auto bhop enabled.", CookieAccess_Public);
}

void GetClientCookies(int client)
{
	char musicstr[64];
	g_PrefMusic.Get(client, musicstr, sizeof(musicstr));
	
	char bhop[64];
	g_PrefBhop.Get(client, bhop, sizeof(bhop));
	
	if (musicstr[0] == '\0') {
		g_PrefMusic.Set(client, "1");
		g_ClientPrefs[client].EnabledMusic = true;
	} else {
		g_ClientPrefs[client].EnabledMusic = view_as<bool>(StringToInt(musicstr));
	}
	
	if (bhop[0] == '\0') {
		g_PrefBhop.Set(client, "1");
		g_ClientPrefs[client].AutoBhop = true;
	} else {
		g_ClientPrefs[client].AutoBhop = view_as<bool>(StringToInt(bhop));
	}
}

// -------------------------------------------------------------------
public void OnClientCookiesCached(int client)
{
	GetClientCookies(client);
}
