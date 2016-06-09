state("Undertale", "1.0")
{
	double naming : "Undertale.exe", 0x50F33C, 0x80, 0xC8, 0x20, 8;
	uint pFlag : "Undertale.exe", 0x2EBD78, 0x38, 0x3C, 4;
	double charaCon : "Undertale.exe", 0x50F33C, 0x80, 0xC8, 0x3C, 8;
	double exp : "Undertale.exe", 0x2EBD78, 0x20, 0x58;
	double plot : "Undertale.exe", 0x2EBD78, 0x14, 4, 8;
	uint room : "Undertale.exe", 0x50F300;
	double fivedamage : "Undertale.exe", 0x2EBD78, 0xC8, 8;
	double msc : "Undertale.exe", 0x2EBD78, 0xF8, 8;
	double igt : "Undertale.exe", 0x30CF34, 0, 0x100, 4, 4, 4, 0xC, 0xB8, 8, 0xC8, 0x38, 8;
}

state("Undertale", "1.1")
{
	uint naming : "Undertale.exe", 0x34D638, 0x574, 4, 0x3FC, 0x520;
	uint pFlag : "Undertale.exe", 0x34D638, 0x248, 0, 4, 4;
	double exp : "Undertale.exe", 0x34D638, 0x188, 0x100;
	double plot : "Undertale.exe", 0x34D638, 0x188, 0x70;
	uint room : "Undertale.exe", 0x59C270;
	double fivedamage : "Undertale.exe", 0x34D638, 0x578, 0x1E0;
	double msc : "Undertale.exe", 0x34D638, 0x1B8, 0x310;
}

startup
{
	refreshRate = 30;
	
	settings.Add("6", false, "Genocide Ending");
	settings.SetToolTip("6", "End split currently does not work in 1.1");
	settings.Add("12", true, "Neutral Ending");
	settings.Add("23", false, "True Pacifist Ending");
	
	settings.CurrentDefaultParent = "6";
	settings.Add("0", true, "Toriel");
	settings.Add("1", true, "Papyrus");
	settings.Add("2", true, "Undyne");
	settings.Add("3", false, "Muffet");
	settings.Add("4", true, "Mettaton");
	settings.Add("5", true, "sans");

	settings.CurrentDefaultParent = "12";
	settings.Add("7", false, "Napstablook");
	settings.Add("8", true, "Toriel");
	settings.Add("9", true, "Papyrus");
	settings.Add("A", false, "Mad Dummy");
	settings.Add("B", true, "Undyne");
	settings.Add("C", false, "Jetpack skip");
	settings.Add("D", false, "Bomb skip");
	settings.Add("E", false, "Muffet");
	settings.Add("F", false, "Play skip");
	settings.Add("10", true, "Mettaton");
	settings.Add("11", true, "Asgore");

	settings.CurrentDefaultParent = "23";
	settings.Add("13", false, "Napstablook");
	settings.Add("14", true, "Toriel");
	settings.Add("15", true, "Papyrus");
	settings.Add("16", true, "Papyrus Date");
	settings.Add("17", false, "Mad Dummy");
	settings.Add("18", true, "Undyne");
	settings.Add("19", false, "Jetpack skip");
	settings.Add("1A", false, "Bomb skip");
	settings.Add("1B", false, "Muffet");
	settings.Add("1C", false, "Play skip");
	settings.Add("1D", true, "Mettaton");
	settings.Add("1E", true, "Asgore");
	settings.Add("1F", true, "Flowey");
	settings.Add("20", true, "Undyne Date");
	settings.Add("21", true, "Alphys Date");
	settings.Add("22", true, "True Lab");
}

init
{
	timer.OnStart += (s, e) =>
	{
		vars.charaCon = null;
		
		vars.splits = new Queue<byte>();
		
		for (byte i = 0x00; i < 0x24; ++i)
			if (settings[i.ToString("X")])
				vars.splits.Enqueue(i);
				
		vars.splits.Enqueue(0xFF);
	};
	
	vars.GetFlag = (Func<uint, double>)((n) =>
	{
		return memory.ReadValue<double>(new IntPtr(current.pFlag + n * 0x10));
	});
	
	switch (modules.First().ModuleMemorySize)
	{
		case 0x567000:
			version = "1.0";
			break;
		case 0x5ED000:
			version = "1.1";
			break;
		default:
			print("Could not detect version.");
			break;
	}
}

