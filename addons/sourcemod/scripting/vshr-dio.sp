#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2>
#include <tf2_stocks>
#include <saxtonhale>

public Plugin myinfo=
{
	name="VSH Rewrite: Dio Brando",
	author="Cocoa",
	description="Add dio to VSH-R",
	version="0.1",
};
//Timestop的定义
static int g_iTimeStopCharge[MAXPLAYERS + 1];
static int g_iTimeStopMaxCharge[MAXPLAYERS + 1];
static int g_iTimeStopChargeBuild[MAXPLAYERS + 1];
//static float g_flBraveJumpMaxHeight[TF_MAXPLAYERS];
//static float g_flBraveJumpMaxDistance[TF_MAXPLAYERS];
static float g_flTimeStopCooldown[MAXPLAYERS + 1];
static float g_flTimeStopCooldownWait[MAXPLAYERS + 1];
//static float g_flBraveJumpEyeAngleRequirement[TF_MAXPLAYERS];
static bool g_bTimeStopHoldingChargeButton[MAXPLAYERS + 1];
//static bool g_bTimeStopOnGoing = false;
#define MAXENTITIES 2048
static int g_nEntityMovetype[MAXENTITIES+1];
static float g_flTimeStop = -1.0;
static float g_flTimeStopCooling = -1.0;
static int g_hTimeStopParent;
static float g_flTimeStopDamage[MAXPLAYERS + 1];
static float g_flTimeStopArg[MAXPLAYERS + 1];
static float g_flTimeStopCoolingArg[MAXPLAYERS + 1];

//定义boss的资源
#define DIO_MODEL "models/freak_fortress_2/newdio/newdio.mdl"
#define DIO_THEME "freak_fortress_2/dio2/bgm3.mp3"
#define DIO_TIMESTOPWARN "freak_fortress_2/dio2/rage.mp3"
#define DIO_TIMESTOPBELL "ambient/alarms/warningbell1.wav"


static char g_strDioRoundStart[][] = {
	"freak_fortress_2/dio2/intro.mp3"
};

static char g_strDioWin[][] = {
	"freak_fortress_2/dio2/win.mp3"
	"freak_fortress_2/dio2/win2.mp3"
	"freak_fortress_2/dio2/win3.mp3"
};

static char g_strDioLose[][] = {
	"freak_fortress_2/dio2/lose.mp3"
	"freak_fortress_2/dio2/lose2.mp3"
	"freak_fortress_2/dio2/lose3.mp3"
};

static char g_strDioJump[][] = {
	"freak_fortress_2/dio2/jump.mp3"
};

static char g_strDioKill[][] = {
	"freak_fortress_2/dio2/hitfix.mp3"
};

static char g_strDioKillHeavy[][] = {
	"freak_fortress_2/dio2/killheavy.mp3"
};

static char g_strDioKillSpree[][] = {
	"freak_fortress_2/dio2/killingspree.mp3"
	"freak_fortress_2/dio2/killingspree2.mp3"
};

static char g_strDioRage[][] = {
	"vsh_rewrite/dio2/roadrollerrage.mp3"
};

public void OnLibraryAdded(const char[] sName)
{
	if (StrEqual(sName, "saxtonhale"))
	{
		SaxtonHale_RegisterClass("CDio", VSHClassType_Boss);
		SaxtonHale_RegisterClass("CTimeStop", VSHClassType_Ability);
		SaxtonHale_RegisterClass("CRoadRoller", VSHClassType_Ability);
	}
}

