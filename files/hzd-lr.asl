// Created by Canine, ISO and Dorian
// Game version 181/7517962 (Steam and GOG)
// Created on 2024-01-28
// Version detection from the Death Stranding LR

state("HorizonZeroDawn", "Steam")
{
    ulong worldPtr : 0x0714F830;
    uint loading : 0x0714F830, 0x4B4;
}

state("HorizonZeroDawn", "GOG")
{
    ulong worldPtr : 0x0714C728;
    uint loading : 0x0714C728, 0x4B4;
}

init
{
    print(modules.First().ModuleMemorySize.ToString());
    switch(modules.First().ModuleMemorySize)
	{
        case (150986752):
            version = "Steam";
            break;
        case (150966272):
            version = "GOG";
            break;
	}
}

startup
{
}

isLoading
{
    return (current.worldPtr > 0 && current.loading >= 1);
}

exit
{
}

update
{
}
