private ["_vehicle", "_allHitpoints", "_hitpointNames", "_totalRepairList", "_totalSalvageList", "_wheelRepairList", "_wheelSalvageList", "_tempLabel", "_noWheels", "_tempExpression", "_tempMenu", "_wheelPrice", "_valueType"];

//REPAIR CONFIG
_valueType = "Poptabs"; // type of cost

//items that contribute to price of repair
_wheelRepairItems = ["Exile_Item_CarWheel"];
_glassRepairItems = ["Exile_Item_LightBulb"];
_engineRepairItems = ["Exile_Item_JunkMetal", "Exile_Item_MetalBoard", "Exile_Item_MetalScrews","Exile_Item_MetalWire"];
_rotorRepairItems = ["Exile_Item_MetalBoard", "Exile_Item_MetalPole"];
_fuelRepairItems = ["Exile_Item_MetalBoard"];
_otherRepairItems = ["Exile_Item_DuctTape", "Exile_Item_MetalBoard","Exile_Item_MetalScrews","Exile_Item_MetalWire"];

_refuelOption = "true"; //turn on and off refuel option: 1 on, 0 off
_fuelingPrice = 10; //price of fuel per litre

//ENDCONFIG

_vehicle = cursorTarget;
if (!local _vehicle) exitwith
{
	["InfoTitleAndText", ["Service Point Info", "Get in driver seat first"]] call ExileClient_gui_toaster_addTemplateToast;
};
if (ExileClientPlayerIsInCombat) exitWith
{
	["ErrorTitleOnly", ["You are in combat!"]] call ExileClient_gui_toaster_addTemplateToast;
};
if (vehicle player isEqualTo _vehicle) exitWith 
{
	["ErrorTitleOnly", ["Are you serious?"]] call ExileClient_gui_toaster_addTemplateToast;
};
if (ExilePlayerInSafezone) exitWith 
{
	["ErrorTitleOnly", ["Leave Safezone First!"]] call ExileClient_gui_toaster_addTemplateToast;
};
_damage = damage _vehicle;
if (_damage == 1) exitwith
{
	["ErrorTitleOnly", ["Vehicle is Destroyed!"]] call ExileClient_gui_toaster_addTemplateToast;
};
_allHitpoints = getAllHitPointsDamage _vehicle;
_hitpointNames = _allHitpoints select 0;
_tempMenu = [["Vehicle Service Repair Menu",true]];
_tempSubMenuWheels = [["Wheel Menu",true]];
_tempSubMenuWindows = [["Window Menu",true]];
_totalRepairPrice = 0;
_allWheelPrice = 0;
_allGlassPrice = 0;

/////////Wheels Menus
_wheelRepairList = [];
_noWheelsTemp = getnumber (configfile >> "cfgvehicles" >> (typeof _vehicle) >> "numberPhysicalWheels");
{
	_wheel = ["wheel", _x] call bis_fnc_instring;
	if(_wheel) then
	{
		_damage = _vehicle getHitPointDamage _x;
		if (_damage > 0) then 
		{
			_wheelRepairList pushback _x;
		};
	};
}forEach _hitpointNames;

