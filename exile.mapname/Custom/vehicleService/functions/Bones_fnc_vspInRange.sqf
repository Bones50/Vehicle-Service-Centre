_worldSize = if (isNumber (configfile >> "CfgWorlds" >> worldName >> "mapSize")) then {getNumber (configfile >> "CfgWorlds" >> worldName >> "mapSize");} else {8192;};
_middle = _worldSize / 2;
_servicePoints = nearestObjects [[_middle, _middle], ['Land_FuelStation_02_workshop_F'],_worldSize];

{
_pos = getPos _x;
_trg = createTrigger ["EmptyDetector", _pos];
_trg setTriggerArea [50, 50, 0, false];
_trg setTriggerActivation ["ANYPLAYER", "PRESENT", true];
_trg setTriggerStatements
[
   "this",    //using the keyword "this", the above statements will be considered for checking whether the trigger is (de)activated
   "0 = [] spawn {['InfoTitleOnly', ['You are in range of a Vehicle Service Point']] call ExileClient_gui_toaster_addTemplateToast;};",
   "0 = [] spawn {['InfoTitleOnly', ['You have left range of the Vehicle Service Point']] call ExileClient_gui_toaster_addTemplateToast;};"
];
} forEach _servicePoints;