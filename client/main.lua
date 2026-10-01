local open=false;local spectating=false
local function notify(t,typ)exports.szcore_ui:Notify({description=t,type=typ or'info'})end
local function refresh()if not open then return end;local d=exports.szcore:AwaitCallback('szcore_admin:dashboard');if d then SendNUIMessage({action='data',data=d})end end
local function show()local d,err=exports.szcore:AwaitCallback('szcore_admin:dashboard');if not d then return notify(err or'Nincs jogosultság.','error')end;open=true;SetNuiFocus(true,true);SendNUIMessage({action='open',data=d})end
local function close()open=false;SetNuiFocus(false,false);SendNUIMessage({action='close'})end
RegisterCommand(SzCoreAdminConfig.command,show,false);RegisterKeyMapping(SzCoreAdminConfig.command,'SzCore Admin','keyboard',SzCoreAdminConfig.key)
RegisterNUICallback('close',function(_,cb)close();cb({ok=true})end);RegisterNUICallback('refresh',function(_,cb)refresh();cb({ok=true})end)
RegisterNUICallback('action',function(d,cb)local ok,err=exports.szcore:AwaitCallback('szcore_admin:action',d.action,d);if ok then notify('Admin művelet sikeres.','success');SetTimeout(150,refresh)else notify(err or'Hiba.','error')end;cb({ok=ok,error=err})end)
RegisterNetEvent('szcore_admin:teleport',function(c)local p=PlayerPedId();SetEntityCoords(p,c.x,c.y,c.z,false,false,false,false);SetEntityHeading(p,c.w or 0.0)end)
RegisterNetEvent('szcore_admin:freeze',function(s)FreezeEntityPosition(PlayerPedId(),s==true);notify(s and'Admin lefagyasztott.'or'Feloldva.',s and'error'or'success')end)
RegisterNetEvent('szcore_admin:spectate',function(target)
    if spectating then NetworkSetInSpectatorMode(false,PlayerPedId());spectating=false;return end
    local pid=GetPlayerFromServerId(target);if pid==-1 then return notify('Célpont nincs streamelve.','error')end;local ped=GetPlayerPed(pid);NetworkSetInSpectatorMode(true,ped);spectating=true;notify('Spectate aktív. Újra kattintva kikapcsol.','info')
end)
CreateThread(function()while true do if open then Wait(SzCoreAdminConfig.dashboardRefreshMs);refresh()else Wait(1000)end end end)
exports('OpenAdmin',show)
