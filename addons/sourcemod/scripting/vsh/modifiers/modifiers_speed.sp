methodmap CModifiersSpeed < SaxtonHaleBase
{
	public CModifiersSpeed(CModifiersSpeed boss)
	{
		boss.flSpeed *= 1.08;
		boss.flSpeedMult *= 3.0;
		boss.iMaxRageDamage = RoundToNearest(float(boss.iMaxRageDamage) * 1.2);
	}
	
	public void GetModifiersName(char[] sName, int length)
	{
		strcopy(sName, length, "速度");
	}
	
	public void GetModifiersInfo(char[] sInfo, int length)
	{
		StrCat(sInfo, length, "\n颜色: 绿色");
		StrCat(sInfo, length, "\n ");
		StrCat(sInfo, length, "\n- 更快的移动速度");
		StrCat(sInfo, length, "\n- 获得愤怒值减少20%%");
	}
	
	public int GetRenderColor(int iColor[4])
	{
		iColor[0] = 176;
		iColor[1] = 255;
		iColor[2] = 144;
		iColor[3] = 255;
	}
};