//wheel Repair MenuItems
//get pricing
_wheelPrice = 0;
{
_wheelPriceTemp = (getNumber (missionConfigFile >> "CfgExileArsenal" >> _x >> "price"));
_wheelPrice = _wheelPrice + _wheelPriceTemp;
} forEach _wheelRepairItems;
	
	{
	_tempLabel = _x;
	_noWheels = getnumber (configfile >> "cfgvehicles" >> (typeof _vehicle) >> "numberPhysicalWheels");
	if (_noWheels == 8) then 
		{
			if (_x == "HitRFWheel") then {_tempLabel = format ["Repair Right Front Wheel - %1 %2", _wheelPrice, _valueType]};
			if (_x == "HitRF2Wheel") then {_tempLabel = format ["Repair Right Front Wheel 2 - %1 %2", _wheelPrice, _valueType]};
			if (_x == "HitRMWheel") then {_tempLabel = format ["Repair Right Rear Wheel 2 - %1 %2", _wheelPrice, _valueType]};
			if (_x == "HitRBWheel") then {_tempLabel = format ["Repair Right Rear Wheel - %1 %2", _wheelPrice, _valueType]};
			if (_x == "HitLFWheel") then {_tempLabel = format ["Repair Left Front Wheel - %1 %2", _wheelPrice, _valueType]};
			if (_x == "HitLF2Wheel") then {_tempLabel = format ["Repair Left Front Wheel 2 - %1 %2", _wheelPrice, _valueType]};
			if (_x == "HitLMWheel") then {_tempLabel = format ["Repair Left Rear Wheel 2 - %1 %2", _wheelPrice, _valueType]};
			if (_x == "HitLBWheel") then {_tempLabel = format ["Repair Left Rear Wheel - %1 %2", _wheelPrice, _valueType]};
		};

	if (_noWheels == 4) then 
		{
			if (_x == "HitRFWheel") then {_tempLabel = format ["Repair Right Front Wheel - %1 %2", _wheelPrice, _valueType]};
			if (_x == "HitRF2Wheel") then {_tempLabel = format ["Repair Right Rear Wheel - %1 %2", _wheelPrice, _valueType]};
			if (_x == "HitLFWheel") then {_tempLabel = format ["Repair Left Front Wheel - %1 %2", _wheelPrice, _valueType]};
			if (_x == "HitLF2Wheel") then {_tempLabel = format ["Repair Left Rear Wheel - %1 %2", _wheelPrice, _valueType]};
			if (_x == "HitRMWheel") then {_tempLabel = "error"};
			if (_x == "HitLMWheel") then {_tempLabel = "error"};
			if (_x == "HitLBWheel") then {_tempLabel = "error"};
			if (_x == "HitRBWheel") then {_tempLabel = "error"};
		};

	if (_noWheels == 6) then 
		{
			if (_x == "HitRFWheel") then {_tempLabel = format ["Repair Right Front Wheel - %1 %2", _wheelPrice, _valueType]};
			if (_x == "HitRF2Wheel") then {_tempLabel = format ["Repair Right Middle Wheel - %1 %2", _wheelPrice, _valueType]};
			if (_x == "HitRMWheel") then {_tempLabel = format ["Repair Right Rear Wheel - %1 %2", _wheelPrice, _valueType]};
			if (_x == "HitLFWheel") then {_tempLabel = format ["Repair Left Front Wheel - %1 %2", _wheelPrice, _valueType]};
			if (_x == "HitLF2Wheel") then {_tempLabel = format ["Repair Left Middle Wheel - %1 %2", _wheelPrice, _valueType]};
			if (_x == "HitLMWheel") then {_tempLabel = format ["Repair Left Rear Wheel - %1 %2", _wheelPrice, _valueType]};
			if (_x == "HitLBWheel") then {_tempLabel = "error"};
			if (_x == "HitRBWheel") then {_tempLabel = "error"};
		};
	if !(_tempLabel == "error") then
		{
			_tempStatement = [];
			_item = [];
			_action = "RepairCarWheel";
			_item pushback _x;
			_tempStatement pushback _action;
			_tempStatement pushback _item;
			_tempStatement pushback _wheelPrice;
			_temp2 = format ["%1 Call salvage_setup", _tempStatement];
			_tempExpression = [];
			_tempExpression pushback _tempLabel;
			_tempExpression = _tempExpression + [[0],"",-5, [["expression", _temp2]] ,"1","1"];
			_tempSubMenuWheels pushback _tempExpression;
		};
	_totalRepairPrice = _totalRepairPrice + _wheelPrice;
	_allWheelPrice = _allWheelPrice + _wheelPrice;
}forEach _wheelRepairList;

//////////Rotors Menu

_rotorRepairList = [];

{
	_rotor = ["rotor", _x] call bis_fnc_instring;
	if(_rotor) then
	{
		_damage = _vehicle getHitPointDamage _x;
		if (_damage > 0) then 
		{
			_rotorRepairList pushback _x;
		};
	};
}forEach _hitpointNames;

//rotor Repair Menu
_rotorPrice = 0;
{
_rotorPriceTemp = (getNumber (missionConfigFile >> "CfgExileArsenal" >> _x >> "price"));
_rotorPrice = _rotorPrice + _rotorPriceTemp;
} forEach _rotorRepairItems;
{
	_tempLabel = _x;
	if (_x == "HitHRotor") then {_tempLabel = format ["Repair Main Rotor - %1 %2", _rotorPrice, _valueType]};
	if (_x == "HitVRotor") then {_tempLabel = format ["Repair Tail Rotor - %1 %2", _rotorPrice, _valueType]};
	if !(_tempLabel == "error") then
		{
			_tempStatement = [];
			_item = [];
			_action = "repairRotor";
			_item pushback _x;
			_tempStatement pushback _action;
			_tempStatement pushback _item;
			_tempStatement pushback _rotorPrice;
			_temp2 = format ["%1 Call salvage_setup", _tempStatement];
			_tempExpression = [];
			_tempExpression pushback _tempLabel;
			_tempExpression = _tempExpression + [[0],"",-5, [["expression", _temp2]] ,"1","1"];
			_tempMenu pushback _tempExpression;
		};
		_totalRepairPrice = _totalRepairPrice + _rotorPrice;
}forEach _rotorRepairList;

