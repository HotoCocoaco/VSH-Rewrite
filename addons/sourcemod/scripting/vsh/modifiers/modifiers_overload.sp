methodmap CModifiersOverload < SaxtonHaleBase
{
	public CModifiersOverload(CModifiersOverload boss)
	{
		//Basically 165% required for super rage
		boss.iMaxRageDamage = RoundToNearest(float(boss.iMaxRageDamage) * 1.65);
		boss.flMaxRagePercentage = 1.0;	//Hard set 100% cap
	}
	
	public void GetModifiersName(char[] sName, int length)
	{
		strcopy(sName, length, "超载");
	}
	
	public void GetModifiersInfo(char[] sInfo, int length)
	{
		StrCat(sInfo, length, "\n颜色: 橙色");
		StrCat(sInfo, length, "\n ");
		StrCat(sInfo, length, "\n- 普通的愤怒变成超级愤怒");
		StrCat(sInfo, length, "\n- 获得愤怒减少 65%%");
		StrCat(sInfo, length, "\n- 愤怒百分比不能超过100%%");
	}
	
	public int GetRenderColor(int iColor[4])
	{
		iColor[0] = 255;
		iColor[1] = 144;
		iColor[2] = 0;
		iColor[3] = 255;
	}
};