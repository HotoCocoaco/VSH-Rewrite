#define ATTRIB_FIRE_RATE	6

static int g_iBonkBoyModelHelmet;
static int g_iBonkBoyModelMask;
static int g_iBonkBoyModelShirt;
static int g_iBonkBoyModelBag;

static bool g_bBonkBoyRage[TF_MAXPLAYERS];

static char g_strBonkBoyRoundStart[][] = {
	"vo/scout_sf12_goodmagic07.mp3",
};

static char g_strBonkBoyWin[][] = {
	"vo/scout_domination14.mp3",
	"vo/scout_jeers07.mp3",
	"vo/taunts/scout_taunts13.mp3",
};

static char g_strBonkBoyLose[][] = {
	"vo/scout_painsevere01.mp3",
};

static char g_strBonkBoyRage[][] = {
	"vo/scout_apexofjump02.mp3",
	"vo/scout_cheers04.mp3",
	"vo/scout_sf12_badmagic11.mp3",
	"vo/scout_sf12_goodmagic03.mp3",
};

static char g_strBonkBoyKill[][] = {
	"vo/scout_domination03.mp3",
	"vo/scout_domination07.mp3",
	"vo/scout_dominationhvy10.mp3",
	"vo/scout_misc09.mp3",
	"vo/scout_revenge02.mp3",
	"vo/scout_revenge03.mp3",
	"vo/scout_specialcompleted01.mp3",
	"vo/scout_specialcompleted02.mp3",
	"vo/scout_specialcompleted03.mp3",
	"vo/scout_specialcompleted04.mp3",
	"vo/taunts/scout_taunts01.mp3",
	"vo/taunts/scout_taunts18.mp3",
};

static char g_strBonkBoyLastMan[][] = {
	"vo/scout_domination05.mp3",
	"vo/scout_domination06.mp3",
	"vo/scout_domination17.mp3",
	"vo/scout_cartgoingbackdefense05.mp3",
};

static char g_strBonkBoyBackStabbed[][] = {
	"vo/scout_autodejectedtie01.mp3",
	"vo/scout_autodejectedtie04.mp3",
	"vo/scout_cartgoingbackoffense02.mp3",
	
};

