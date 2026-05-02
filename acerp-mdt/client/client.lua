local RSGCore = exports['rsg-core']:GetCoreObject()
local spawnedProps = {}
local animating = false

CreateThread(function()
    for _, prop in ipairs(Config.Locations) do
        local obj = CreateObjectNoOffset(Config.Prop, prop.x, prop.y, prop.z, true, true, false)
        SetEntityHeading(obj, prop.h)
        FreezeEntityPosition(obj, true)
    end
end)

CreateThread(function()
    Wait(5000)
    for _, prop in ipairs(Config.Locations) do
        exports.ox_target:addSphereZone({
            coords = vec3(prop.x, prop.y, prop.z),
            radius = 1.5,
            options = {
                {
                    label = 'Open ' .. Config.Label,
                    icon = 'fas fa-book',
					distance = 2,
                    onSelect = function()
                        TriggerEvent('acerp-mdt:client:menuMain')
                    end,
                }
            }
        })
    end
end)

local function IsLaw()
	local Player = RSGCore.Functions.GetPlayerData()
	return Player.job.type == 'leo'
end

local function IsCommand()
	local Player = RSGCore.Functions.GetPlayerData()
	return Player.job.type == 'leo' and Player.job.grade.level >= Config.CommandGrade
end

local function EditReport(report, fromProfile, fromWarrant)
	local isWarrant = report.warrant == 'true'
    local input = lib.inputDialog('Report for ' .. report.sname .. ' | ' .. report.date, {
		{type = 'input', label = 'Title', description = 'Edit the title', required = true, min = 4, max = 25, default = report.title},
		{type = 'textarea', label = 'Report Description', description = 'Write what happened here', required = true, autosize = true, default = report.text},
		{type = 'checkbox', label = 'Warrant', checked = isWarrant},
	  })
	if not input then 
		TriggerEvent('acerp-mdt:client:viewReport', report, fromProfile, fromWarrant)
	else 
	if input[3] then
		isWarrant = 'true'
	else
		isWarrant = 'false'
	end
		TriggerServerEvent('acerp-mdt:server:editReport', input[1], input[2], isWarrant, report.id)
		report.title = input[1]
		report.text = input[2]
		report.warrant = isWarrant
		TriggerEvent('acerp-mdt:client:viewReport', report, fromProfile, fromWarrant)
	end
end

local function ViewReport(report, fromProfile, fromWarrant)
	local cid = RSGCore.Functions.GetPlayerData().citizenid
	local canEdit = not IsCommand() and not cid == report.ocid
	lib.registerContext({
		id = 'mdt_reportView',
		title = '#' .. report.id .. ' ' .. report.title,
		position = 'top-right',
		options = {
			{
				title = 'Back',
				icon = 'arrow-left',
				onSelect = function()
					if not fromProfile and not fromWarrant then
						TriggerEvent('acerp-mdt:client:reports')
					elseif fromProfile then
						TriggerEvent('acerp-mdt:client:manageProfile', fromProfile.sname, fromProfile.scid)
					elseif fromWarrant then
						TriggerEvent('acerp-mdt:client:warrants')
					end
				end,
			},
			{
				title = 'Suspect: ' .. report.sname,
			},
			{
				title = 'Officer: ' .. report.oname,
			},
			{
				title = 'Warrant: ' .. report.warrant,
			},
			{
				title = 'Description',
				description = report.text,
			},
			{
				title = 'Edit',
				description = 'Edit this report',
				icon = 'pen-to-square',
				disabled = canEdit,
				onSelect = function()
					EditReport(report, fromProfile, fromWarrant)
				end,
			},
			{
				title = 'Delete',
				description = 'Delete this report',
				icon = 'trash',
				disabled = canEdit,
				onSelect = function()
					local alert = lib.alertDialog({
						header = 'Are you sure you want to delete this report?',
						centered = true,
						cancel = true
					})
					if alert == 'confirm' then
						TriggerServerEvent('acerp-mdt:server:removeReport', report.id)
						if not fromProfile and not fromWarrant then
							TriggerEvent('acerp-mdt:client:reports')
						elseif fromProfile then
							TriggerEvent('acerp-mdt:client:manageProfile', fromProfile.sname, fromProfile.scid)
						elseif fromWarrant then
							TriggerEvent('acerp-mdt:client:warrants')
						end
						lib.notify({
							title = 'Report Deleted',
							type = 'info'
						})
					else
						TriggerEvent('acerp-mdt:client:viewReport', report, fromProfile, fromWarrant)
						lib.notify({
							title = 'Canceled',
							type = 'error'
						})
					end
				end,
			},
		}
	  }) 

      lib.showContext('mdt_reportView')
