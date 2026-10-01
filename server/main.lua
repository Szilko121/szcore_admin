local function registerSzCoreCallback(name, fn)
    CreateThread(function()
        local deadline = GetGameTimer() + 15000

        while GetGameTimer() < deadline do
            if GetResourceState('szcore') == 'started' then
                local ok, success, err = pcall(function()
                    return registerSzCoreCallback(name, fn)
                end)

                if ok and success ~= false then
                    return
                end

                if ok and success == false then
                    print(('[%s] SzCore callback registration rejected: %s (%s)'):format(
                        GetCurrentResourceName(),
                        tostring(name),
                        tostring(err)
                    ))
                    return
                end
            end

            Wait(100)
        end

        print(('[%s] SzCore callback registration timed out: %s'):format(
            GetCurrentResourceName(),
            tostring(name)
        ))
    end)
end

local rate={}
local function perm(src,p)return exports.szcore:HasPermission(src,p)end
local function player(src)return exports.szcore:GetPlayer(tonumber(src))end
local function notify(src,t,typ)if src==0 then print('[SzCoreAdmin] '..t)else TriggerClientEvent('szcore_ui:notify',src,{description=t,type=typ or'info'})end end
local function allow(src,key,ms)local n=GetGameTimer();rate[src]=rate[src]or{};local p=rate[src][key]or 0;if n-p<ms then return false end;rate[src][key]=n;return true end
local function dashboard(src)
    if not perm(src,'admin.view')then return nil,'no_permission'end
    local list={}
    for _,sid in ipairs(exports.szcore:GetPlayerSources())do local p=player(sid);if p then list[#list+1]={source=sid,name=p.PlayerData.name,citizenid=p.PlayerData.citizenid,ping=GetPlayerPing(sid),job=p.PlayerData.job,gang=p.PlayerData.gang,money=p.PlayerData.money,dead=p.PlayerData.metadata.dead==true}end end
    table.sort(list,function(a,b)return a.source<b.source end)
    local bans=MySQL.query.await("SELECT id,identifier,reason,banned_by,expires_at,created_at FROM szcore_bans ORDER BY id DESC LIMIT 100")or{}
    return{players=list,metrics=exports.szcore:GetMetrics(),bans=bans,server={players=#list,max=GetConvarInt('sv_maxclients',48),uptime=os.time()}}
end
local function action(src,a,d)
    if not perm(src,'admin.view')then return false,'no_permission'end;if not allow(src,'action',100)then return false,'rate_limited'end;d=type(d)=='table'and d or{}
    local target=tonumber(d.target);local q=target and player(target)
    if a=='revive'then if not perm(src,'admin.revive')then return false,'no_permission'end;return exports.szcore_death:Revive(target,200)
    elseif a=='heal'then if not perm(src,'admin.revive')then return false,'no_permission'end;return exports.szcore_death:Heal(target,'full')
    elseif a=='goto'then if not perm(src,'admin.goto')then return false,'no_permission'end;if not q then return false,'player_not_found'end;local ped=GetPlayerPed(target);local c=GetEntityCoords(ped);TriggerClientEvent('szcore_admin:teleport',src,{x=c.x,y=c.y,z=c.z,w=GetEntityHeading(ped)});return true
    elseif a=='bring'then if not perm(src,'admin.bring')then return false,'no_permission'end;if not q then return false,'player_not_found'end;local ped=GetPlayerPed(src);local c=GetEntityCoords(ped);TriggerClientEvent('szcore_admin:teleport',target,{x=c.x,y=c.y,z=c.z,w=GetEntityHeading(ped)});return true
    elseif a=='freeze'then if not perm(src,'admin.freeze')then return false,'no_permission'end;if not q then return false,'player_not_found'end;TriggerClientEvent('szcore_admin:freeze',target,d.state==true);return true
    elseif a=='spectate'then if not perm(src,'admin.spectate')then return false,'no_permission'end;if not q then return false,'player_not_found'end;TriggerClientEvent('szcore_admin:spectate',src,target);return true
    elseif a=='kick'then if not perm(src,'admin.kick')or not q then return false,'no_permission'end;DropPlayer(target,tostring(d.reason or'Admin kick'):sub(1,SzCoreAdminConfig.maxBanReason));return true
    elseif a=='ban'then
        if not perm(src,'admin.ban')or not q then return false,'no_permission'end;local id=exports.szcore:GetIdentifier(target);local hours=math.max(0,math.min(tonumber(d.hours)or 0,87600));local ex=hours>0 and os.date('!%Y-%m-%d %H:%M:%S',os.time()+hours*3600)or nil
        MySQL.insert.await('INSERT INTO szcore_bans(identifier,reason,banned_by,expires_at) VALUES (?,?,?,?)',{id,tostring(d.reason or'Admin ban'):sub(1,SzCoreAdminConfig.maxBanReason),tostring(src),ex});exports.szcore:Audit('admin.ban',src,id,{hours=hours,reason=d.reason});DropPlayer(target,d.reason or'Banned');return true
    elseif a=='unban'then if not perm(src,'admin.ban')then return false,'no_permission'end;return MySQL.update.await('DELETE FROM szcore_bans WHERE id=?',{tonumber(d.id)})>0
    elseif a=='setjob'then if not perm(src,'admin.job')then return false,'no_permission'end;return exports.szcore:SetJob(target,tostring(d.name),tonumber(d.grade)or 0,d.duty~=false)
    elseif a=='setgang'then if not perm(src,'admin.job')then return false,'no_permission'end;return exports.szcore:SetGang(target,tostring(d.name),tonumber(d.grade)or 0)
    elseif a=='money'then if not perm(src,'admin.money')then return false,'no_permission'end;local n=math.floor(tonumber(d.amount)or 0);if d.mode=='set'then return exports.szcore:SetMoney(target,d.account,n,'admin:'..src)else return exports.szcore:AddMoney(target,d.account,n,'admin:'..src)end
    elseif a=='item'then
        if not perm(src,'admin.item')or not q then return false,'no_permission'end;local inv='player:'..q.PlayerData.citizenid;local ok,err=exports.szcore_inventory:AddItem(inv,tostring(d.item),math.max(1,math.floor(tonumber(d.amount)or 1)));if ok then TriggerClientEvent('szcore_inventory:refresh',target)end;return ok,err
    elseif a=='clearinv'then
        if not perm(src,'admin.item')or not q then return false,'no_permission'end;local inv=exports.szcore_inventory:GetPlayerInventory(target);if not inv then return false,'inventory_missing'end
        for slot,e in pairs(inv.items or{})do exports.szcore_inventory:RemoveItemBySlot('player:'..q.PlayerData.citizenid,slot,e.amount)end;exports.szcore_inventory:FlushInventory('player:'..q.PlayerData.citizenid);TriggerClientEvent('szcore_inventory:refresh',target);return true
    end
    return false,'invalid_action'
end
registerSzCoreCallback('szcore_admin:dashboard',dashboard);registerSzCoreCallback('szcore_admin:action',action)
exports.szcore:RegisterCommand({name='szcoreinfo',permission='admin.view',arguments={}},function(src)local m=exports.szcore:GetMetrics();notify(src,('Players: %d | Saves: %d | Batch: %d | Callbacks: %d | Events: %d'):format(exports.szcore:GetPlayerCount(),m.saves or 0,m.batchSaves or 0,m.callbacks or 0,m.secureEvents or 0))end)
exports.szcore:RegisterCommand({name='setjob',permission='admin.job',arguments={{name='player',type='player'},{name='job',type='job'},{name='grade',type='number'}}},function(src,a)local ok,err=exports.szcore:SetJob(a.player,a.job,a.grade,true);notify(src,ok and'Job módosítva.'or tostring(err),ok and'success'or'error')end)
exports.szcore:RegisterCommand({name='setgang',permission='admin.job',arguments={{name='player',type='player'},{name='gang',type='gang'},{name='grade',type='number'}}},function(src,a)local ok,err=exports.szcore:SetGang(a.player,a.gang,a.grade);notify(src,ok and'Gang módosítva.'or tostring(err),ok and'success'or'error')end)
exports.szcore:RegisterCommand({name='givemoney',permission='admin.money',arguments={{name='player',type='player'},{name='account',type='string'},{name='amount',type='number'}}},function(src,a)local ok,err=exports.szcore:AddMoney(a.player,a.account,a.amount,'admin:'..src);notify(src,ok and'Pénz hozzáadva.'or tostring(err),ok and'success'or'error')end)
exports.szcore:RegisterCommand({name='setmoney',permission='admin.money',arguments={{name='player',type='player'},{name='account',type='string'},{name='amount',type='number'}}},function(src,a)local ok,err=exports.szcore:SetMoney(a.player,a.account,a.amount,'admin:'..src);notify(src,ok and'Egyenleg beállítva.'or tostring(err),ok and'success'or'error')end)
exports.szcore:RegisterCommand({name='giveitem',permission='admin.item',arguments={{name='player',type='player'},{name='item',type='string'},{name='amount',type='number',required=false}}},function(src,a)local q=exports.szcore:GetPlayer(a.player);if not q then return end;local ok,err=exports.szcore_inventory:AddItem('player:'..q.PlayerData.citizenid,a.item,math.max(1,a.amount or 1));if ok then TriggerClientEvent('szcore_inventory:refresh',a.player)end;notify(src,ok and'Item hozzáadva.'or tostring(err),ok and'success'or'error')end)
exports.szcore:RegisterCommand({name='revive',permission='admin.revive',arguments={{name='player',type='player'}}},function(src,a)exports.szcore_death:Revive(a.player,200);notify(src,'Játékos újraélesztve.','success')end)
exports.szcore:RegisterCommand({name='heal',permission='admin.revive',arguments={{name='player',type='player'}}},function(src,a)exports.szcore_death:Heal(a.player,'full');notify(src,'Játékos meggyógyítva.','success')end)
exports.szcore:RegisterCommand({name='kick',permission='admin.kick',arguments={{name='player',type='player'},{name='reason',type='string',rest=true,required=false}}},function(src,a)DropPlayer(a.player,a.reason or'Admin kick')end)
AddEventHandler('playerDropped',function()rate[source]=nil end)