public void OnPluginEnd()
{
	SaxtonHale_UnregisterClass("CDio");
	SaxtonHale_UnregisterClass("CTimeStop");
	SaxtonHale_UnregisterClass("CRoadRoller");
}
//时间停止能力注册
methodmap CTimeStop < SaxtonHaleBase
{
	property int iMaxTimeStopCharge
	{
		public get()
		{
			return g_iTimeStopMaxCharge[this.iClient];
		}
		public set(int val)
		{
			g_iTimeStopMaxCharge[this.iClient] = val;
		}
	}

	property int iTimeStopCharge
	{
		public get()
		{
			return g_iTimeStopCharge[this.iClient];
		}
		public set(int val)
		{
			g_iTimeStopCharge[this.iClient] = val;
			if (g_iTimeStopCharge[this.iClient] > this.iMaxTimeStopCharge) g_iTimeStopCharge[this.iClient] = this.iMaxTimeStopCharge;
			if (g_iTimeStopCharge[this.iClient] < 0) g_iTimeStopCharge[this.iClient] = 0;
		}
	}

	property int iTimeStopChargeBuild
	{
		public get()
		{
			return g_iTimeStopChargeBuild[this.iClient];
		}
		public set(int val)
		{
			g_iTimeStopChargeBuild[this.iClient] = val;
		}
	}

	property float flCooldown
	{
		public get()
		{
			return g_flTimeStopCooldown[this.iClient];
		}
		public set(float val)
		{
			g_flTimeStopCooldown[this.iClient] = val;
		}
	}

	property float flTimeStopArg
	{
		public get()
		{
			return g_flTimeStopArg[this.iClient];
		}
		public set(float val)
		{
			g_flTimeStopArg[this.iClient] = val;
		}
	}

	property float flTimeStopCoolingArg
	{
		public get()
		{
			return g_flTimeStopCoolingArg[this.iClient];
		}
		public set(float val)
		{
			g_flTimeStopCoolingArg[this.iClient] = val;
		}
	}

	public CTimeStop(CTimeStop ability)
	{
		g_iTimeStopCharge[ability.iClient] = 0;
		g_flTimeStopCooldownWait[ability.iClient] = 0.0;

		//Default values, these can be changed if needed
		ability.iMaxTimeStopCharge = 200;
		ability.iTimeStopChargeBuild = 4;
		ability.flCooldown = 30.0;
		ability.flTimeStopArg = 9.0;
		ability.flTimeStopCoolingArg = 5.0;
	}

	public void OnThink()
	{
		if (GameRules_GetRoundState() == RoundState_Preround) return;

		if (g_flTimeStopCooldownWait[this.iClient] == 0.0)	//Round started, start cooldown
			g_flTimeStopCooldownWait[this.iClient] = GetGameTime()+this.flCooldown;

		char sMessage[255];
		if (this.iJumpCharge > 0)
			Format(sMessage, sizeof(sMessage), "时停充能: %0.2f%%. 充能完释放右键", (float(this.iTimeStopCharge)/float(this.iMaxTimeStopCharge))*100.0);
		else
			Format(sMessage, sizeof(sMessage), "按住右键来给时停充能！");

		if (g_flTimeStopCooldownWait[this.iClient] != 0.0 && g_flTimeStopCooldownWait[this.iClient] > GetGameTime())
		{
			float flRemainingTime = g_flTimeStopCooldownWait[this.iClient]-GetGameTime();
			int iSec = RoundToNearest(flRemainingTime);
			Format(sMessage, sizeof(sMessage), "时停冷却 %i 秒%s 剩余！", iSec, (iSec > 1) ? "s" : "");
			Hud_AddText(this.iClient, sMessage);
			return;
		}

		Hud_AddText(this.iClient, sMessage);

		if (g_bTimeStopHoldingChargeButton[this.iClient])
			this.iTimeStopCharge += this.iTimeStopChargeBuild;
		else
			this.iTimeStopCharge -= this.iTimeStopChargeBuild*2;

		//开始制作时间停止的部分，当TimeStopOnGoing时冻结全部人。
		if(g_bTimeStopOnGoing)
		{
			for(int n=1; n <= MaxClients; n++)
			{
				if(!IsClientInGame(n) && !SaxtonHale_IsValidBoss(n, false))	continue;
				//冻结
			}
		}
	}

	public void OnSpawn()
	{
		HookEvent("player_spawn", OnPlayerSpawn);
	}

	public void OnDeath()
	{
		UnHookEvent("player_spawn", OnPlayerSpawn);
	}

	public void OnButtonRelease(int button)
	{
		if (button == IN_ATTACK2)
		{
			g_bTimeStopHoldingChargeButton[this.iClient] = false;
			if (g_flTimeStopCooldownWait[this.iClient] != 0.0 && g_flTimeStopCooldownWait[this.iClient] > GetGameTime()) return;

			if (this.iJumpCharge > 1)
			{
				//释放按钮，开始void时停
				Rage_TimeStop(this.iClient);

				float flCooldownTime = (this.flCooldown*(float(this.iTimeStopCharge)/float(this.iMaxTimeStopCharge)));
				if (flCooldownTime < 5.5) flCooldownTime = 5.5;
				g_flTimeStopCooldownWait[this.iClient] = GetGameTime()+flCooldownTime;

				this.iTimeStopCharge = 0;


				char sSound[PLATFORM_MAX_PATH];
				this.CallFunction("GetSoundAbility", sSound, sizeof(sSound), "CTimeStop");
				if (!StrEmpty(sSound))
					EmitSoundToAll(sSound, this.iClient, SNDCHAN_VOICE, SNDLEVEL_SCREAMING);
			}
		}
	}

	void Rage_TimeStop(int boss)
	{
		if(g_flTimeStopCooling <= 0.0)
		{
			for(int client = 1; client <= MaxClients; client++)
			{
				g_flTimeStopDamage[client] = 0.0;
			}
		}
			g_flTimeStopCooling = GetGameTime() + this.flTimeStopCoolingArg
			g_flTimeStop = GetGameTime() + this.flTimeStopArg

		SDKHook(boss, SDKHook_PreThinkPost, RageTimer);
		SDKUnhook(boss, SDKHook_OnTakeDamage, OnTakeDamage);
		SDKHook(boss, SDKHook_OnTakeDamage, OnTakeDamage);

		EmitSoundToAll(DIO_TIMESTOPBELL);
	}

	public void Precache()
	{
		PrepareSound(DIO_TIMESTOPBELL);
	}
}

