#define VAGINEER_MODEL		"models/player/saxton_hale/vagineer_v150.mdl"
#define VAGINEER_KILL_SOUND "vsh_rewrite/vagineer/vagineer_kill.mp3"

static char g_strVagineerRageMusic[][] = {
	"vsh_rewrite/vagineer/vagineer_rage_music_1.mp3",
	"vsh_rewrite/vagineer/vagineer_rage_music_2.mp3",
	"vsh_rewrite/vagineer/vagineer_rage_music_3.mp3"
};

static char g_strVagineerRoundStart[][] = {
	"vsh_rewrite/vagineer/vagineer_responce_intro_1.mp3",
	"vsh_rewrite/vagineer/vagineer_responce_intro_2.mp3"
};

static char g_strVagineerLose[][] = {
	"vsh_rewrite/vagineer/vagineer_responce_fail_1.mp3",
	"vsh_rewrite/vagineer/vagineer_responce_fail_2.mp3"
};

static char g_strVagineerRage[][] = {
	"vsh_rewrite/vagineer/vagineer_responce_rage_1.mp3",
	"vsh_rewrite/vagineer/vagineer_responce_rage_2.mp3",
	"vsh_rewrite/vagineer/vagineer_responce_rage_3.mp3",
	"vsh_rewrite/vagineer/vagineer_responce_rage_4.mp3"
};

static char g_strVagineerJump[][] = {
	"vsh_rewrite/vagineer/vagineer_responce_jump_1.mp3",
	"vsh_rewrite/vagineer/vagineer_responce_jump_2.mp3"
};

static char g_strVagineerKill[][] = {
	"vsh_rewrite/vagineer/vagineer_responce_taunt_1.mp3",
	"vsh_rewrite/vagineer/vagineer_responce_taunt_2.mp3",
	"vsh_rewrite/vagineer/vagineer_responce_taunt_3.mp3",
	"vsh_rewrite/vagineer/vagineer_responce_taunt_4.mp3",
	"vsh_rewrite/vagineer/vagineer_responce_taunt_5.mp3",
	"vsh_rewrite/vagineer/vagineer_responce_taunt_6.mp3"
};

static char g_strVagineerLastMan[][] = {
	"vsh_rewrite/vagineer/vagineer_lastman.mp3"
};

static char g_strVagineerBackStabbed[][] = {
	"vsh_rewrite/vagineer/vagineer_responce_rage_2.mp3",
	"vsh_rewrite/vagineer/vagineer_responce_rage_3.mp3"
};

