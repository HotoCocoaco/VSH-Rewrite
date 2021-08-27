/*
 * Pyromancer Duo Boss: Red Pyromancer
 * By: ScrewdriverHyena
**/

static const float RAGE_DURATION = 8.0;

methodmap CScorchedPyromancer < SaxtonHaleBase
{
	public CScorchedPyromancer(CScorchedPyromancer boss)
	{
		boss.CallFunction("CreateAbility", "CBraveJump");
		CRageAddCond addCond = boss.CallFunction("CreateAbility", "CRageAddCond");
		addCond.flRageCondDuration = RAGE_DURATION;
		addCond.AddCond(TFCond_Buffed);
		
		boss.iBaseHealth = 500;
		boss.iHealthPerPlayer = 750;
		boss.nClass = TFClass_Pyro;
		boss.iMaxRageDamage = 1700;
	}
	
	public void GetBossMultiType(char[] sType, int length)
	{
		strcopy(sType, length, "CPyromancers");
	}
	
	public bool IsBossHidden()
	{
		return true;
	}
	
	public void GetBossName(char[] sName, int length)
	{
		strcopy(sName, length, "烧焦火焰兵");
	}
	
	public void GetBossInfo(char[] sInfo, int length)
	{
		StrCat(sInfo, length, "\n双人Boss: 纵火者");
		StrCat(sInfo, length, "\n近战造成80伤害");
		StrCat(sInfo, length, "\n生命值: 低");
		StrCat(sInfo, length, "\n ");
		StrCat(sInfo, length, "\n能力");
		StrCat(sInfo, length, "\n- 增强跳");
		StrCat(sInfo, length, "\n ");
		StrCat(sInfo, length, "\n愤怒");
		StrCat(sInfo, length, "\n- 点燃500单位内的所有玩家");
		StrCat(sInfo, length, "\n- 200%% 愤怒: 点燃地图的所有玩家");
	}
	
	public void OnSpawn()
	{
		const int TF_WEAPON_SHARPENED_VOLCANO_FRAGMENT = 348;
		int iWeapon = this.CallFunction("CreateWeapon", TF_WEAPON_SHARPENED_VOLCANO_FRAGMENT, "tf_weapon_fireaxe", 100, TFQual_Collectors, "2 ; 1.54 ; 208 ; 1.0 ; 252 ; 0.5");
		if (iWeapon > MaxClients)
			SetEntPropEnt(this.iClient, Prop_Send, "m_hActiveWeapon", iWeapon);
		/*
		Fragment attributes:
		
		2: damage bonus
		208: ignite target on hit
		252: reduction in push force taken from damage
		*/
	}
	
	public void OnRage()
	{
		const float RAGE_RADIUS = 750.0;
		
		int iClient = this.iClient;
		int bossTeam = GetClientTeam(iClient);
		float vecPos[3];
		GetClientAbsOrigin(iClient, vecPos);
		
		for (int iVictim = 1; iVictim <= MaxClients; iVictim++)
		{
			if (IsClientInGame(iVictim) && IsPlayerAlive(iVictim) && GetClientTeam(iVictim) != bossTeam && !TF2_IsUbercharged(iVictim))
			{
				if (this.bSuperRage || IsClientInRange(iVictim, vecPos, RAGE_RADIUS))
					TF2_IgnitePlayer(iVictim, iClient, 8.0);
			}
		}
	}
	
	public void OnThink()
	{
		Hud_AddText(this.iClient, "提示: 靠近另一个纵火者以便让它爆击被点燃的敌人！");
	}
}