public void RageTimer(int client)
{
	if(GameRules_GetRoundState() != RoundState_RoundRunning)
	{
		if(g_flTimeStopCooling != -1.0)
		{
			g_flTimeStopCooling = -1.0;
		}
		else if(g_flTimeStop != -1.0)
		{
			g_flTimeStop = -1.0;
			DisableTimeStop();
		}

		SDKUnhook(client, SDKHook_PreThinkPost, RageTimer);
	}

	int glowIndex;
	for(int target = 1; target <= MaxClients; target++)
	{
		if(!IsClientInGame(target) || !IsPlayerAlive(target)) continue;

		// int currentHP = GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iMaxHealth", _, target);
		int currentHP = GetEntProp(target, Prop_Send, "m_iHealth");
		int color[4] = {255, 255, 0, 255}, totalColor, temp;

		float ratio = g_flTimeStopDamage[target] * 100.0 / float(currentHP);
		totalColor = (temp = 510 - RoundFloat(5.1 * ratio)) > 0 ? temp : 0;
		color[0] = totalColor <= 255 ? ((temp = (totalColor - 255) * -1) > 255 ? 0 : temp) : 0;
		color[1] = totalColor < 255 ? 0 : totalColor - 255;

		if((glowIndex = TF2_HasGlow(target)) != -1 && IsValidEntity(glowIndex)) {
			TF2_SetGlowColor(glowIndex, color);
		}
	}

	if(g_flTimeStopCooling <= GetGameTime() && g_flTimeStopCooling != -1.0)
	{
		EnableTimeStop(client);
		g_flTimeStopCooling = -1.0;

	}
	else if(g_flTimeStop <= GetGameTime() && g_flTimeStop != -1.0)
	{
		g_flTimeStop = -1.0;
		DisableTimeStop();
		SDKUnhook(client, SDKHook_PreThinkPost, RageTimer);
	}
}