///////////Glass Menu

_glassRepairList = [];

{
	_glass = ["glass", _x] call bis_fnc_instring;
	if(_glass) then
	{
		_damage = _vehicle getHitPointDamage _x;
		if (_damage > 0) then 
		{
			_glassRepairList pushback _x;
		};
	};
}forEach _hitpointNames;

//glass Repair Menu
_glassPrice = 0;
{
_glassPriceTemp = (getNumber (missionConfigFile >> "CfgExileArsenal" >> _x >> "price"));
_glassPrice = _glassPrice + _glassPriceTemp;
} forEach _glassRepairItems;
{
	_tempLabel = _x;
	if (_x == "HitGlass1") then {_tempLabel = format ["Repair Window 1 - %1 %2", _glassPrice, _valueType]};
	if (_x == "HitGlass1A") then {_tempLabel = format ["Repair Window 1a - %1 %2", _glassPrice, _valueType]};
	if (_x == "HitGlass1B") then {_tempLabel = format ["Repair Window 1b - %1 %2", _glassPrice, _valueType]};
	if (_x == "HitGlass2") then {_tempLabel = format ["Repair Window 2 - %1 %2", _glassPrice, _valueType]};
	if (_x == "HitGlass3") then {_tempLabel = format ["Repair Window 3 - %1 %2", _glassPrice, _valueType]};
	if (_x == "HitGlass4") then {_tempLabel = format ["Repair Window 4 - %1 %2", _glassPrice, _valueType]};
	if (_x == "HitGlass5") then {_tempLabel = format ["Repair Window 5 - %1 %2", _glassPrice, _valueType]};
	if (_x == "HitGlass6") then {_tempLabel = format ["Repair Window 6 - %1 %2", _glassPrice, _valueType]};
	if (_x == "HitGlass7") then {_tempLabel = format ["Repair Window 7 - %1 %2", _glassPrice, _valueType]};
	if (_x == "HitGlass8") then {_tempLabel = format ["Repair Window 8 - %1 %2", _glassPrice, _valueType]};
	if (_x == "HitGlass9") then {_tempLabel = format ["Repair Window 9 - %1 %2", _glassPrice, _valueType]};
	if (_x == "HitGlass10") then {_tempLabel = format ["Repair Window 10 - %1 %2", _glassPrice, _valueType]};
	if (_x == "HitGlass11") then {_tempLabel = format ["Repair Window 11 - %1 %2", _glassPrice, _valueType]};
	if (_x == "HitGlass12") then {_tempLabel = format ["Repair Window 12 - %1 %2", _glassPrice, _valueType]};
	if (_x == "HitGlass13") then {_tempLabel = format ["Repair Window 13 - %1 %2", _glassPrice, _valueType]};
	if (_x == "HitGlass14") then {_tempLabel = format ["Repair Window 14 - %1 %2", _glassPrice, _valueType]};
	if (_x == "HitGlass15") then {_tempLabel = format ["Repair Window 15 - %1 %2", _glassPrice, _valueType]};
	if (_x == "HitGlass16") then {_tempLabel = format ["Repair Window 16 - %1 %2", _glassPrice, _valueType]};
	if (_x == "HitGlass17") then {_tempLabel = format ["Repair Window 17 - %1 %2", _glassPrice, _valueType]};
	if (_x == "HitRGlass") then {_tempLabel = format ["Repair Window Right - %1 %2", _glassPrice, _valueType]};
	if (_x == "HitLGlass") then {_tempLabel = format ["Repair Window Left - %1 %2", _glassPrice, _valueType]};
	if !(_tempLabel == "error") then
		{
			_tempStatement = [];
			_item = [];
			_action = "repairGlass";
			_item pushback _x;
			_tempStatement pushback _action;
			_tempStatement pushback _item;
			_tempStatement pushback _glassPrice;
			_temp2 = format ["%1 Call salvage_setup", _tempStatement];
			_tempExpression = [];
			_tempExpression pushback _tempLabel;
			_tempExpression = _tempExpression + [[0],"",-5, [["expression", _temp2]] ,"1","1"];
			_tempSubMenuWindows pushback _tempExpression;
		};
		_totalRepairPrice = _totalRepairPrice + _glassPrice;
		_allGlassPrice = _allGlassPrice + _glassPrice;
}forEach _glassRepairList;

//Engine Menu
_engineRepairList = [];

