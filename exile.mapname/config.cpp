//Add the below to the "class Car" and "class Air" classes under "class CfgInteractionMenus"


//servicepoint
class ServicePointRepair: ExileAbstractAction
{
	title = "ServicePoint Repair";
	condition = "(count (nearestObjects [(getPos player), ['Land_FuelStation_02_workshop_F'],50]) >0)";
	action = "_this call Bones_fnc_servicePointRepairMenu";
};

class ServicePointRearm: ExileAbstractAction
{
	title = "ServicePoint Re-Arm";
	condition = "(count (nearestObjects [(getPos player), ['Land_FuelStation_02_workshop_F'],50]) >0)";
	action = "_this call Bones_fnc_servicePointRearmMenu";
};
//endsServicePoint