public Action OnTakeDamage(int client, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(IsValidClient(client) && IsValidClient(attacker))
	{
		if(TF2_IsPlayerInCondition(client, TFCond_Ubercharged))
			return Plugin_Continue;

		int boss = IsBoss(attacker);

		if(g_flTimeStop != -1.0 && client != attacker)
		{
			g_flTimeStopDamage[client]+= damage;
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}

public Action OnPlayerSpawn(Handle event, const char[] name, bool dont)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (GameRules_GetRoundState() != RoundState_RoundRunning)    return Plugin_Continue;

	if(g_flTimeStop > GetGameTime())
	{
		g_nEntityMovetype[client] = view_as<int>(GetEntityMoveType(client));
		SetEntityMoveType(client, MOVETYPE_NONE);

		TF2_AddCondition(client, TFCond_HalloweenKartNoTurn, -1.0);

		DisableAnimation(client);

		SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime() + 10000.0);

		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(IsValidEntity(weapon))
			DisableAnimation(weapon);

		SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(g_flTimeStop != -1.0 && g_flTimeStop > GetGameTime() && g_flTimeStopCooling == -1.0)
	{
		SDKHook(entity, SDKHook_SpawnPost, OnEntitySpawnOnTimeStop);
	}
}

public Action OnEntitySpawnOnTimeStop(int entity)
{
	if(IsValidEntity(entity))
	{
		g_nEntityMovetype[entity] = view_as<int>(GetEntityMoveType(entity));
		SetEntityMoveType(entity, MOVETYPE_NONE);

		DisableAnimation(entity);
	}
}

public TF2_OnConditionAdded(client, TFCond:condition)
{
	if(g_flTimeStop != -1.0 && condition == TFCond_Taunting)
	{
		TF2_RemoveCondition(client, condition);
	}
}

public Action TimeStopClient(Handle hTimer, int iUserId)
{
	int iClient = GetClientOfUserId(iUserId);
	EnableTimeStop(client);
	g_flTimeStopCooling = -1.0;
}

void EnableTimeStop(int client)
{
	g_hTimeStopParent = client;
	char classname[60];
	for(int entity=1; entity <= MAXENTITIES; entity++)
	{
		if(entity == client)
			continue;

		if(IsValidClient(entity))
		{
			SetClientOverlay(entity, "debug/yuv");
			if(IsPlayerAlive(entity))
			{
				TF2_AddCondition(entity, TFCond_HalloweenKartNoTurn, -1.0);
				DisableAnimation(entity);
				SetEntPropFloat(entity, Prop_Send, "m_flNextAttack", GetGameTime() + 10000.0);

				int weapon = GetEntPropEnt(entity, Prop_Send, "m_hActiveWeapon");
				if(IsValidEntity(weapon))
					DisableAnimation(weapon);

				SDKUnhook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
				SDKHook(entity, SDKHook_OnTakeDamage, OnTakeDamage);

				int glowIndex;
				if((glowIndex = TF2_HasGlow(entity)) == -1 || !IsValidEntity(glowIndex)) {
					glowIndex = TF2_CreateGlow(entity);
				}
			}
		}

		if(IsValidEntity(entity))
		{
			g_nEntityMovetype[entity] = view_as<int>(GetEntityMoveType(entity));
			SetEntityMoveType(entity, MOVETYPE_NONE);
			GetEntityClassname(entity, classname, sizeof(classname));

			if(!StrContains(classname, "obj_"))
			{
				if(TF2_GetObjectType(entity) == TFObject_Dispenser
				|| TF2_GetObjectType(entity) == TFObject_Teleporter
				|| TF2_GetObjectType(entity) == TFObject_Sentry)
				{
					SetEntProp(entity, Prop_Send, "m_bDisabled", 1);
					DisableAnimation(entity);
				}
			}
		}
	}
}

void DisableTimeStop()
{
	char classname[60];

	for(int entity = 1; entity <= MAXENTITIES; entity++)
	{
		if(entity == g_hTimeStopParent)
		continue;

		if(IsValidClient(entity))
		{
			if(TF2_IsPlayerInCondition(entity, TFCond_HalloweenKartNoTurn))
			{
				TF2_RemoveCondition(entity, TFCond_HalloweenKartNoTurn);
			}

			SetClientOverlay(entity, "");
			EnableAnimation(entity);

			SetEntPropFloat(entity, Prop_Send, "m_flNextAttack", GetGameTime());

			if(IsPlayerAlive(entity))
			{
				int weapon = GetEntPropEnt(entity, Prop_Send, "m_hActiveWeapon");
				if(IsValidEntity(weapon))
					EnableAnimation(weapon);

				SDKHooks_TakeDamage(entity, g_hTimeStopParent, g_hTimeStopParent, g_flTimeStopDamage[entity]);
				TF2_RemoveCondition(entity, TFCond_MarkedForDeath);

				int glowIndex = -1;
				if((glowIndex = TF2_HasGlow(entity)) != -1 && IsValidEntity(glowIndex)) {
					AcceptEntityInput(glowIndex, "Disable");
					RemoveEntity(glowIndex);
				}

				g_flTimeStopDamage[entity] = 0.0;
				SDKUnhook(entity, SDKHook_OnTakeDamage, OnTakeDamage);

				if(IsValidEntity(entity))
				{
					GetEntityClassname(entity, classname, sizeof(classname));
					SetEntityMoveType(entity, view_as<MoveType>(g_nEntityMovetype[entity]));

					if(!StrContains(classname, "obj_"))
					{
						if(TF2_GetObjectType(entity) == TFObject_Dispenser
						|| TF2_GetObjectType(entity) == TFObject_Teleporter
						|| TF2_GetObjectType(entity) == TFObject_Sentry)
						{
							SetEntProp(entity, Prop_Send, "m_bDisabled", 0);

							EnableAnimation(entity);
						}
					}
					else if(!StrContains(classname, "tf_projectile_", false) || IsValidClient(entity))
					{
						continue;
					}
					else
					{
						float tempVelo[3];
						tempVelo[2] = 0.1;
						NormalizeVector(tempVelo, tempVelo);
						TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, tempVelo);
					}
				}

				g_hTimeStopParent = -1;
			}
		}
	}
}