{
	if(_x == "hitEngine") then
	{
		_damage = _vehicle getHitPointDamage _x;
		if (_damage > 0) then 
		{
			_engineRepairList pushback _x;
		};
	};
}forEach _hitpointNames;

//engine Repair
_enginePrice = 0;
{
_enginePriceTemp = (getNumber (missionConfigFile >> "CfgExileArsenal" >> _x >> "price"));
_enginePrice = _enginePrice + _enginePriceTemp;
} forEach _engineRepairItems;

{
	_tempLabel = _x;
	if (_x == "HitEngine") then {_tempLabel = format ["Repair Engine - %1 %2", _enginePrice, _valueType]};
	if !(_tempLabel == "error") then
		{
			_tempStatement = [];
			_item = [];
			_action = "repairEngine";
			_item pushback _x;
			_tempStatement pushback _action;
			_tempStatement pushback _item;
			_tempStatement pushback _enginePrice;
			_temp2 = format ["%1 Call salvage_setup", _tempStatement];
			_tempExpression = [];
			_tempExpression pushback _tempLabel;
			_tempExpression = _tempExpression + [[0],"",-5, [["expression", _temp2]] ,"1","1"];
			_tempMenu pushback _tempExpression;
		};
		_totalRepairPrice = _totalRepairPrice + _enginePrice;
}forEach _engineRepairList;

//Fuel Tank Menu
_fuelRepairList = [];

{
	if(_x == "hitFuel") then
	{
		_damage = _vehicle getHitPointDamage _x;
		if (_damage > 0) then 
		{
			_fuelRepairList pushback _x;
		};
	};
}forEach _hitpointNames;

//Fuel Tank Repair
_fuelPrice = 0;
{
_fuelPriceTemp = (getNumber (missionConfigFile >> "CfgExileArsenal" >> _x >> "price"));
_fuelPrice = _fuelPrice + _fuelPriceTemp;
} forEach _fuelRepairItems;

{
	_tempLabel = _x;
	if (_x == "HitFuel") then {_tempLabel = format ["Repair Fuel Tank - %1 %2", _fuelPrice, _valueType]};
	if !(_tempLabel == "error") then
		{
			_tempStatement = [];
			_item = [];
			_action = "repairFuel";
			_item pushback _x;
			_tempStatement pushback _action;
			_tempStatement pushback _item;
			_temp2 = format ["%1 Call salvage_setup", _tempStatement];
			_tempExpression = [];
			_tempExpression pushback _tempLabel;
			_tempExpression = _tempExpression + [[0],"",-5, [["expression", _temp2]] ,"1","1"];
			_tempMenu pushback _tempExpression;
			_totalRepairPrice = _totalRepairPrice + _fuelPrice;
		};
}forEach _fuelRepairList;

//other Repair
_overallDamage = 0;
_otherDamageItems = [];
{
	_glass = ["glass", _x] call bis_fnc_instring;
	_rotor = ["rotor", _x] call bis_fnc_instring;
	_wheel = ["wheel", _x] call bis_fnc_instring;
	_engine = ["engine", _x] call bis_fnc_instring;
	_fuel = ["fuel", _x] call bis_fnc_instring;
	
	if !(_glass || _rotor || _wheel || _fuel || _engine) then
	{
	_damage = _vehicle getHitPointDamage _x;
	_overallDamage = _overallDamage + _damage;
	_otherDamageItems pushback _x;
	};
} forEach _hitpointNames;

if (_overallDamage > 0) then
{
	_otherPrice = 0;
	{
	_otherPriceTemp = (getNumber (missionConfigFile >> "CfgExileArsenal" >> _x >> "price"));
	_otherPrice = _otherPrice + _otherPriceTemp;
	} forEach _otherRepairItems;

	_tempLabel = format ["Repair All Other Damaged Items - %1 %2", _otherPrice, _valueType];
	_tempStatement = [];
	_action = "repairOther";
	_item = _otherDamageItems;
	_tempStatement pushback _action;
	_tempStatement pushback _item;
	_tempStatement pushback _otherPrice;
	_temp2 = format ["%1 Call salvage_setup", _tempStatement];
	_tempExpression = [];
	_tempExpression pushback _tempLabel;
	_tempExpression = _tempExpression + [[0],"",-5, [["expression", _temp2]] ,"1","1"];
	_tempMenu pushback _tempExpression;
	_totalRepairPrice = _totalRepairPrice + _otherPrice;
};

