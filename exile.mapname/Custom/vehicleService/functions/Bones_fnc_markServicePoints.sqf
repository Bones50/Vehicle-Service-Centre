private ["_worldSizeTemp", "_worldSize", "_middle", "_servicePoints", "_markerstr"];

_worldSizeTemp = if (isNumber (configfile >> "CfgWorlds" >> worldName >> "mapSize")) then {getNumber (configfile >> "CfgWorlds" >> worldName >> "mapSize");} else {8192;};
_worldsize = _worldsizeTemp + 1000;
_middle = _worldSize / 2;
_servicePoints = nearestObjects [[_middle, _middle], ["Land_FuelStation_02_workshop_F"], _worldSize];
_id = 0;
{
_markerstr = createMarker [format ["Vehicle Service Centre %1", _id], getPos _x];
_markerstr setMarkerShape "ICON";
_markerstr setMarkerType "respawn_unknown";
_id = _id +1;
} forEach _servicePoints;