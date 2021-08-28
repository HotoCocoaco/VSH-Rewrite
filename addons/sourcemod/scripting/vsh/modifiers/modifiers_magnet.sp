#define MAGNET_RANGE	500.0
#define MAGNET_STRENGTH	8.0

methodmap CModifiersMagnet < SaxtonHaleBase
{
	public CModifiersMagnet(CModifiersMagnet boss)
	{
		boss.flSpeed *= 0.9; //370 -> 333
	}
	
	public void GetModifiersName(char[] sName, int length)
	{
		strcopy(sName, length, "磁力");
	}
	
	public void GetModifiersInfo(char[] sInfo, int length)
	{
		StrCat(sInfo, length, "\n颜色: 粉色");
		StrCat(sInfo, length, "\n ");
		StrCat(sInfo, length, "\n- 将自身和敌方玩家拉向对方");
		StrCat(sInfo, length, "\n- 10%% 移动速度减益");
	}
	
	public int GetRenderColor(int iColor[4])
	{
		iColor[0] = 255;
		iColor[1] = 128;
		iColor[2] = 255;
		iColor[3] = 255;
	}
	
	public void OnThink()
	{
		if (!IsPlayerAlive(this.iClient))
			return;
		
		float vecOrigin[3], vecPullVelocity[3];
		GetClientAbsOrigin(this.iClient, vecOrigin);
		TFTeam nTeam = TF2_GetClientTeam(this.iClient);
		int iCount;
		
		//Player interaction
		for (int iVictim = 1; iVictim <= MaxClients; iVictim++)
		{
			if (IsClientInGame(iVictim) && IsPlayerAlive(iVictim) && TF2_GetClientTeam(iVictim) != nTeam)
			{
				float vecTargetOrigin[3];
				GetClientAbsOrigin(iVictim, vecTargetOrigin);
				if (GetVectorDistance(vecOrigin, vecTargetOrigin) <= MAGNET_RANGE)
				{
					float vecTargetPullVelocity[3];
					MakeVectorFromPoints(vecOrigin, vecTargetOrigin, vecTargetPullVelocity);
					
					//We don't want players to helplessly hover slightly above ground if the boss is above them, so we don't modify their vertical velocity
					vecTargetPullVelocity[2] = 0.0;
					
					//Boss velocity
					NormalizeVector(vecTargetPullVelocity, vecTargetPullVelocity);
					AddVectors(vecPullVelocity, vecTargetPullVelocity, vecPullVelocity);
					iCount++;
					
					//Victim velocity
					NegateVector(vecTargetPullVelocity);
					ScaleVector(vecTargetPullVelocity, MAGNET_STRENGTH);
					
					//Consider their current velocity
					float vecTargetVelocity[3];
					GetEntPropVector(iVictim, Prop_Data, "m_vecVelocity", vecTargetVelocity);
					
					AddVectors(vecTargetVelocity, vecTargetPullVelocity, vecTargetVelocity);
					TeleportEntity(iVictim, NULL_VECTOR, NULL_VECTOR, vecTargetVelocity);
				}
			}
		}
		
		ScaleVector(vecPullVelocity, 1.0 / float(iCount));	//So vel won't go crazy with huge amount of players
		ScaleVector(vecPullVelocity, MAGNET_STRENGTH);
		
		//Consider boss current velocity
		float vecVelocity[3];
		GetEntPropVector(this.iClient, Prop_Data, "m_vecVelocity", vecVelocity);
		
		AddVectors(vecVelocity, vecPullVelocity, vecVelocity);
		TeleportEntity(this.iClient, NULL_VECTOR, NULL_VECTOR, vecVelocity);
	}
};