//repair all menu
if(_totalRepairPrice > 0) then
{
_tempLabel = format ["Repair All Items - %1 %2", _totalRepairPrice, _valueType];
_tempStatement = [];
_action = "repairAll";
_item = "";
_tempStatement pushback _action;
_tempStatement pushback _item;
_tempStatement pushback _totalRepairPrice;
_temp2 = format ["%1 Call salvage_setup", _tempStatement];
_tempExpression = [];
_tempExpression pushback _tempLabel;
_tempExpression = _tempExpression + [[0],"",-5, [["expression", _temp2]] ,"1","1"];
_tempMenu pushback _tempExpression;
};

//repair all wheels
if (_allWheelPrice > 0) then 
{
	_tempLabel = format ["Repair All Wheels - %1 %2", _allWheelPrice, _valueType];
	_tempStatement = [];
	_action = "repairAllWheel";
	_item = _wheelRepairList;
	_tempStatement pushback _action;
	_tempStatement pushback _item;
	_tempStatement pushback _allWheelPrice;
	_temp2 = format ["%1 Call salvage_setup", _tempStatement];
	_tempExpression = [];
	_tempExpression pushback _tempLabel;
	_tempExpression = _tempExpression + [[0],"",-5, [["expression", _temp2]] ,"1","1"];
	_tempMenu pushback _tempExpression;
};

//repair all glass
if(_allGlassPrice > 0) then
{
_tempLabel = format ["Repair All Glass - %1 %2", _allGlassPrice, _valueType];
_tempStatement = [];
_action = "repairAllGlass";
_item = _glassRepairList;
_tempStatement pushback _action;
_tempStatement pushback _item;
_tempStatement pushback _allGlassPrice;
_temp2 = format ["%1 Call salvage_setup", _tempStatement];
_tempExpression = [];
_tempExpression pushback _tempLabel;
_tempExpression = _tempExpression + [[0],"",-5, [["expression", _temp2]] ,"1","1"];
_tempMenu pushback _tempExpression;
};


//refuel Option
_maxFuelAmount = getnumber (configfile >> "cfgvehicles" >> (typeof _vehicle) >> "fuelCapacity");
_fuelAmountTemp = fuel _vehicle;
_fuelAmount = _fuelAmountTemp * _maxFuelAmount;
_refillFuelAmount = floor(_maxFuelAmount - _fuelAmount);
_refuelCost = _refillFuelAmount * _fuelingPrice;
if (_refuelCost > 0 && _refuelOption == "true") then 
{
_tempLabel = format ["Refuel the Vehicle - %1 %2", _refuelCost, _valueType];
_tempStatement = [];
_action = "refuelVehicle";
_item = "";
_tempStatement pushback _action;
_tempStatement pushback _item;
_tempStatement pushback _refuelCost;
_temp2 = format ["%1 Call salvage_setup", _tempStatement];
_tempExpression = [];
_tempExpression pushback _tempLabel;
_tempExpression = _tempExpression + [[0],"",-5, [["expression", _temp2]] ,"1","1"];
_tempMenu pushback _tempExpression;
};

_backButton = ["Back",[0],"",-4,[["expression", "Back ""Mainmenu"" "]],"1","1"];
_tempSubMenuWheels pushback _backButton;
_tempSubMenuWindows pushback _backButton;

_wheelMenuOption = ["Repair Individual Wheels",[0],"#USER:ASL_Show_Repair_Service_SubMenuWheels_Array",-5,[["expression", "Wheels ""Submenu"" "]],"1","1"];
_windowMenuOption = ["Repair Indivual Windows",[0],"#USER:ASL_Show_Repair_Service_SubMenuWindows_Array",-5,[["expression", "Windows ""Submenu"" "]],"1","1"];
if (_allWheelPrice > 0) then {_tempMenu pushback _wheelMenuOption;};
if (_allGlassPrice > 0) then {_tempMenu pushback _windowMenuOption;};

//Create the Menu
if (count _tempMenu < 2) exitwith {["ErrorTitleAndText", ["Service Point Info", format ["Nothing requires repair!"]]] call ExileClient_gui_toaster_addTemplateToast;};
	
ASL_Show_Repair_Service_SubMenuWheels_Array = _tempSubMenuWheels;
ASL_Show_Repair_Service_SubMenuWindows_Array = _tempSubMenuWindows;
ASL_Show_Repair_Service_Menu_Array = _tempMenu;

showCommandingMenu "";
showCommandingMenu "#USER:ASL_Show_Repair_Service_Menu_Array";

salvage_setup = {
_vehicle = cursorTarget;
_action = _this select 0;
_items = _this select 1;
_price = _this select 2;
[_action,_vehicle, _items, _price] execVM 'Custom\vehicleService\functions\Bones_fnc_Repair.sqf';
};