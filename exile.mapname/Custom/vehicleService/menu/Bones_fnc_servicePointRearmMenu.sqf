private ["_starter", "_costType", "_costTypes", "_defaultCost", "_vehicle", "_vehicleMags", "_tempMenu", "_ammoRearmList", "_repairAllCost", "_tempStatement", "_action", "_item", "_cost", "_temp2", "_tempExpression", "_weapArray", "_cfgTurret", "_damage"];

//configFile
_starter = "Reload";
_costType = "PopTabs";
_defaultCost = 2;
//costs per bullet per bullet type
_costTypes = 
[
	["24Rnd_120mm_APFSDS_shells_Tracer_Red", 200],
	["12Rnd_120mm_HE_shells_Tracer_Red", 100],
	["12Rnd_120mm_HEAT_MP_T_Red", 150],
	["200Rnd_762x51_Belt_Red", 2],
	["SmokeLauncherMag", 5],
	["100Rnd_Green_Tracer_127x107_DSHKM_M", 2],
	["29Rnd_30mm_AGS30", 4],
	["2000Rnd_762x51_Belt", 2],
	["Laserbatteries", 5],
	["100Rnd_127x99_mag_Tracer_Yellow", 2],
	["100Rnd_Red_Tracer_127x99_M", 2],
	["50Rnd_127x107_DSHKM_M", 2],
	["200Rnd_762x51_Belt_Green", 2],
	["PylonRack_12Rnd_missiles",50],
	["5000Rnd_762x51_Belt",2],
	["240Rnd_CMFlare_Chaff_Magazine",3],
	["1000Rnd_20mm_shells",5],
	["PylonMissile_1Rnd_AAA_missiles",100],
	["PylonRack_12Rnd_PG_missiles",50]
];
//endconfig



//get ammo type and max amount fromn config 
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
_weapArray = [];
{
	_cfgTurret = _x;
	{
		_weapArray pushBack [(getArray (_cfgTurret >> "magazines") select 0),count getArray (_cfgTurret >> "magazines")]
	} forEach (getArray (_cfgTurret >> "weapons"));
} forEach ([_vehicle] call BIS_fnc_getTurrets);

{
	_weapArray pushBack [_x, 1]
} forEach (getPylonMagazines _vehicle);

_vehicleMags = _vehicle call Bones_fnc_getRearmVehicleLoadout;

_tempMenu = [["Vehicle Service Rearm Menu",true]];
_ammoRearmList = [];
_repairAllCost = 0;
{
	private ["_turretPath", "_totalCost", "_bulletCost", "_maxMag", "_menuItem", "_magClass", "_displayName", "_ammoCount", "_magMaxAmmoCount", "_maxBullets", "_numMagsToLoad", "_currentMags", "_loadedMagCount", "_currentMagToLoad", "_currentMagCost", "_menuItemAndDetails", "_pylonIndex"];
	_turretPath = _x select 0;
	_totalCost = 0;
	_bulletCost = 0;
	_maxMag = 0;
	_menuItem = [];
	_pylonIndex = _x select 1;
	_magClass = _x select 2;
	
	//get bullet cost for this turret mag
	{
		if (_magClass == (_x select 0)) then {_bulletCost = _x select 1;};
	} forEach _costTypes;
	if (_bulletCost == 0) then {_bulletCost = _defaultCost;};
	
	//get max number of mags for this turret mag
	{
		if (_magClass == (_x select 0)) then {_maxMag = _x select 1;};
	} forEach _weapArray;

	//Set Display name of Mag
	_displayName = getText(configFile >> "CfgMagazines" >> _magClass >> "displayName");
	if (_displayName == "") then {_displayName = _magClass;};
	
	//get ammo and get total max bullets
	_ammoCount = _x select 3;
	_magMaxAmmoCount = getNumber(configFile >> "CfgMagazines" >> _magClass >> "count");
	_maxBullets = _magMaxAmmoCount * _maxMag;
	
	//if less than  max bullets work out how many and how much
	if (_ammoCount < _maxBullets) then
	{
		if (["120mm",_magClass] call BIS_fnc_inString || ["125mm",_magClass] call BIS_fnc_inString || ["105mm",_magClass] call BIS_fnc_inString || ["L30A1_Cannon",_magClass] call BIS_fnc_inString || ["2A46",_magClass] call BIS_fnc_inString || ["100mm",_magClass] call BIS_fnc_inString || ["smoke",_magClass] call BIS_fnc_inString) then
		{
			_numMagsToLoad = _magMaxAmmoCount - _ammoCount;
			_totalCost = _numMagsToLoad * _bulletCost;
		} else
		{
			_currentMags = floor (_ammoCount / _magMaxAmmoCount);
			_numMagsToLoad = _maxMag - _currentMags - 1;
			_totalCost = _numMagsToLoad * _bulletCost * _magMaxAmmoCount;
			_loadedMagCount = _ammoCount - (_currentMags * _magMaxAmmoCount);
			_currentMagToLoad = _magMaxAmmoCount - _loadedMagCount;
			_currentMagCost = _currentMagToLoad * _bulletCost;
			_totalCost = _totalCost + _currentMagCost;
		};
		_menuItem = format ["%1 %2 - %3 %4", _starter, _displayName, _totalCost, _costType];			
		_menuItemAndDetails = [];
		_menuItemAndDetails pushback _menuItem;
		_menuItemAndDetails pushback _magClass;
		_menuItemAndDetails pushback _totalCost;
		_menuItemAndDetails pushback _maxBullets;
		_menuItemAndDetails pushback _pylonIndex;
		_ammoRearmList pushback _menuItemAndDetails;
		_repairAllCost = _repairAllCost + _totalCost;
	};
} forEach _vehicleMags;	