methodmap CVagineer < SaxtonHaleBase
{
	public CVagineer(CVagineer boss)
	{
		boss.CallFunction("CreateAbility", "CBraveJump");
		boss.CallFunction("CreateAbility", "CWeaponSentry");
		CScareRage scareAbility = boss.CallFunction("CreateAbility", "CScareRage");
		scareAbility.flRadius = 200.0;
		
		boss.iHealthPerPlayer = 550;
		boss.flHealthExponential = 1.05;
		boss.nClass = TFClass_Engineer;
		boss.iMaxRageDamage = 2500;
	}
	
	public void GetBossName(char[] sName, int length)
	{
		strcopy(sName, length, "Vagineer");
	}
	
	public void GetBossInfo(char[] sInfo, int length)
	{
		StrCat(sInfo, length, "\n生命值: 稍低");
		StrCat(sInfo, length, "\n ");
		StrCat(sInfo, length, "\n能力");
		StrCat(sInfo, length, "\n- 超级跳");
		StrCat(sInfo, length, "\n ");
		StrCat(sInfo, length, "\n愤怒");
		StrCat(sInfo, length, "\n- 建造一个等级1步哨, 有更快的旋转和开火速度, 生命值取决于生存着的玩家数");
		StrCat(sInfo, length, "\n- 小范围惊吓玩家5秒");
		StrCat(sInfo, length, "\n- 200%% 愤怒: 2级步哨, 更大的惊吓范围并延长时间到7.5秒");
	}
	
	public void OnSpawn()
	{
		char attribs[256];
		Format(attribs, sizeof(attribs), "2 ; 2.80 ; 252 ; 0.5 ; 259 ; 1.0 ; 93 ; 0.0 ; 95 ; 0.0 ; 343 ; 0.5 ; 353 ; 1.0 ; 436 ; 1.0 ; 464 ; 10.0 ; 2043 ; 0.0");
		int iWeapon = this.CallFunction("CreateWeapon", 7, "tf_weapon_wrench", 100, TFQual_Collectors, attribs);
		if (iWeapon > MaxClients)
			SetEntPropEnt(this.iClient, Prop_Send, "m_hActiveWeapon", iWeapon);
		/*
		Wrench attributes:
		
		2: damage bonus
		252: reduction in push force taken from damage
		259: Deals 3x falling damage to the player you land on
		
		93: Construction hit speed boost decreased
		95: Slower repair speed
		343: Sentry firing speed bonus
		353: Cannot carry buildings
		436: Plasma effect
		464: Sentry build speed increased
		2043: slower upgrade rate
		*/
	}
	
	public void GetModel(char[] sModel, int length)
	{
		strcopy(sModel, length, VAGINEER_MODEL);
	}
	
	public void GetSound(char[] sSound, int length, SaxtonHaleSound iSoundType)
	{
		switch (iSoundType)
		{
			case VSHSound_RoundStart: strcopy(sSound, length, g_strVagineerRoundStart[GetRandomInt(0,sizeof(g_strVagineerRoundStart)-1)]);
			case VSHSound_Lose: strcopy(sSound, length, g_strVagineerLose[GetRandomInt(0,sizeof(g_strVagineerLose)-1)]);
			case VSHSound_Rage: strcopy(sSound, length, g_strVagineerRage[GetRandomInt(0,sizeof(g_strVagineerRage)-1)]);
			case VSHSound_Lastman: strcopy(sSound, length, g_strVagineerLastMan[GetRandomInt(0,sizeof(g_strVagineerLastMan)-1)]);
			case VSHSound_Backstab: strcopy(sSound, length, g_strVagineerBackStabbed[GetRandomInt(0,sizeof(g_strVagineerBackStabbed)-1)]);
		}
	}
	
	public void GetSoundAbility(char[] sSound, int length, const char[] sType)
	{
		if (strcmp(sType, "CBraveJump") == 0)
			strcopy(sSound, length, g_strVagineerJump[GetRandomInt(0,sizeof(g_strVagineerJump)-1)]);
	}
	
	public void GetSoundKill(char[] sSound, int length, TFClassType nClass)
	{
		strcopy(sSound, length, g_strVagineerKill[GetRandomInt(0,sizeof(g_strVagineerKill)-1)]);
	}
	
	public void OnPlayerKilled(Event event, int iVictim)
	{
		EmitSoundToAll(VAGINEER_KILL_SOUND);
	}
	
	public void GetRageMusicInfo(char[] sSound, int length, float &time)
	{
		strcopy(sSound, length, g_strVagineerRageMusic[GetRandomInt(0,sizeof(g_strVagineerRageMusic)-1)]);
		time = 19.0;
	}
	
	public Action OnSoundPlayed(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
	{
		if (strncmp(sample, "vo/", 3) == 0)//Block voicelines
			return Plugin_Handled;
		return Plugin_Continue;
	}
	
	public void Precache()
	{
		PrepareSound(VAGINEER_KILL_SOUND);
		for (int i = 0; i < sizeof(g_strVagineerRageMusic); i++) PrepareSound(g_strVagineerRageMusic[i]);
		for (int i = 0; i < sizeof(g_strVagineerRoundStart); i++) PrepareSound(g_strVagineerRoundStart[i]);
		for (int i = 0; i < sizeof(g_strVagineerLose); i++) PrepareSound(g_strVagineerLose[i]);
		for (int i = 0; i < sizeof(g_strVagineerRage); i++) PrepareSound(g_strVagineerRage[i]);
		for (int i = 0; i < sizeof(g_strVagineerJump); i++) PrepareSound(g_strVagineerJump[i]);
		for (int i = 0; i < sizeof(g_strVagineerKill); i++) PrepareSound(g_strVagineerKill[i]);
		for (int i = 0; i < sizeof(g_strVagineerLastMan); i++) PrepareSound(g_strVagineerLastMan[i]);
		for (int i = 0; i < sizeof(g_strVagineerBackStabbed); i++) PrepareSound(g_strVagineerBackStabbed[i]);
		
		AddFileToDownloadsTable("models/player/saxton_hale/vagineer_v150.mdl");
		AddFileToDownloadsTable("models/player/saxton_hale/vagineer_v150.phy");
		AddFileToDownloadsTable("models/player/saxton_hale/vagineer_v150.sw.vtx");
		AddFileToDownloadsTable("models/player/saxton_hale/vagineer_v150.vvd");
		AddFileToDownloadsTable("models/player/saxton_hale/vagineer_v150.dx80.vtx");
		AddFileToDownloadsTable("models/player/saxton_hale/vagineer_v150.dx90.vtx");
	}
};