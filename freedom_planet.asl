state("FP", "1.21.4")
{
	double igt : "FP.exe", 0x1DD5100, 0x14, 0x1B8;
	uint totalIgt : "FP.exe", 0x1DD4EA0, 0x64, 0x3C;
	int frame : "FP.exe", 0x1DD4D50;
}

state("FP", "1.20.4")
{
	// Adventure mode is not supported
	double igt : "FP.exe", 0x1DAE6C8, 0x14, 0x1B8;
	uint totalIgt : "FP.exe", 0x1DAE488, 0x64, 0x3C;
	int frame : "FP.exe", 0x1DAE338;
}

startup
{
	timer.OnStart += (s, e) =>
	{
		vars.time = 0;
		vars.lastSplit = 0;		
		vars.doSplit = false;
	};
}

init
{
	switch (modules.First().ModuleMemorySize)
	{
		case 0x01F13000:
			version = "1.21.4";
			break;
		case 0x01EDD000:
			version = "1.20.4";
			break;
		default:
			print("Could not detect version.");
			break;
	}
}

start
{
	return (current.frame == 20 || current.frame == 16 || current.frame == 81) && old.frame == 6;
}

split
{
	if (vars.doSplit)
	{
		vars.doSplit = false;
		return true;
	}
}

reset
{
	return current.frame == 3;
}

isLoading
{
	return true;
}

gameTime
{
	if (current.totalIgt > vars.lastSplit)
	{
			vars.lastSplit = current.totalIgt;
			vars.doSplit = true;
	}

	uint newTime = vars.lastSplit + (uint)current.igt;
	
	if (newTime > vars.time)
		vars.time = newTime;
	
	return TimeSpan.FromMilliseconds(vars.time);
}