end

local function WriteReport(sName, sCID)
    local input = lib.inputDialog('Report for ' .. sName, {
		{type = 'input', label = 'Title', description = 'Write a custom title for the report', required = true, min = 4, max = 25},
		{type = 'textarea', label = 'Report Description', description = 'Write what happened here', required = true, autosize = true},
		{type = 'checkbox', label = 'Warrant'},
	  })
	  if not input then TriggerEvent('acerp-mdt:client:manageProfile', sName, sCID) return end
	  local oCID = RSGCore.Functions.GetPlayerData().citizenid 
	  if input[3] then
		isWarrant = 'true'
	  else
		isWarrant = 'false'
	  end
	  TriggerServerEvent('acerp-mdt:server:addReport', sCID, oCID, input[1], input[2], isWarrant)
	  TriggerEvent('acerp-mdt:client:manageProfile', sName, sCID)
	  lib.notify({
		title = 'Report Written',
		type = 'success'
	})
end

local function ReportsSpecific(searchID, searchCID, fromProfile)
    local result = lib.callback.await('acerp-mdt:server:getReports', false)
    if not result then
        lib.notify({ title = 'MDT', description = 'Failed to load reports.', type = 'error' })
		TriggerEvent('acerp-mdt:client:menuMain')
        return
    end
	
	local options = {
		{
			title = 'Back',
			icon = 'arrow-left',
			onSelect = function()
				if not fromProfile then
					TriggerEvent('acerp-mdt:client:reports')
				else
					TriggerEvent('acerp-mdt:client:manageProfile', fromProfile.sname, fromProfile.scid)
				end
			end,
		},
	}
    for _, report in ipairs(result) do
		local idStr  = tostring(report.id):lower()
		local cidStr = tostring(report.scid):lower()
		local idMatch  = searchID  == '' or idStr:find(searchID, 1, true)
		local cidMatch = searchCID == '' or cidStr:find(searchCID, 1, true)
		if idMatch and cidMatch then
			local reportTitle = '#' .. report.id .. ' ' .. report.title
			options[#options + 1] = {
				title = reportTitle,
				description = 'Date Issued: ' .. report.date .. '\nSuspect: ' .. report.sname .. '\nOfficer: ' .. report.oname .. '\nWarrant: ' .. report.warrant,
				disabled = false,
				onSelect = function()
					ViewReport(report, fromProfile, false)
				end,
			}
		end
    end
    if #options == 0 then
        lib.notify({ title = 'MDT', description = 'No reports found matching your search.', type = 'error' })
		TriggerEvent('acerp-mdt:client:menuMain')
        return
    end
    lib.registerContext({
        id = 'mdt_reports',
        title = 'County Reports',
        options = options
    })

    lib.showContext('mdt_reports')
end

local function SearchReport()
    local input = lib.inputDialog('Search for Report', {
        {type = 'input', label = 'Report ID', description = 'Optional'},
        {type = 'input', label = 'Suspects CID', description = 'Optional'},
    })
    if not input then TriggerEvent('acerp-mdt:client:reports') return end
    local searchID  = input[1] and tostring(input[1]):lower() or ''
    local searchCID = input[2] and tostring(input[2]):lower() or ''
    if searchID == '' and searchCID == '' then
        lib.notify({ title = 'MDT', description = 'Please enter at least one search field.', type = 'error' })
		TriggerEvent('acerp-mdt:client:menuMain')
        return
    end

    ReportsSpecific(searchID, searchCID, false)
end

local function ManageProfile(sName, sCID)
	local isWanted = lib.callback.await('acerp-mdt:server:isPlayerWanted', false, sCID)
	if isWanted then
		wantedStatus = 'Wanted'
	else
		wantedStatus = 'Not Wanted'
	end
	lib.registerContext({
		id = 'mdt_profile',
		title = sName,
		position = 'top-right',
		options = {
			{
				title = 'Back',
				icon = 'arrow-left',
				onSelect = function()
					TriggerEvent('acerp-mdt:client:profiles')
				end,
			},
			{
				title = 'CID: ' .. sCID,
			},
			{
				title = wantedStatus,
				icon = 'user-ninja',
			},
			{
				title = 'Reports',
				description = 'View this profiles reports',
				icon = 'clipboard',
				onSelect = function()
					local searchCID = sCID and tostring(sCID):lower() or ''
					local pData = {
						sname = sName,
						scid = sCID,
					}
					ReportsSpecific('', searchCID, pData)
				end,
			},
			{
				title = 'Write Report',
				description = 'Write a report for this profile',
				icon = 'file-circle-plus',
				onSelect = function()
					WriteReport(sName, sCID)
				end,
			},
		}
	  }) 

      lib.showContext('mdt_profile')
