local RSGCore = exports['rsg-core']:GetCoreObject()

lib.callback.register('acerp-mdt:server:isPlayerWanted', function(source, cid)
    local result = MySQL.scalar.await([[
        SELECT COUNT(*) FROM mdt_reports 
        WHERE suspect = ? AND warrant = 'true'
    ]], { cid })
    return result and result > 0
end)

lib.callback.register('acerp-mdt:server:getPlayerData', function(source)
    local data = {}
    local results = MySQL.query.await('SELECT citizenid, charinfo FROM players')
    if results then
        for _, row in ipairs(results) do
            local charinfo = json.decode(row.charinfo) or {}
            table.insert(data, {
                citizenid = row.citizenid,
                firstname = charinfo.firstname or '',
                lastname = charinfo.lastname or ''
            })
        end
    end
    return data
end)

lib.callback.register('acerp-mdt:server:getReports', function(source)
    local data = {}
    local results = MySQL.query.await('SELECT id, suspect, officer, title, text, warrant, date FROM mdt_reports')
    if results then
        for _, row in ipairs(results) do
            table.insert(data, {
                sname = RSGCore.Functions.GetOfflinePlayerByCitizenId(row.suspect).PlayerData.charinfo.firstname .. ' ' .. RSGCore.Functions.GetOfflinePlayerByCitizenId(row.suspect).PlayerData.charinfo.lastname,
                oname = RSGCore.Functions.GetOfflinePlayerByCitizenId(row.officer).PlayerData.charinfo.firstname .. ' ' .. RSGCore.Functions.GetOfflinePlayerByCitizenId(row.officer).PlayerData.charinfo.lastname,
                scid = row.suspect,
                ocid = row.officer,
                title = row.title,
                text = row.text,
                warrant = row.warrant,
                date = row.date,
                id = row.id
            })
        end
    end
    return data
end)

RegisterNetEvent('acerp-mdt:server:addReport', function(sCID, oCID, title, text, warrant, date) 
    local reportAmount = MySQL.scalar.await('SELECT COUNT(*) FROM `mdt_reports`')
    local newId = reportAmount + 1
    local date = os.date('*t') 
    local months = {
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
    }
    local formattedDate = months[date.month] .. ' ' .. date.day .. ', ' .. Config.Year
    MySQL.insert.await('INSERT INTO `mdt_reports` (id, suspect, officer, title, text, warrant, date) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        newId, sCID, oCID, title, text, warrant, formattedDate
    })
end)

RegisterNetEvent('acerp-mdt:server:editReport', function(newTitle, newText, newWarrant, reportId)
    MySQL.update.await('UPDATE `mdt_reports` SET `text` = ?, `title` = ?, `warrant` = ? WHERE `id` = ?', {
        newText, newTitle, newWarrant, reportId
    })
end)

RegisterNetEvent('acerp-mdt:server:removeReport', function(id) 
    MySQL.update.await('DELETE FROM `mdt_reports` WHERE `id` = ?', { id })
end)
