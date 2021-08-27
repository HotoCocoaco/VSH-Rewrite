static char g_strPyromancerRoundStart[][] = 
{
	"vo/pyro_laughevil01.mp3",
	"vo/pyro_laughevil02.mp3",
	"vo/pyro_laughevil03.mp3",
	"vo/pyro_laughevil04.mp3"
};

static char g_strPyromancerRage[][] = 
{
	"vo/pyro_battlecry01.mp3",
	"vo/pyro_battlecry02.mp3",
};

static char g_strPyromancerKill[][] = 
{
	"vo/pyro_cheers01.mp3",
	"vo/pyro_goodjob01.mp3"
};

static char g_strPyromancerJump[][] = 
{
	"vo/pyro_jeers01.mp3",
	"vo/pyro_jeers02.mp3"
};

static char g_strPrecacheCosmetics[][] =
{
	"models/player/items/pyro/pyro_pyromancers_mask.mdl",
	"models/player/items/pyro/hwn_pyro_misc1.mdl",
	"models/player/items/pyro/sore_eyes.mdl",
	"models/workshop/player/items/pyro/hw2013_dragonbutt/hw2013_dragonbutt.mdl"
};

static int g_iCosmetics[] =
{
	316,
	550,
	387,
	30225
};

static int g_iPrecacheCosmetics[4];

methodmap CPyromancers < SaxtonHaleBase
{
	public CPyromancers(CPyromancers boss)
	{
		boss.CallFunction("CreateAbility", "CBraveJump");
	}
	
	public void GetBossMultiList(ArrayList aList)
	{
		aList.PushString("CScaldedPyromancer");
		aList.PushString("CScorchedPyromancer");
	}
	
	public bool IsBossMultiHidden()
	{
		return true;
	}
	
	public void GetBossMultiName(char[] sName, int length)
	{
		strcopy(sName, length, "纵火犯");
	}
	
	public void GetBossMultiInfo(char[] sInfo, int length)
	{
		StrCat(sInfo, length, "\n近战造成80伤害");
		StrCat(sInfo, length, "\n生命值: 低");
		StrCat(sInfo, length, "\n ");
		StrCat(sInfo, length, "\n能力");
		StrCat(sInfo, length, "\n- 增强跳");
		StrCat(sInfo, length, "\n ");
		StrCat(sInfo, length, "\n愤怒");
		StrCat(sInfo, length, "\n- 白灼获得脱油剂8秒");
		StrCat(sInfo, length, "\n- 200%% 愤怒: 白灼获得一个增强的偷袭烈焰燃烧器并能快速切换8秒");
		StrCat(sInfo, length, "\n- 烧焦能点燃500单位内的所有玩家");
		StrCat(sInfo, length, "\n- 200%% 愤怒: 烧焦点燃地图的全部玩家");
	}
	
	public void OnSpawn()
	{
		for (int i = 0; i < sizeof(g_iCosmetics); i++)
		{
			int iWearable = this.CallFunction("CreateWeapon", g_iCosmetics[i], "tf_wearable", 1, TFQual_Collectors, "");
			if (iWearable > MaxClients)
			{
				SetEntProp(iWearable, Prop_Send, "m_nModelIndexOverrides", g_iPrecacheCosmetics[i]);
				
				if (i == 0) //Pyromancer's Mask
				{
					SetEntProp(iWearable, Prop_Send, "m_nSkin", 2);
					SetEntityRenderColor(iWearable, 0, 0, 255, 200);
				}
				
				if (i == 3) //Cauterizer's Caudal Appendage
				{
					SetEntityRenderColor(iWearable, 0, 0, 255, 255);
				}
			}
		}
	}
	
	public void GetSound(char[] sSound, int length, SaxtonHaleSound iSoundType)
	{
		switch (iSoundType)
		{
			case VSHSound_RoundStart: strcopy(sSound, length, g_strPyromancerRoundStart[GetRandomInt(0,sizeof(g_strPyromancerRoundStart)-1)]);
			case VSHSound_Rage: strcopy(sSound, length, g_strPyromancerRage[GetRandomInt(0,sizeof(g_strPyromancerRage)-1)]);
			case VSHSound_Lastman: strcopy(sSound, length, g_strPyromancerRage[0]);
			case VSHSound_Win: strcopy(sSound, length, g_strPyromancerKill[0]);
			case VSHSound_Lose: strcopy(sSound, length, g_strPyromancerJump[0]);
			case VSHSound_Backstab: strcopy(sSound, length, g_strPyromancerJump[1]);
		}
	}
	
	public void GetSoundAbility(char[] sSound, int length, const char[] sType)
	{
		if (strcmp(sType, "CBraveJump") == 0)
			strcopy(sSound, length, g_strPyromancerJump[GetRandomInt(0,sizeof(g_strPyromancerJump)-1)]);
	}	
	
	public void GetSoundKill(char[] sSound, int length, TFClassType nClass)
	{
		strcopy(sSound, length, g_strPyromancerKill[GetRandomInt(0,sizeof(g_strPyromancerKill)-1)]);
	}
	
	public void Precache()
	{
		for (int i = 0; i < sizeof(g_iCosmetics); i++)
			g_iPrecacheCosmetics[i] = PrecacheModel(g_strPrecacheCosmetics[i]);
	
		for (int i = 0; i < sizeof(g_strPyromancerRoundStart); i++) PrecacheSound(g_strPyromancerRoundStart[i]);
		for (int i = 0; i < sizeof(g_strPyromancerRage); i++) PrecacheSound(g_strPyromancerRage[i]);
		for (int i = 0; i < sizeof(g_strPyromancerKill); i++) PrecacheSound(g_strPyromancerKill[i]);
		for (int i = 0; i < sizeof(g_strPyromancerJump); i++) PrecacheSound(g_strPyromancerJump[i]);
	}
}