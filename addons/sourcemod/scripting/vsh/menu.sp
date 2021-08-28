static Menu g_hMenuError;
static Menu g_hMenuMain;
static Menu g_hMenuCredits;

void Menu_Init()
{
	char buffer[512];
	
	// Create menus.
	// TODO add translations support.
	
	// Error Menu
	g_hMenuError = new Menu(Menu_SelectError);
	g_hMenuError.SetTitle("You found an error menu - you're not supposed to be here... oops!\nYou probably want to tell an admin about this...");
	g_hMenuError.AddItem("back", "<- 主菜单");
	
	// Main Menu
	g_hMenuMain = new Menu(Menu_SelectMain);
	g_hMenuMain.SetTitle("[VSH REWRITE] - %s.%s", PLUGIN_VERSION, PLUGIN_VERSION_REVISION);
	g_hMenuMain.AddItem("class", "兵种 & 武器菜单 (!vshclass)");
	g_hMenuMain.AddItem("boss", "Boss信息 (!vshboss)");
	g_hMenuMain.AddItem("bossmulti", "多人Boss信息 (!vshmultiboss)");
	g_hMenuMain.AddItem("modifiers", "修改器信息 (!vshmodifiers)");
	g_hMenuMain.AddItem("queue", "队列列表 (!vshnext)");
	g_hMenuMain.AddItem("preference", "设置 (!vshsettings)");
	g_hMenuMain.AddItem("credit", "鸣谢 (!vshcredits)");
	
	// Credits
	g_hMenuCredits = new Menu(Menu_SelectCredits);
	Format(buffer, sizeof(buffer), "鸣谢");
	Format(buffer, sizeof(buffer), "%s \n", buffer);
	Format(buffer, sizeof(buffer), "%s \n代码贡献者: 42", buffer);
	Format(buffer, sizeof(buffer), "%s \n原始代码贡献者: Kenzzer", buffer);
	Format(buffer, sizeof(buffer), "%s \n", buffer);
	Format(buffer, sizeof(buffer), "%s \nEggman - The creator of the first VSH", buffer);
	Format(buffer, sizeof(buffer), "%s \nKirillian - Several boss model addition", buffer);
	Format(buffer, sizeof(buffer), "%s \nSediSocks - Announcer model", buffer);
	Format(buffer, sizeof(buffer), "%s \nAlex Turtle & Chillax - Original Rewrite test subjects", buffer);
	Format(buffer, sizeof(buffer), "%s \nwo - Test subject", buffer);
	Format(buffer, sizeof(buffer), "%s \nRedSun - Host community!", buffer);
	Format(buffer, sizeof(buffer), "%s \n热可可 - 汉化此插件!", buffer);
	g_hMenuCredits.SetTitle(buffer);
	g_hMenuCredits.AddItem("back", "<- 返回");
	
	MenuAdmin_Init();
	MenuBoss_Init();
}

void Menu_DisplayError(int iClient)
{
	g_hMenuError.Display(iClient, MENU_TIME_FOREVER);
	ThrowError("[VSH] Entered error menu!");
}

public int Menu_SelectError(Menu hMenu, MenuAction action, int iClient, int iSelect)
{
	if (action != MenuAction_Select) return;
	
	Menu_DisplayMain(iClient);
}

void Menu_DisplayMain(int iClient)
{
	g_hMenuMain.Display(iClient, MENU_TIME_FOREVER);
}

public int Menu_SelectMain(Menu hMenu, MenuAction action, int iClient, int iSelect)
{
	if (action != MenuAction_Select) return;
	
	char sSelect[32];
	hMenu.GetItem(iSelect, sSelect, sizeof(sSelect));
	
	if (StrEqual(sSelect, "class"))
		MenuWeapon_DisplayMain(iClient);
	else if (StrEqual(sSelect, "boss"))
		MenuBoss_DisplayList(iClient, VSHClassType_Boss, MenuBoss_CallbackInfo);
	else if (StrEqual(sSelect, "bossmulti"))
		MenuBoss_DisplayList(iClient, VSHClassType_BossMulti, MenuBoss_CallbackInfo);
	else if (StrEqual(sSelect, "modifiers"))
		MenuBoss_DisplayList(iClient, VSHClassType_Modifier, MenuBoss_CallbackInfo);
	else if (StrEqual(sSelect, "queue"))
		Menu_DisplayQueue(iClient);
	else if (StrEqual(sSelect, "preference"))
		Menu_DisplayPreferences(iClient);
	else if (StrEqual(sSelect, "credit"))
		Menu_DisplayCredits(iClient);
	else
		Menu_DisplayError(iClient);
}

