#define SEEMAN_MODEL						"models/player/kirillian/boss/seeman_fix.mdl"
#define SEEMAN_RAGE_SND						"vsh_rewrite/seeman/rage.mp3"
#define SEEMAN_SEE_SND						"vsh_rewrite/seeman/see.mp3"

methodmap CSeeMan < SaxtonHaleBase
{
	public CSeeMan(CSeeMan boss)
	{
		boss.CallFunction("CreateAbility", "CWeaponFists");
		boss.CallFunction("CreateAbility", "CBraveJump");
		CBomb bomb = boss.CallFunction("CreateAbility", "CBomb");
		bomb.flBombSpawnInterval = 0.1;
		bomb.flBombSpawnDuration = 3.0;
		bomb.flBombSpawnRadius = 500.0;
		bomb.flBombRadius = 200.0;
		bomb.flBombDamage = 75.0;
		bomb.flNukeRadius = 650.0;
		
		boss.iHealthPerPlayer = 550;
		boss.flHealthExponential = 1.05;
		boss.nClass = TFClass_DemoMan;
		boss.iMaxRageDamage = 2000;
		
		CRageAddCond rageCond = boss.CallFunction("CreateAbility", "CRageAddCond");
		rageCond.flRageCondDuration = 3.0;
		rageCond.flRageCondSuperRageMultiplier = 1.0;
		rageCond.AddCond(TFCond_UberchargedCanteen);
	}
	
	public void GetBossMultiType(char[] sType, int length)
	{
		strcopy(sType, length, "CSeeManSeeldier");
	}
	
	public bool IsBossHidden()
	{
		return true;
	}
	
	public void GetBossName(char[] sName, int length)
	{
		strcopy(sName, length, "Seeman");
	}
	
	public void GetBossInfo(char[] sInfo, int length)
	{
		StrCat(sInfo, length, "\n与Seeldier一起的双人Boss");
		StrCat(sInfo, length, "\n近战造成124伤害");
		StrCat(sInfo, length, "\n生命值: 低");
		StrCat(sInfo, length, "\n ");
		StrCat(sInfo, length, "\n能力");
		StrCat(sInfo, length, "\n- 超级跳");
		StrCat(sInfo, length, "\n ");
		StrCat(sInfo, length, "\n愤怒");
		StrCat(sInfo, length, "\n- Übercharge状态冰冻3秒");
		StrCat(sInfo, length, "\n- Boss周围许多小型爆炸");
		StrCat(sInfo, length, "\n- 200%% Rage: 在愤怒结尾使用秒杀的核弹");
	}
	
	public Action OnTakeDamage(int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
	{
		char sWeaponClassName[32];
		if (inflictor >= 0) GetEdictClassname(inflictor, sWeaponClassName, sizeof(sWeaponClassName));
		
		//Disable self-damage from bomb rage ability
		if (this.iClient == attacker && strcmp(sWeaponClassName, "tf_generic_bomb") == 0) return Plugin_Stop;

		EmitSoundToAll(SEEMAN_SEE_SND, this.iClient, SNDCHAN_VOICE, SNDLEVEL_SCREAMING);
		return Plugin_Continue;
	}
	
	public void OnSpawn()
	{
		char attribs[128];
		Format(attribs, sizeof(attribs), "2 ; 1.9 ; 252 ; 0.5 ; 259 ; 1.0");
		int iWeapon = this.CallFunction("CreateWeapon", 195, "tf_weapon_bottle", 100, TFQual_Collectors, attribs);
		if (iWeapon > MaxClients)
			SetEntPropEnt(this.iClient, Prop_Send, "m_hActiveWeapon", iWeapon);
		/*
		Fist attributes:
		
		2: damage bonus
		252: reduction in push force taken from damage
		259: Deals 3x falling damage to the player you land on
		*/
	}
	
	public void GetModel(char[] sModel, int length)
	{
		strcopy(sModel, length, SEEMAN_MODEL);
	}
	
	public void GetSound(char[] sSound, int length, SaxtonHaleSound iSoundType)
	{
		if (iSoundType != VSHSound_RoundStart)
			strcopy(sSound, length, SEEMAN_SEE_SND);
	}
	
	public void GetSoundAbility(char[] sSound, int length, const char[] sType)
	{
		if (strcmp(sType, "CBraveJump") == 0)
			strcopy(sSound, length, SEEMAN_SEE_SND);
	}
	
	public void GetSoundKill(char[] sSound, int length, TFClassType nClass)
	{
		strcopy(sSound, length, SEEMAN_SEE_SND);
	}
	
	public Action OnSoundPlayed(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
	{
		if (strncmp(sample, "vo/", 3) == 0)
		{
			return Plugin_Handled;
		}
		return Plugin_Continue;
	}
	
	public void GetRageMusicInfo(char[] sSound, int length, float &time)
	{
		strcopy(sSound, length, SEEMAN_RAGE_SND);
		time = 6.0;
	}
	
	public void Precache()
	{
		PrepareSound(SEEMAN_SEE_SND);
		PrepareSound(SEEMAN_RAGE_SND);
		PrecacheModel(SEEMAN_MODEL);
		
		AddFileToDownloadsTable("models/player/kirillian/boss/seeman_fix.mdl");
		AddFileToDownloadsTable("models/player/kirillian/boss/seeman_fix.sw.vtx");
		AddFileToDownloadsTable("models/player/kirillian/boss/seeman_fix.vvd");
		AddFileToDownloadsTable("models/player/kirillian/boss/seeman_fix.dx80.vtx");
		AddFileToDownloadsTable("models/player/kirillian/boss/seeman_fix.dx90.vtx");
		AddFileToDownloadsTable("models/player/kirillian/boss/seeman_fix.phy");
	}
};
