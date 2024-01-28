// Created by Canine & ISO
// Game version 181/7517962 (Steam)
// Created on 2024-01-28

state("HorizonZeroDawn")
{
    uint loading : 0x0714F830, 0x4B4;
}

startup
{
}

isLoading
{
    return current.loading >= 1;
}

exit
{
}

update
{
}