stock int TF2_CreateGlow(int iEnt, int colors[4] = {255, 255, 255, 255})
{
	char strName[126], strClass[64];
	GetEntityClassname(iEnt, strClass, sizeof(strClass));
	Format(strName, sizeof(strName), "%s%i", strClass, iEnt);
	DispatchKeyValue(iEnt, "targetname", strName);

	char strGlowColor[18];
	Format(strGlowColor, sizeof(strGlowColor), "%i %i %i %i", colors[0], colors[1], colors[2], colors[3]);

	int ent = CreateEntityByName("tf_glow");
	DispatchKeyValue(ent, "targetname", "RainbowGlow");
	DispatchKeyValue(ent, "target", strName);
	DispatchKeyValue(ent, "Mode", "0");
	DispatchKeyValue(ent, "GlowColor", strGlowColor);
	DispatchSpawn(ent);

	AcceptEntityInput(ent, "Enable");

	return ent;
}

stock int TF2_HasGlow(int iEnt)
{
	int index = -1;
	while ((index = FindEntityByClassname(index, "tf_glow")) != -1)
	{
		if (GetEntPropEnt(index, Prop_Send, "m_hTarget") == iEnt)
		{
			return index;
		}
	}

	return -1;
}

stock void TF2_SetGlowColor(int ent, int colors[4])
{
	SetVariantColor(colors);
	AcceptEntityInput(ent, "SetGlowColor");
}

void EnableAnimation(int entity)
{
	if(HasEntProp(entity, Prop_Send, "m_bIsPlayerSimulated"))
		SetEntProp(entity, Prop_Send, "m_bIsPlayerSimulated", 1);
	if(HasEntProp(entity, Prop_Send, "m_bAnimatedEveryTick"))
		SetEntProp(entity, Prop_Send, "m_bAnimatedEveryTick", 1);
	if(HasEntProp(entity, Prop_Send, "m_bSimulatedEveryTick"))
		SetEntProp(entity, Prop_Send, "m_bSimulatedEveryTick", 1);
	if(HasEntProp(entity, Prop_Send, "m_bClientSideAnimation"))
		SetEntProp(entity, Prop_Send, "m_bClientSideAnimation", 1);
	if(HasEntProp(entity, Prop_Send, "m_bClientSideFrameReset"))
		SetEntProp(entity, Prop_Send, "m_bClientSideFrameReset", 0);
}

void DisableAnimation(int entity)
{
	if(HasEntProp(entity, Prop_Send, "m_bIsPlayerSimulated"))
		SetEntProp(entity, Prop_Send, "m_bIsPlayerSimulated", 0);
	if(HasEntProp(entity, Prop_Send, "m_bSimulatedEveryTick"))
		SetEntProp(entity, Prop_Send, "m_bSimulatedEveryTick", 0);
	if(HasEntProp(entity, Prop_Send, "m_bAnimatedEveryTick"))
		SetEntProp(entity, Prop_Send, "m_bAnimatedEveryTick", 0);
	if(HasEntProp(entity, Prop_Send, "m_bClientSideAnimation"))
		SetEntProp(entity, Prop_Send, "m_bClientSideAnimation", 0);
	if(HasEntProp(entity, Prop_Send, "m_bClientSideFrameReset"))
		SetEntProp(entity, Prop_Send, "m_bClientSideFrameReset", 1);
}

stock bool IsBoss(int client)
{
	return SaxtonHale_IsValidBoss(client, false);
}

stock bool IsValidClient(int client)
{
  return (0 < client && client <= MaxClients && IsClientInGame(client));
}

void SetClientOverlay(int client, char[] strOverlay)
{
	int iFlags = GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT);
	SetCommandFlags("r_screenoverlay", iFlags);

	ClientCommand(client, "r_screenoverlay \"%s\"", strOverlay);
}