end

local function ProfilesSpecific(searchFirst, searchLast, searchCid)
    local result = lib.callback.await('acerp-mdt:server:getPlayerData', false)
    if not result then
        lib.notify({ title = 'MDT', description = 'Failed to load profiles.', type = 'error' })
		TriggerEvent('acerp-mdt:client:menuMain')
        return
    end

	local options = {
		{
			title = 'Back',
			icon = 'arrow-left',
			onSelect = function()
				TriggerEvent('acerp-mdt:client:profiles')
			end,
		},
	}
    for _, profile in ipairs(result) do
        local firstName = profile.firstname:lower()
        local lastName  = profile.lastname:lower()
        local cid       = profile.citizenid:lower()
        local firstMatch = searchFirst == '' or firstName:find(searchFirst, 1, true)
        local lastMatch  = searchLast  == '' or lastName:find(searchLast, 1, true)
        local cidMatch   = searchCid   == '' or cid:find(searchCid, 1, true)

        if firstMatch and lastMatch and cidMatch then
            local profileName = profile.firstname .. ' ' .. profile.lastname
            options[#options + 1] = {
                title = profileName,
                description = 'CID: ' .. profile.citizenid .. ' | Click to Manage',
                disabled = false,
                onSelect = function()
                    ManageProfile(profileName, profile.citizenid)
                end,
            }
        end
    end

    if #options == 0 then
        lib.notify({ title = 'MDT', description = 'No profiles found matching your search.', type = 'error' })
		TriggerEvent('acerp-mdt:client:menuMain')
        return
    end

    lib.registerContext({
        id = 'mdt_profiles',
        title = Config.ProfilesLabel,
        options = options
    })

    lib.showContext('mdt_profiles')
end

local function SearchProfile()
    local input = lib.inputDialog('Search for Profile', {
        {type = 'input', label = 'First Name', description = 'Optional'},
        {type = 'input', label = 'Last Name', description = 'Optional'},
        {type = 'input', label = 'CID', description = 'Optional'},
    })
    if not input then TriggerEvent('acerp-mdt:client:profiles') return end

    local searchFirst = input[1] and input[1]:lower() or ''
    local searchLast  = input[2] and input[2]:lower() or ''
    local searchCid   = input[3] and input[3]:lower() or ''

    if searchFirst == '' and searchLast == '' and searchCid == '' then
        lib.notify({ title = 'MDT', description = 'Please enter at least one search field.', type = 'error' })
		TriggerEvent('acerp-mdt:client:menuMain')
        return
    end

    ProfilesSpecific(searchFirst, searchLast, searchCid)
end

local function Profiles()
    local result = lib.callback.await('acerp-mdt:server:getPlayerData', false)

    if not result then
        lib.notify({ title = 'MDT', description = 'Failed to load profiles.', type = 'error' })
		TriggerEvent('acerp-mdt:client:menuMain')
        return
    end

	local options = {
		{
			title = 'Back',
			icon = 'arrow-left',
			onSelect = function()
				TriggerEvent('acerp-mdt:client:menuMain')
			end,
		},
		{
			title = 'Search',
			icon = 'magnifying-glass',
			onSelect = function()
				SearchProfile()
			end,
		},
	}
    for _, profile in ipairs(result) do
        local profileName = profile.firstname .. ' ' .. profile.lastname
        options[#options + 1] = {
            title = profileName,
            description = 'CID: ' .. profile.citizenid .. ' | Click to Manage',
            disabled = false,
            onSelect = function()
                ManageProfile(profileName, profile.citizenid)
            end,
        }
    end

    lib.registerContext({
        id = 'mdt_profiles',
        title = 'County Profiles',
        options = options
    })

    lib.showContext('mdt_profiles')
end

