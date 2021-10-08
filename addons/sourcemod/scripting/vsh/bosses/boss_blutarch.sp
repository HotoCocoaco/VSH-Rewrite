#define BLUTARCH_MODEL		"models/player/kirillian/boss/boss_blutarch_v2.mdl"

static char g_strBlutarchWin[][] = {
	"vo/halloween_mann_brothers/sf13_blutarch_win04.mp3",
	"vo/halloween_mann_brothers/sf13_blutarch_win11.mp3",
	"vo/halloween_mann_brothers/sf13_blutarch_winning06.mp3",
};

static char g_strBlutarchDeath[][] = {
	"vo/halloween_mann_brothers/sf13_blutarch_almost_lost01.mp3",
	"vo/halloween_mann_brothers/sf13_blutarch_almost_lost03.mp3",
	"vo/halloween_mann_brothers/sf13_blutarch_almost_lost05.mp3",
};

static char g_strBlutarchLose[][] = {
	"vo/halloween_mann_brothers/sf13_blutarch_lose01.mp3",
	"vo/halloween_mann_brothers/sf13_blutarch_lose04.mp3",
	"vo/halloween_mann_brothers/sf13_blutarch_lose07.mp3",
};

static char g_strBlutarchRage[][] = {
	"vo/halloween_mann_brothers/sf13_blutarch_spells04.mp3",
	"vo/halloween_mann_brothers/sf13_blutarch_spells05.mp3",
	"vo/halloween_mann_brothers/sf13_blutarch_midnight01.mp3",
};

static char g_strBlutarchLastMan[][] = {
	"vo/halloween_mann_brothers/sf13_blutarch_almost_won02.mp3",
	"vo/halloween_mann_brothers/sf13_blutarch_almost_won03.mp3",
	"vo/halloween_mann_brothers/sf13_blutarch_almost_won09.mp3",
};

static char g_strBlutarchBackstabbed[][] = {
	"vo/halloween_mann_brothers/sf13_blutarch_enemies01.mp3",
	"vo/halloween_mann_brothers/sf13_blutarch_enemies02.mp3",
	"vo/halloween_mann_brothers/sf13_blutarch_enemies03.mp3",
};

methodmap CBlutarch < SaxtonHaleBase
{
	public CBlutarch(CBlutarch boss)
	{
		CWeaponSpells weaponSpells = boss.CallFunction("CreateAbility", "CWeaponSpells");
		weaponSpells.AddSpells(haleSpells_Bats);
		weaponSpells.RageSpells(haleSpells_Meteor);
		weaponSpells.flRageRequirement = 0.0;
		weaponSpells.flCooldown = 15.0;
		
		boss.iHealthPerPlayer = 550;
		boss.flHealthExponential = 1.05;
		boss.nClass = TFClass_Spy;
		boss.iMaxRageDamage = 2500;
	}
	
	public void GetBossMultiType(char[] sType, int length)
	{
		strcopy(sType, length, "CMannBrothers");
	}
	
	public bool IsBossHidden()
	{
		return true;
	}
	
	public void GetBossName(char[] sName, int length)
	{
		strcopy(sName, length, "布鲁塔克");
	}
	
	public void GetBossInfo(char[] sInfo, int length)
	{
		StrCat(sInfo, length, "\n与雷德蒙德一起的双人Boss");
		StrCat(sInfo, length, "\n近战造成 124 伤害");
		StrCat(sInfo, length, "\n生命值: 低");
		StrCat(sInfo, length, "\n ");
		StrCat(sInfo, length, "\n能力");
		StrCat(sInfo, length, "\n- 辅助攻击使用具有15秒冷却的蝙蝠魔咒");
		StrCat(sInfo, length, "\n ");
		StrCat(sInfo, length, "\n愤怒");
		StrCat(sInfo, length, "\n- 召唤一个流星球魔咒");
		StrCat(sInfo, length, "\n- 200%% 愤怒: 召唤3个流星球魔咒");
	}
	
	public void GetModel(char[] sModel, int length)
	{
		strcopy(sModel, length, BLUTARCH_MODEL);
	}
	
	public void GetSound(char[] sSound, int length, SaxtonHaleSound iSoundType)
	{
		switch (iSoundType)
		{
			case VSHSound_Win: strcopy(sSound, length, g_strBlutarchWin[GetRandomInt(0,sizeof(g_strBlutarchWin)-1)]);
			case VSHSound_Lose: strcopy(sSound, length, g_strBlutarchLose[GetRandomInt(0,sizeof(g_strBlutarchLose)-1)]);
			case VSHSound_Rage: strcopy(sSound, length, g_strBlutarchRage[GetRandomInt(0,sizeof(g_strBlutarchRage)-1)]);
			case VSHSound_Lastman: strcopy(sSound, length, g_strBlutarchLastMan[GetRandomInt(0,sizeof(g_strBlutarchLastMan)-1)]);
			case VSHSound_Backstab: strcopy(sSound, length, g_strBlutarchBackstabbed[GetRandomInt(0,sizeof(g_strBlutarchBackstabbed)-1)]);
			case VSHSound_Death: strcopy(sSound, length, g_strBlutarchDeath[GetRandomInt(0,sizeof(g_strBlutarchDeath)-1)]);
		}
	}
	
	public void Precache()
	{
		PrecacheModel(BLUTARCH_MODEL);
		
		for (int i = 0; i < sizeof(g_strBlutarchWin); i++) PrecacheSound(g_strBlutarchWin[i]);
		for (int i = 0; i < sizeof(g_strBlutarchDeath); i++) PrecacheSound(g_strBlutarchDeath[i]);
		for (int i = 0; i < sizeof(g_strBlutarchLose); i++) PrecacheSound(g_strBlutarchLose[i]);
		for (int i = 0; i < sizeof(g_strBlutarchRage); i++) PrecacheSound(g_strBlutarchRage[i]);
		for (int i = 0; i < sizeof(g_strBlutarchLastMan); i++) PrecacheSound(g_strBlutarchLastMan[i]);
		for (int i = 0; i < sizeof(g_strBlutarchBackstabbed); i++) PrecacheSound(g_strBlutarchBackstabbed[i]);
		
		AddFileToDownloadsTable("models/player/kirillian/boss/boss_blutarch_v2.mdl");
		AddFileToDownloadsTable("models/player/kirillian/boss/boss_blutarch_v2.sw.vtx");
		AddFileToDownloadsTable("models/player/kirillian/boss/boss_blutarch_v2.vvd");
		AddFileToDownloadsTable("models/player/kirillian/boss/boss_blutarch_v2.dx80.vtx");
		AddFileToDownloadsTable("models/player/kirillian/boss/boss_blutarch_v2.dx90.vtx");
		AddFileToDownloadsTable("models/player/kirillian/boss/boss_blutarch_v2.phy");
	}
};