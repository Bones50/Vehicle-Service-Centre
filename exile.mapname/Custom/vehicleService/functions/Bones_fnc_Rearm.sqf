/*
Bones Vehicle ReArm Script

Executed from Bones_fnc_salvageAndRepairMenu.sqf

Call as [_action, _vehicle, _items, _reloadCost, _bulletAmount, _pylon] execVM 'Custom\VSP\Bones_fnc_Rearm.sqf'

*/

private ["_mag", "_vehicle", "_action", "_reloadCost", "_bulletAmount", "_exilew", "_vehicleMags", "_weapArray", "_cfgTurret", "_pylonIndex"];

_mag = _this select 2;
_vehicle = _this select 1;
_action = _this select 0;
_reloadCost = _this select 3;
_bulletAmount = _this select 4;

//get array of [magclass, maxmags] for all turrets weapons and plons
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

//check if enough money
_exilew = player getVariable ["ExileMoney", 0];
if (_exilew <_reloadCost) exitWith {["ErrorTitleOnly", ["You don't have enough money!"]] call ExileClient_gui_toaster_addTemplateToast;};

//Re-Arm vehicle or Mag
_vehicleMags = _vehicle call Bones_fnc_getRearmVehicleLoadout;
{
	private ["_turretPath", "_magMaxAmmoCount", "_maxBullets","_magData", "_magClass", "_maxMagAmmo", "_numMags"];
	_turretPath = _x select 0;
	_pylonIndex = _x select 1;
	_magClass = _x select 2;
	if (_action == "ReloadAllAmmo") then
	{
		_vehicle setVehicleAmmo 1;
	} else
	{
		if(_magClass == _mag) then 
		{
			if (["120mm",_magClass] call BIS_fnc_inString || ["125mm",_magClass] call BIS_fnc_inString || ["105mm",_magClass] call BIS_fnc_inString || ["L30A1_Cannon",_magClass] call BIS_fnc_inString || ["2A46",_magClass] call BIS_fnc_inString || ["100mm",_magClass] call BIS_fnc_inString) then
			{
				_vehicle removeMagazinesTurret [_magClass, _turretPath];
				_vehicle addMagazineTurret [_magClass,_turretPath,_bulletAmount];
			} else
			{
				//DO THIS IF SMOKE
				if (["smoke",_magclass] call BIS_fnc_inString) then
				{
					_vehicle removeMagazinesTurret [_magClass, _turretPath];
					_vehicle removeWeaponTurret ["SmokeLauncher", _turretPath];
					_vehicle addMagazineTurret [_magClass,_turretPath,_bulletAmount];
					_vehicle addWeaponTurret ["SmokeLauncher", _turretPath];
				} else
				{
					//DO THIS IF CHAFF
					if (["chaff",_magclass] call BIS_fnc_inString) then
					{
						_vehicle removeMagazinesTurret [_magClass, _turretPath];
						_vehicle removeWeaponTurret ["CMFlareLauncher", _turretPath];
						_vehicle addMagazineTurret [_magClass,_turretPath,_bulletAmount];
						_vehicle addWeaponTurret ["CMFlareLauncher", _turretPath];
					} else
					{
						//DO THIS IF PYLON
						if (["pylon",_magclass] call BIS_fnc_inString) then
						{
							_vehicle setAmmoOnPylon [_pylonIndex,_bulletAmount];
						} else
						{
							//FOR EVERYTHING ELSE
							_maxMagAmmo = (configFile >> "CfgMagazines" >> _magClass >> "count") call BIS_fnc_getCfgData;
							_vehicle addMagazineTurret [_magClass, _turretPath, _bulletAmount];	
							_numMags = floor (_bulletAmount / _maxMagAmmo);
							_vehicle removeMagazinesTurret [_magClass, _turretPath];
							while {_numMags > 0} do
							{
								_vehicle addMagazineTurret [_magClass, _turretPath];
								_numMags = _numMags - 1;
							};
						};
					};
				};
			};
		};
	};
}forEach _vehicleMags;

if(_reloadCost > 0 && isTradeEnabled)then{
        takegive_poptab = [player,_reloadCost,true];
        publicVariableServer "takegive_poptab";
};

["SuccessTitleOnly", [format["Rearm Complete, Total Cost was %1 Poptabs", _reloadCost]]] call ExileClient_gui_toaster_addTemplateToast;