//Create Menu Items for each magazine
{
	private ["_tempLabel", "_tempStatement", "_action", "_item", "_cost", "_bullets", "_pylon", "_temp2", "_tempExpression"];
	_tempLabel = _x select 0;
	if !(_tempLabel == "error") then
		{
			_tempStatement = [];
			_action = "ReloadAmmo";
			_item = _x select 1;
			_cost = _x select 2;
			_bullets = _x select 3;
			_pylon = _x select 4;
			_tempStatement pushback _action;
			_tempStatement pushback _item;
			_tempStatement pushback _cost;
			_tempStatement pushback _bullets;
			_tempStatement pushback _pylon;
			_temp2 = format ["%1 Call rearm_setup", _tempStatement];
			_tempExpression = [];
			_tempExpression pushback _tempLabel;
			_tempExpression = _tempExpression + [[0],"",-5, [["expression", _temp2]] ,"1","1"];
			_tempMenu pushback _tempExpression;
		};
} forEach _ammoRearmList;

//Create the Menu
if (count _tempMenu < 2) exitwith {["ErrorTitleAndText", ["Rearm Issue","No Guns Require Reloading!"]] call ExileClient_gui_toaster_addTemplateToast;};

_tempStatement = [];
_action = "ReloadAllAmmo";
_item = "All";
_cost = _repairAllCost;
_tempStatement pushback _action;
_tempStatement pushback _item;
_tempStatement pushback _cost;
_tempStatement pushback _costTypes;
_temp2 = format ["%1 Call rearm_setup", _tempStatement];
_tempExpression = [];
_tempExpression pushback format ["%1 all ammo - %2 %3", _starter, _repairAllCost, _costType];
_tempExpression = _tempExpression + [[0],"",-5, [["expression", _temp2]] ,"1","1"];
_tempMenu pushback _tempExpression;


ASL_Show_Repair_Service_Menu_Array = _tempMenu;

showCommandingMenu "";
showCommandingMenu "#USER:ASL_Show_Repair_Service_Menu_Array";

rearm_setup = {
private ["_vehicle", "_action", "_items", "_reloadCost", "_bulletAmount", "_pylon"];
_vehicle = cursorTarget;
_action = _this select 0;
_items = _this select 1;
_reloadCost = _this select 2;
_bulletAmount = _this select 3;
_pylon = _this select 4;
[_action, _vehicle, _items, _reloadCost, _bulletAmount, _pylon] execVM 'Custom\vehicleService\functions\Bones_fnc_Rearm.sqf';
};