methodmap CBonkBoy < SaxtonHaleBase
{
	public CBonkBoy(CBonkBoy boss)
	{
		boss.CallFunction("CreateAbility", "CDashJump");
		boss.CallFunction("CreateAbility", "CWeaponBall");
		
		CRageAddCond rageCond = boss.CallFunction("CreateAbility", "CRageAddCond");
		rageCond.flRageCondDuration = 5.0;
		rageCond.AddCond(TFCond_HalloweenSpeedBoost);	//Unlimited jumps
		rageCond.AddCond(TFCond_CritHype);				//Pink weapon effect
		rageCond.AddCond(TFCond_SpeedBuffAlly);			//Speed boost effect
		
		boss.flSpeed = 400.0;
		boss.iHealthPerPlayer = 500;
		boss.flHealthExponential = 1.05;
		boss.nClass = TFClass_Scout;
		boss.iMaxRageDamage = 1500;
		
		g_bBonkBoyRage[boss.iClient] = false;
	}
	
	public void GetBossName(char[] sName, int length)
	{
		strcopy(sName, length, "原子能侦察兵");
	}
	
	public void GetBossInfo(char[] sInfo, int length)
	{
		StrCat(sInfo, length, "\n生命值: 低");
		StrCat(sInfo, length, "\n ");
		StrCat(sInfo, length, "\n能力");
		StrCat(sInfo, length, "\n- 更快的移动速度和额外跳跃高度");
		StrCat(sInfo, length, "\n- 可以冲跳");
		StrCat(sInfo, length, "\n- 睡魔可以爆击和击晕玩家");
		StrCat(sInfo, length, "\n- 快速充能球, 最高可持有3个球");
		StrCat(sInfo, length, "\n- 中距离的球击晕玩家和建筑, 远距离击中可秒杀");
		StrCat(sInfo, length, "\n ");
		StrCat(sInfo, length, "\n愤怒");
		StrCat(sInfo, length, "\n- 无限制的更高的机动跳跃");
		StrCat(sInfo, length, "\n- 更快的移动速度");
		StrCat(sInfo, length, "\n- 无限的球");
		StrCat(sInfo, length, "\n- 球棍击晕击退玩家");
		StrCat(sInfo, length, "\n- 200%% 愤怒: 延长时间从5秒到10秒");
	}
	
	public void OnSpawn()
	{
		char attribs[256];
		Format(attribs, sizeof(attribs), "2 ; 3.54 ; 252 ; 0.5 ; 259 ; 1.0 ; 38 ; 1.0 ; 278 ; 0.5 ; 437 ; 65536.0 ; 524 ; 1.2 ; 551 ; 1.0");
		int iWeapon = this.CallFunction("CreateWeapon", 44, "tf_weapon_bat_wood", 1, TFQual_Collectors, attribs);
		if (iWeapon > MaxClients)
			SetEntPropEnt(this.iClient, Prop_Send, "m_hActiveWeapon", iWeapon);
		
		/*
		Sandman attributes:
		
		2: damage bonus
		252: reduction in push force taken from damage
		259: Deals 3x falling damage to the player you land on
		
		38: Launches a ball that slows opponents
		278: increase in recharge rate
		437: 100% critical hit vs stunned players
		524: greater jump height when active
		551: special_taunt
		*/
		
		int iWearable = -1;
		
		iWearable = this.CallFunction("CreateWeapon", 106, "tf_wearable", 1, TFQual_Collectors, "");	//Bonk Helm
		if (iWearable > MaxClients)
			SetEntProp(iWearable, Prop_Send, "m_nModelIndexOverrides", g_iBonkBoyModelHelmet);
		
		iWearable = this.CallFunction("CreateWeapon", 451, "tf_wearable", 1, TFQual_Collectors, "");	//Bonk Boy
		if (iWearable > MaxClients)
			SetEntProp(iWearable, Prop_Send, "m_nModelIndexOverrides", g_iBonkBoyModelMask);
		
		iWearable = this.CallFunction("CreateWeapon", 30685, "tf_wearable", 1, TFQual_Collectors, "");	//Thrilling Tracksuit
		if (iWearable > MaxClients)
			SetEntProp(iWearable, Prop_Send, "m_nModelIndexOverrides", g_iBonkBoyModelShirt);
			
		iWearable = this.CallFunction("CreateWeapon", 30751, "tf_wearable", 1, TFQual_Collectors, "");	//Bonk Batter's Backup
		if (iWearable > MaxClients)
			SetEntProp(iWearable, Prop_Send, "m_nModelIndexOverrides", g_iBonkBoyModelBag);
	}
	
	public void OnRage()
	{
		//Just to fix TFCond_CritHype not doing anything
		SetEntPropFloat(this.iClient, Prop_Send, "m_flHypeMeter", 100.0);
		
		this.flSpeed *= 1.5;
		g_bBonkBoyRage[this.iClient] = true;
		SetEntityMoveType(this.iClient, MOVETYPE_ISOMETRIC);
		
		int iMelee = TF2_GetItemInSlot(this.iClient, WeaponSlot_Melee);
		if (iMelee > MaxClients)
		{
			TF2Attrib_SetByDefIndex(iMelee, ATTRIB_FIRE_RATE, 0.7);	//firing speed
			TF2Attrib_ClearCache(iMelee);
		}
	}
	
	public void OnThink()
	{
		if (g_bBonkBoyRage[this.iClient] && this.flRageLastTime < GetGameTime() - (this.bSuperRage ? 10.0 : 5.0))
		{
			g_bBonkBoyRage[this.iClient] = false;
			this.flSpeed /= 1.5;
			SetEntityMoveType(this.iClient, MOVETYPE_WALK);
			
			int iMelee = TF2_GetItemInSlot(this.iClient, WeaponSlot_Melee);
			if (iMelee > MaxClients)
			{
				TF2Attrib_RemoveByDefIndex(iMelee, ATTRIB_FIRE_RATE);	//firing speed
				TF2Attrib_ClearCache(iMelee);
			}
		}
	}
	
	public Action OnAttackDamage(int victim, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
	{
		if (g_bBonkBoyRage[this.iClient] && weapon > MaxClients && TF2_GetItemInSlot(this.iClient, WeaponSlot_Melee) == weapon && damagecustom == 0)
		{
			TF2_StunPlayer(victim, 5.0, _, TF_STUNFLAGS_SMALLBONK, this.iClient);
			
			float vecEye[3], vecVel[3], vecVictim[3];
			GetClientEyeAngles(this.iClient, vecEye);
			
			vecEye[0] = ((vecEye[0] + 90.0) / 3.0) - 90.0;	//Move eye angle more upward
			
			GetAngleVectors(vecEye, vecVel, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(vecVel, 500.0);
			
			GetEntPropVector(victim, Prop_Data, "m_vecVelocity", vecVictim);
			AddVectors(vecVictim, vecVel, vecVictim);
			TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, vecVictim);
		}
	}
	
	public void GetSound(char[] sSound, int length, SaxtonHaleSound iSoundType)
	{
		switch (iSoundType)
		{
			case VSHSound_RoundStart: strcopy(sSound, length, g_strBonkBoyRoundStart[GetRandomInt(0,sizeof(g_strBonkBoyRoundStart)-1)]);
			case VSHSound_Win: strcopy(sSound, length, g_strBonkBoyWin[GetRandomInt(0,sizeof(g_strBonkBoyWin)-1)]);
			case VSHSound_Lose: strcopy(sSound, length, g_strBonkBoyLose[GetRandomInt(0,sizeof(g_strBonkBoyLose)-1)]);
			case VSHSound_Rage: strcopy(sSound, length, g_strBonkBoyRage[GetRandomInt(0,sizeof(g_strBonkBoyRage)-1)]);
			case VSHSound_Lastman: strcopy(sSound, length, g_strBonkBoyLastMan[GetRandomInt(0,sizeof(g_strBonkBoyLastMan)-1)]);
			case VSHSound_Backstab: strcopy(sSound, length, g_strBonkBoyBackStabbed[GetRandomInt(0,sizeof(g_strBonkBoyBackStabbed)-1)]);
		}
	}
	
	public void GetSoundKill(char[] sSound, int length, TFClassType nClass)
	{
		strcopy(sSound, length, g_strBonkBoyKill[GetRandomInt(0,sizeof(g_strBonkBoyKill)-1)]);
	}
	
	public void Precache()
	{
		g_iBonkBoyModelHelmet = PrecacheModel("models/player/items/scout/bonk_helmet.mdl");
		g_iBonkBoyModelMask = PrecacheModel("models/workshop/player/items/scout/bonk_mask/bonk_mask.mdl");
		g_iBonkBoyModelShirt = PrecacheModel("models/workshop/player/items/scout/hwn2015_death_racer_jacket/hwn2015_death_racer_jacket.mdl");
		g_iBonkBoyModelBag = PrecacheModel("models/workshop/player/items/scout/dec15_scout_baseball_bag/dec15_scout_baseball_bag.mdl");
		
		for (int i = 0; i < sizeof(g_strBonkBoyRoundStart); i++) PrecacheSound(g_strBonkBoyRoundStart[i]);
		for (int i = 0; i < sizeof(g_strBonkBoyWin); i++) PrecacheSound(g_strBonkBoyWin[i]);
		for (int i = 0; i < sizeof(g_strBonkBoyLose); i++) PrecacheSound(g_strBonkBoyLose[i]);
		for (int i = 0; i < sizeof(g_strBonkBoyRage); i++) PrecacheSound(g_strBonkBoyRage[i]);
		for (int i = 0; i < sizeof(g_strBonkBoyKill); i++) PrecacheSound(g_strBonkBoyKill[i]);
		for (int i = 0; i < sizeof(g_strBonkBoyLastMan); i++) PrecacheSound(g_strBonkBoyLastMan[i]);
		for (int i = 0; i < sizeof(g_strBonkBoyBackStabbed); i++) PrecacheSound(g_strBonkBoyBackStabbed[i]);
	}
};