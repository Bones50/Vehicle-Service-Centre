/*
Bones Vehicle Repair Script

Executed from Bones_fnc_salvageAndRepairMenu.sqf

Call as [_action, _vehicle, _items, _price] execVM 'Custom\vehicleService\Bones_fnc_Repair.sqf';

*/

private ["_items", "_vehicle", "_action", "_price", "_exilew"];

_items = _this select 2;
_vehicle = _this select 1;
_action = _this select 0;
_price = _this select 3;

_exilew = player getVariable ["ExileMoney", 0];
if (_exilew <_price) exitWith {["ErrorTitleOnly", ["You don't have enough money!"]] call ExileClient_gui_toaster_addTemplateToast;};

if (_action == 'refuelVehicle') then
{
	_vehicle setfuel 1;
} else 
{
	if (_action == 'repairAll') then
	{
		_vehicle setdamage 0;
	} else
	{
		{
		_vehicle setHitPointDamage [_x, 0];
		} forEach _items;
	};
};

if(_price > 0 && isTradeEnabled)then{
        takegive_poptab = [player,_price,true];
        publicVariableServer "takegive_poptab";
};

["SuccessTitleOnly", ["Repair Complete"]] call ExileClient_gui_toaster_addTemplateToast;