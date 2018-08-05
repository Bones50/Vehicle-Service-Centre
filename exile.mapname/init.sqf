//START Bones Vehicle Service
Bones_fnc_getRearmVehicleLoadout = compileFinal (preprocessFileLineNumbers "Custom\vehicleService\functions\Bones_fnc_getRearmVehicleLoadout.sqf");
[] execVM "Custom\vehicleService\functions\takegive_poptab_init.sqf";

//add this if you want the service points to have markers
[] execVM "Custom\vehicleService\functions\Bones_fnc_markServicePoints.sqf";

//put the below at the end of your init after everything else
if (isServer)  exitWith {};
[] execVM "Custom\vehicleService\functions\Bones_fnc_vspInRange.sqf";
//END Bones Vehicle Service