//Boss本体信息部分
methodmap CSaxtonHale < SaxtonHaleBase
{
	public CDio(CDio boss)
	{
		boss.CallFunction("CreateAbility", "CBraveJump");
		//boss.CallFunction("CreateAbility", "CTimeStop");
		//boss.CallFunction("CreateAbility", "CRoadRoller");
		CTimeStop timestop = boss.CallFunction("CreateAbility", "CTimeStop");
		timestop.flTimeStopArg = 9.0;
		timestop.flTimeStopCoolingArg = 5.0;

		boss.iBaseHealth = 800;
		boss.iHealthPerPlayer = 800;
		boss.nClass = TFClass_Spy;
		boss.iMaxRageDamage = 2500;
	}

	public void GetBossName(char[] sName, int length)
	{
		strcopy(sName, length, "Dio Brando");
	}

	public void GetBossInfo(char[] sInfo, int length)
	{
		StrCat(sInfo, length, "\n生命值: 中等");
		StrCat(sInfo, length, "\n ");
		StrCat(sInfo, length, "\n能力");
		StrCat(sInfo, length, "\n- 超级跳");
		StrCat(sInfo, length, "\n- 装填键使用时间停止能力");
		StrCat(sInfo, length, "\n ");
		StrCat(sInfo, length, "\n愤怒");
		StrCat(sInfo, length, "\n- 时间停止，对瞄准的位置召唤出一个压路机");
		StrCat(sInfo, length, "\n- 200%% 愤怒: 压路机的HP更高了");
	}

	public void OnSpawn()
	{
		Format(attribs, sizeof(attribs), "2 ; 4.55 ; 252 ; 0.7 ; 259 ; 1.0");
		iWeapon = this.CallFunction("CreateWeapon", 194, "tf_weapon_knife", 100, TFQual_Collectors, attribs);
		if (iWeapon > MaxClients)
			SetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon", iWeapon);
	}

	public void GetModel(char[] sModel, int length)
	{
		strcopy(sModel, length, DIO_MODEL);
	}

	public void GetSound(char[] sSound, int length, SaxtonHaleSound iSoundType)
	{
		switch (iSoundType)
		{
			case VSHSound_RoundStart: strcopy(sSound, length, g_strDioRoundStart[GetRandomInt(0,sizeof(g_strDioRoundStart)-1)]);
			case VSHSound_Win: strcopy(sSound, length, g_strDioWin[GetRandomInt(0,sizeof(g_strDioWin)-1)]);
			case VSHSound_Lose: strcopy(sSound, length, g_strDioLose[GetRandomInt(0,sizeof(g_strDioLose)-1)]);
			case VSHSound_Rage: strcopy(sSound, length, g_strDioRage[GetRandomInt(0,sizeof(g_strDioRage)-1)]);
		}
	}

	public void GetSoundAbility(char[] sSound, int length, const char[] sType)
	{
		if (strcmp(sType, "CBraveJump") == 0)
			strcopy(sSound, length, g_strDioJump[GetRandomInt(0,sizeof(g_strDioJump)-1)]);
	}

	public void GetSoundKill(char[] sSound, int length, TFClassType nClass)
	{
		strcopy(sSound, length, g_strDioKill[GetRandomInt(0,sizeof(g_strDioKill)-1)]);
			if (nClass == TFClass_Heavy)
			{
				strcopy(sSound, length, g_strDioKillHeavy[GetRandomInt(0,sizeof(g_strDioKillHeavy)-1)]);
			}
	}

	public Action OnSoundPlayed(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
	{
		if (strncmp(sample, "vo/", 3) == 0)//Block voicelines
			return Plugin_Handled;
		return Plugin_Continue;
	}

	public void Precache()
	{
		PrecacheModel(DIO_MODEL);
		PrepareSound(DIO_THEME);
		PrepareSound(DIO_TIMESTOPWARN);

		for (int i = 0; i < sizeof(g_strDioRoundStart); i++) PrecacheSound(g_strDioRoundStart[i]);
		for (int i = 0; i < sizeof(g_strDioWin); i++) PrecacheSound(g_strDioWin[i]);
		for (int i = 0; i < sizeof(g_strDioLose); i++) PrecacheSound(g_strDioLose[i]);
		for (int i = 0; i < sizeof(g_strDioJump); i++) PrecacheSound(g_strDioJump[i]);
		for (int i = 0; i < sizeof(g_strDioRage); i++) PrecacheSound(g_strDioRage[i]);
		for (int i = 0; i < sizeof(g_strDioKill); i++) PrecacheSound(g_strDioKill[i]);
		for (int i = 0; i < sizeof(g_strDioKillHeavy); i++) PrecacheSound(g_strDioKillHeavy[i]);
		for (int i = 0; i < sizeof(g_strDioKillSpree); i++) PrecacheSound(g_strDioKillSpree[i]);
	}
};
