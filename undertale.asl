state("Undertale", "1.0")
{
	double naming : "Undertale.exe", 0x2EBD78, 0x250, 8;
	uint pFlag : "Undertale.exe", 0x2EBD78, 0x38, 0x3C, 4;
	double typer : "Undertale.exe", 0x2EBD78, 0xF4, 8;
	double exp : "Undertale.exe", 0x2EBD78, 0x20, 0x58;
	double plot : "Undertale.exe", 0x2EBD78, 0x14, 4, 8;
	uint room : "Undertale.exe", 0x50F300;
	double fivedamage : "Undertale.exe", 0x2EBD78, 0xC8, 8;
	double msc : "Undertale.exe", 0x2EBD78, 0xF8, 8;
}

startup
{
	refreshRate = 30;
	
	settings.Add("6", false, "Genocide Ending");
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
	
	vars.FindCharaCon = (Func<IntPtr>)(() =>
	{
		// Finds the instance variable obj_truechara.con
		var target = new SigScanTarget(0, "CE 86 01 00");
		
		foreach (var page in memory.MemoryPages())
		{
			var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);

			foreach (var ptr in scanner.ScanAll(target))
			{
				if (ptr != IntPtr.Zero)
				{
					var con = memory.ReadValue<double>(ptr - 16);
					
					if (con == Math.Floor(con))
						if (con >= 0 && con < 9)
							return ptr - 16;
				}
			}
		}
		
		return IntPtr.Zero;
	});
	
	if (new DeepPointer("Undertale.exe", 0x2EBD78).Deref<uint>(game) == 5)
	{
		print("This version is currently unsupported.");
		version = "1.1";
		
		// todo: implement 1.1
		// base address at undertale.exe+34D638
	}
	else
		version = "1.0";
}

update
{
	if (version == "1.1")
		return false;
}

start
{
	if (old.naming == 2)
		return current.naming == 4 || current.naming == 5;
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
			if (vars.charaCon == null)
			{
				if (current.typer == 104)
				{
					var pCharaCon = vars.FindCharaCon();
					
					if (pCharaCon != IntPtr.Zero)
						vars.charaCon = new MemoryWatcher<double>(pCharaCon);
				}
			}
			
			if (vars.charaCon != null)
			{
				vars.charaCon.Update(game);
				if (vars.charaCon.Current == 19 || vars.charaCon.Current == 29)
					goto nextSplit;
			}
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
			if (current.fivedamage >= 500) { goto nextSplit; }
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
