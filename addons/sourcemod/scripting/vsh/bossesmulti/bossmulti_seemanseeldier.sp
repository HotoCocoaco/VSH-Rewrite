#define SEE_BOSSES_INTRO_SND				"vsh_rewrite/seeman/intro.mp3"

methodmap CSeeManSeeldier < SaxtonHaleBase
{
	public CSeeManSeeldier(CSeeManSeeldier bossmulti)
	{
	}
	
	public void GetBossMultiList(ArrayList aList)
	{
		aList.PushString("CSeeMan");
		aList.PushString("CSeeldier");
	}
	
	public void GetBossMultiName(char[] sName, int length)
	{
		strcopy(sName, length, "Seeman和Seeldier");
	}
	
	public void GetBossMultiInfo(char[] sInfo, int length)
	{
		StrCat(sInfo, length, "\n近战造成124伤害");
		StrCat(sInfo, length, "\n生命值: 低");
		StrCat(sInfo, length, "\n ");
		StrCat(sInfo, length, "\n能力");
		StrCat(sInfo, length, "\n- 超级跳");
		StrCat(sInfo, length, "\n ");
		StrCat(sInfo, length, "\n愤怒");
		StrCat(sInfo, length, "\n- Seeman被冻结并获得Übercharge状态3秒, 自身周围发生小爆炸");
		StrCat(sInfo, length, "\n- 200%% 愤怒: Seeman在愤怒结尾使用秒杀的核弹");
		StrCat(sInfo, length, "\n- Seeldlier召唤3个迷你Seeldlier");
		StrCat(sInfo, length, "\n- 200%% 愤怒: Seeldlier召唤6个迷你Seeldlier");
	}
	
	public void GetSound(char[] sSound, int length, SaxtonHaleSound iSoundType)
	{
		if (iSoundType == VSHSound_RoundStart)
			strcopy(sSound, length, SEE_BOSSES_INTRO_SND);
	}
	
	public void Precache()
	{
		PrepareSound(SEE_BOSSES_INTRO_SND);
	}
};