start
{
	return old.naming == 2 && (current.naming == 0 || current.naming == 4);
}

split
{
	switch ((byte)vars.splits.Peek())
	{
		case 0x00:	// Kill Toriel
			if (vars.GetFlag(45) == 4) { goto nextSplit; }
			break;
		case 0x01:	// Kill Papyrus
			if (vars.GetFlag(67) == 1) { goto nextSplit; }
			break;
		case 0x02:	// Undying
			if (vars.GetFlag(251) == 1) { goto nextSplit; }
			break;
		case 0x03:	// Kill Muffet
			if (vars.GetFlag(397) == 1) { goto nextSplit; }
			break;
		case 0x04:	// Mettaton Neo
			if (vars.GetFlag(425) == 1) { goto nextSplit; }
			break;
		case 0x05:	// sans
			if (current.exp == 99999) { goto nextSplit; }
			break;
		case 0x06:	// Genocide ending
			if (version == "1.0")
				if (current.charaCon == 19 || current.charaCon == 29)
					goto nextSplit;
			// todo: find a decent way to get obj_truechara.con in 1.1
			break;
		case 0x07:
		case 0x13:	// Napstablook
			if (current.plot == 10.4d) { goto nextSplit; }
			break;
		case 0x08:
		case 0x14:	// Pacifist Toriel
			if (vars.GetFlag(45) == 5)
			{
				if (current.room == 41)
						goto nextSplit;
			}
			break;
		case 0x09:
		case 0x15:	// Pacifist Papyrus
			if (old.msc == 544 && current.msc != 544) { goto nextSplit; }
			if (current.plot == 100) { goto nextSplit; }
			break;
		case 0x16:	// Papyrus date
			if (vars.GetFlag(88) == 4) { goto nextSplit; }
			break;
		case 0x0A:
		case 0x17:	// Mad Dummy
			if (current.plot == 116) { goto nextSplit; }
			break;
		case 0x0B:
		case 0x18:	// Pacifist Undyne
			if (current.room == 139) { goto nextSplit; }
			break;
		case 0x0C:
		case 0x19:	// Jetpack skip
			if (current.room == 155) { goto nextSplit; }
			break;
		case 0x0D:
		case 0x1A:	// Bomb skip
			if (current.room == 167) { goto nextSplit; }
			break;
		case 0x0E:
		case 0x1B:	// Muffet skip
			if (current.room == 178) { goto nextSplit; }
			break;
		case 0x0F:
		case 0x1C:	// Play skip
			if (current.room == 181) { goto nextSplit; }
			break;
		case 0x10:
		case 0x1D:	// Mettaton skip
			if (current.room == 212) { goto nextSplit; }
			break;
		case 0x11:
		case 0x1E:	// Asgore
			if (current.fivedamage >= 1) { goto nextSplit; }
			break;
		case 0x12:
		case 0x1F:	// Neutral ending
			if (old.plot > 30 && current.plot == 30) { goto nextSplit; }
			break;
		case 0x20:	// Undyne date
			if (vars.GetFlag(389) == 4) { goto nextSplit; }
			break;
		case 0x21:	// Alphys date
			if (vars.GetFlag(493) == 10) { goto nextSplit; }
			break;
		case 0x22:	// True Lab
			if (vars.GetFlag(493) == 12) { goto nextSplit; }
			break;
		case 0x23:	// True Pacifist ending
			if (old.msc == 820 && current.msc != 820) { goto nextSplit; }
			break;
		case 0xFF:	// End run
			// Clear any extra splits
			return true;
		default:
			vars.splits.Dequeue();
			print("Error: Unknown split ID. Skipping to next split...");
			break;
		nextSplit:
			vars.splits.Dequeue();
			print("Next split: 0x" + vars.splits.Peek().ToString("X"));
			return true;
	}
}

gameTime
{
	if (version == "1.0")
	{
		if (current.igt > old.igt)
			return TimeSpan.FromSeconds(current.igt / 30);
	}
}