local function Warrants()
    local result = lib.callback.await('acerp-mdt:server:getReports', false)

    if not result then
        lib.notify({ title = 'MDT', description = 'Failed to load warrants.', type = 'error' })
		TriggerEvent('acerp-mdt:client:menuMain')
        return
    end

	local options = {
		{
			title = 'Back',
			icon = 'arrow-left',
			onSelect = function()
				TriggerEvent('acerp-mdt:client:menuMain')
			end,
		}
	}
    for _, report in ipairs(result) do
		local warrantStr  = tostring(report.warrant):lower()
		local isWarrant = warrantStr:find('true', 1, true)

		if isWarrant then
			local reportTitle = '#' .. report.id .. ' 🔴 ' .. report.sname
			options[#options + 1] = {
				title = reportTitle,
				description = 'Title: ' .. report.title .. '\nDate Issued: ' .. report.date .. '\nOfficer: ' .. report.oname .. '\nWarrant: ' .. report.warrant,
				disabled = false,
				onSelect = function()
					ViewReport(report, false, true)
				end,
			}
		end
    end

    if #options == 0 then
        lib.notify({ title = 'MDT', description = 'No reports found matching your search.', type = 'error' })
		TriggerEvent('acerp-mdt:client:menuMain')
        return
    end

    lib.registerContext({
        id = 'mdt_warrants',
        title = Config.WarrantsLabel,
        options = options
    })

    lib.showContext('mdt_warrants')
end

local function Reports()
    local result = lib.callback.await('acerp-mdt:server:getReports', false)

    if not result then
        lib.notify({ title = 'MDT', description = 'Failed to load reports.', type = 'error' })
		TriggerEvent('acerp-mdt:client:menuMain')
        return
    end

	local options = {
		{
			title = 'Back',
			icon = 'arrow-left',
			onSelect = function()
				TriggerEvent('acerp-mdt:client:menuMain')
			end,
		},
		{
			title = 'Search',
			icon = 'magnifying-glass',
			onSelect = function()
				SearchReport()
			end,
		},
	}
    for _, report in ipairs(result) do
		if report.warrant == 'true' then
			reportTitle = '#' .. report.id .. ' 🔴 ' .. report.title
		else
			reportTitle = '#' .. report.id .. ' ' .. report.title
		end
        options[#options + 1] = {
            title = reportTitle,
            description = 'Date Issued: ' .. report.date .. '\nSuspect: ' .. report.sname .. '\nOfficer: ' .. report.oname .. '\nWarrant: ' .. report.warrant,
            disabled = false,
            onSelect = function()
				ViewReport(report, false, false)
            end,
        }
    end

    lib.registerContext({
        id = 'mdt_reports',
        title = Config.ReportsLabel,
        options = options
    })

    lib.showContext('mdt_reports')
end

RegisterNetEvent('acerp-mdt:client:viewReport', function(report, fromProfile, fromWarrant)
	ViewReport(report, fromProfile, fromWarrant)
end)

RegisterNetEvent('acerp-mdt:client:reportsSpecific', function(searchID, searchCID, fromProfile)
	ReportsSpecific(searchID, searchCID, fromProfile)
end)

RegisterNetEvent('acerp-mdt:client:reports', function()
	Reports()
end)

RegisterNetEvent('acerp-mdt:client:warrants', function()
	Warrants()
end)

RegisterNetEvent('acerp-mdt:client:profiles', function(report)
	Profiles()
end)

RegisterNetEvent('acerp-mdt:client:manageProfile', function(sName, sCID)
	ManageProfile(sName, sCID)
end)

RegisterNetEvent('acerp-mdt:client:menuMain', function()
	if IsLaw() then
		local Player = RSGCore.Functions.GetPlayerData()
		lib.registerContext({
			id = 'mdt_main',
			title = 'County Records',
			position = 'top-right',
			options = {
				{
					title = '' .. Player.job.grade.name .. ' ' .. Player.charinfo.lastname,
				},
				{
					title = 'Profiles',
					description = 'All profiles in the records',
					icon = 'people-group',
					onSelect = function()
						Profiles()
					end,
				},
				{
					title = 'Reports',
					description = 'All reports in the records',
					icon = 'clipboard',
					onSelect = function()
						Reports()
					end,
				},
				{
					title = 'Active Warrants',
					description = 'Search active warrants in the records',
					icon = 'user-ninja',
					onSelect = function()
						Warrants()
					end,
				},
			}
		}) 

		lib.showContext('mdt_main')
	else
		lib.notify({
			title = 'Not Law',
			type = 'error'
		})
	end
end)

RegisterCommand(Config.Command, function()
	if Config.UseCommand then
		TriggerEvent('acerp-mdt:client:menuMain')
	end
end)