void Menu_DisplayQueue(int iClient)
{
	Menu hMenuQueue = new Menu(Menu_SelectQueue);
	
	char buffer[512];
	Format(buffer, sizeof(buffer), "队列列表:");

	for (int i = 1; i <= 8; i++)
	{
		int iPlayer = Queue_GetPlayerFromRank(i);

		if (0 < iPlayer <= MaxClients)
			Format(buffer, sizeof(buffer), "%s\n%i) - %N (%i)", buffer, i, iPlayer, Queue_PlayerGetPoints(iPlayer));
		else
			Format(buffer, sizeof(buffer), "%s\n%i) - ", buffer, i);
	}
	
	int iPoints = Queue_PlayerGetPoints(iClient);
	if (iPoints >= 0)
		Format(buffer, sizeof(buffer), "%s\n你的队列点数: %i", buffer, iPoints);
	else
		Format(buffer, sizeof(buffer), "%s\n你的队列点数还在加载，稍后再试", buffer, iPoints);
	
	hMenuQueue.SetTitle(buffer);
	hMenuQueue.AddItem("back", "<- 返回");
	hMenuQueue.Display(iClient, MENU_TIME_FOREVER);
}

public int Menu_SelectQueue(Menu hMenu, MenuAction action, int iClient, int iSelect)
{
	if (action == MenuAction_End)
	{
		delete hMenu;
		return;
	}
	
	if (action != MenuAction_Select) return;

	Menu_DisplayMain(iClient);
}

void Menu_DisplayPreferences(int iClient)
{
	//Create new menu, and display whenever if it enabled or not
	Menu hMenuPreferences = new Menu(Menu_SelectPreferences);
	hMenuPreferences.SetTitle("开关偏好");
	
	for (SaxtonHalePreferences nPreferences; nPreferences < view_as<SaxtonHalePreferences>(sizeof(g_strPreferencesName)); nPreferences++)
	{
		if (StrEmpty(g_strPreferencesName[nPreferences]))
			continue;
		
		char buffer[512];
		if (Preferences_Get(iClient, nPreferences))
			Format(buffer, sizeof(buffer), "%s (已开启)", g_strPreferencesName[nPreferences]);
		else
			Format(buffer, sizeof(buffer), "%s (已关闭)", g_strPreferencesName[nPreferences]);
		
		hMenuPreferences.AddItem(g_strPreferencesName[nPreferences], buffer);
	}
	
	hMenuPreferences.AddItem("back", "<- 返回");
	hMenuPreferences.Display(iClient, MENU_TIME_FOREVER);
}

public int Menu_SelectPreferences(Menu hMenu, MenuAction action, int iClient, int iSelect)
{
	if (action == MenuAction_End)
	{
		delete hMenu;
		return;
	}
	
	if (action != MenuAction_Select) return;
	
	char sSelect[32];
	hMenu.GetItem(iSelect, sSelect, sizeof(sSelect));
	
	//Find preferences thats selected
	for (SaxtonHalePreferences nPreferences; nPreferences < view_as<SaxtonHalePreferences>(sizeof(g_strPreferencesName)); nPreferences++)
	{
		if (StrEqual(sSelect, g_strPreferencesName[nPreferences]))
		{
			ClientCommand(iClient, "vsh_preferences %s", g_strPreferencesName[nPreferences]);
			return;
		}
	}
	
	if (StrEqual(sSelect, "back"))
		Menu_DisplayMain(iClient);
	else
		Menu_DisplayError(iClient);
}

void Menu_DisplayCredits(int iClient)
{
	g_hMenuCredits.Display(iClient, MENU_TIME_FOREVER);
}

public int Menu_SelectCredits(Menu hMenu, MenuAction action, int iClient, int iSelect)
{
	if (action != MenuAction_Select) return;

	Menu_DisplayMain(iClient);
}