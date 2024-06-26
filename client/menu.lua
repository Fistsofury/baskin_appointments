--[[ Credits to Fistofury for the general menu code formatting ]]
local CreatedNpcs = {}

CreateThread(function()
    local PromptGroup = BccUtils.Prompts:SetupPromptGroup() -- Setup Prompt Group
    local firstPrompt = PromptGroup:RegisterPrompt(_U("schedulePrompt"), 0x760A9C6F, 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" }) -- Register your first prompt

    for k,v in pairs(Config.Businesses) do
		local coords = GetEntityCoords(PlayerPedId())
		if v.npc then
			local distance =  #(coords - v.location)
			if distance < 50 then
				local ped = BccUtils.Ped:Create(v.model, v.location.x, v.location.y, v.location.z, -1, 'world', false)
				CreatedNpcs[#CreatedNpcs + 1] = ped
				ped:Freeze()
				ped:SetHeading(v.heading)
				ped:Invincible() 
			end  
		end
    end
    while true do
        Wait(1)
        local inMenu = false -- Define and initialize inMenu here
        local playerPed = PlayerPedId() -- Use local variable for PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local sleep = true
        for _, business in pairs(Config.Businesses) do
            local dist = #(playerCoords - business.location)
            if dist < 1.5 then
                sleep = false
                PromptGroup:ShowGroup(business.name)
                if firstPrompt:HasCompleted() then
                    inMenu = true
                    --TaskStandStill(playerPed, -1) -- Assuming OpenMenu() requires the key as an argument
                end
            end
        end

        if inMenu then
			OpenMainMenu()
			if sleep then
                Wait(500)
            end
        end
    end
end)

local mainMenu, mainPage, viewPage, schedulePage, appointmentPage, checkAppointmentPage

function OpenMainMenu()
	mainPage 			 = nil
	viewPage 			 = nil
	schedulePage 	     = nil
	checkAppointmentPage = nil
	appointmentPage 	 = nil

	for _, business in pairs(Config.Businesses) do
		local playerPed = PlayerPedId() -- Use local variable for PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
		local dist = #(playerCoords - business.location)
		if not mainMenu then
			mainMenu = FeatherMenu:RegisterMenu('baskin_appointment:mainMenu', {
				top = '10%',
				left = '2%',
				['720width'] = '600px',
				['1080width'] = '700px',
				['2kwidth'] = '800px',
				['4kwidth'] = '1000px',
				style = {
					--[[ ['background-size'] = 'cover',  
					['background-repeat'] = 'no-repeat',
					['background-position'] = 'center',
					['padding'] = '10px 20px',
					['margin-top'] = '5px', ]]
				},
				contentslot = {
					style = {
						['max-height'] = '550px',  -- Fixed maximum height
					} -- Fixed maximum height
				},
				draggable = false,
				canclose = true
			})
		end
		
		if dist < 1.5 then
			if not mainPage then
				mainPage = mainMenu:RegisterPage('mainmenu:first:page')
				mainPage:RegisterElement("header", {
					value = business.name,
					slot = "header",
					style = {}
				})
				mainPage:RegisterElement('subheader', {
					value = _U("optionText"),
					slot = "header",
					style = {}
				})
				mainPage:RegisterElement('line', {
					slot = "header",
					style = {}
				})
				mainPage:RegisterElement('button', {
					label = _U("scheduleButton"),
					style = {
						-- ['background-image'] = 'none',
						-- ['background-color'] = '#E8E8E8',
						-- ['color'] = 'black',
						-- ['border-radius'] = '6px'
					},
					sound = {
						action = "SELECT",
						soundset = "RDRO_Character_Creator_Sounds"
					},
				}, function()
					schedulePage:RouteTo()
				end)
				mainPage:RegisterElement('bottomline', {
					slot = "footer",
					style = {
					}
				})
				mainPage:RegisterElement('button', {
					label = _U("closeButton"),
					slot = "footer",
					style = {
						-- ['background-image'] = 'none',
						-- ['background-color'] = '#E8E8E8',
						-- ['color'] = 'black',
						-- ['border-radius'] = '6px'
					},
					sound = {
						action = "SELECT",
						soundset = "RDRO_Character_Creator_Sounds"
					},
				}, function()
					mainMenu:Close({
						-- sound = {
						--     action = "SELECT",
						--     soundset = "RDRO_Character_Creator_Sounds"
						-- }
					})
				end)
			end
		
			if not schedulePage then
				schedulePage = mainMenu:RegisterPage('mainmenu:appointment:page')
			
				schedulePage:RegisterElement('header', {
					value = business.name,
					slot = "header",
					style = {}
				})
			
				schedulePage:RegisterElement('subheader', {
					value = _U('scheduleText'),
					slot = "header",
					style = {}
				})
				schedulePage:RegisterElement('line', {
					slot = "header",
					style = {}
				})
				local charname = ''
				schedulePage:RegisterElement('input', {
					label = _U('nameLabel'),
					placeholder = _U('namePlace'),
					persist = false,
					style = {
						['border-color'] = "#513e23"
						-- ['background-image'] = 'none',
						-- ['background-color'] = '#E8E8E8',
						-- ['color'] = 'black',
						-- ['border-radius'] = '6px'
					}
				}, function(data)
					-- This gets triggered whenever the input value change
					charname = data.value
				end)
				local telegram = ''
				schedulePage:RegisterElement('input', {
					label = _U('teleLabel'),
					placeholder = _U('telePlace'),
					persist = false,
					style = {
						-- ['background-image'] = 'none',
						-- ['background-color'] = '#E8E8E8',
						-- ['color'] = 'black',
						-- ['border-radius'] = '6px'
					}
				}, function(data)
					-- This gets triggered whenever the input value changes
					telegram = data.value
				end)
				schedulePage:RegisterElement('subheader', {
					value = _U('reasonLabel'),
					slot = "content",
					style = {}
				})
				local reason = ''
				schedulePage:RegisterElement('textarea', {
					--label = _U('reasonlabel'),
					placeholder = _U('reasonPlace'),
					rows = "4",
					--cols = "33",
					resize = false,
					persist = false,
					style = {
						-- ['background-image'] = 'none',
						-- ['background-color'] = '#E8E8E8',
						-- ['color'] = 'black',
						-- ['border-radius'] = '6px'
					}
				}, function(data)
					-- This gets triggered whenever the input value changes
					reason = data.value
				end)
				schedulePage:RegisterElement('line', {
					slot = "footer",
					-- style = {}
				})
				schedulePage:RegisterElement('button', {
					label = _U('submitButton'),
					slot = "footer",
					style = {},
					sound = {
						 action = "SELECT",
						 soundset = "RDRO_Character_Creator_Sounds"
					},
				}, function()
						--local desc = "**Business Name:** \n "..name.."\n\n **Name:** \n"..charname.."\n\n **Telegram Number:** \n"..telegram.."\n\n **Reason:** \n"..reason
						--VORPcore.AddWebhook("Business Appointment",webhook,desc)
						local appointmentData = { job = business.job, charname = charname, reason = reason, telegram = telegram, created_at = timestamp}
						TriggerServerEvent("baskin_appointments:InsertCreatedAppointmentIntoDB", appointmentData)
						VORPcore.NotifyObjective(_U("scheduleNotify")..business.name,5000)
						mainPage:RouteTo()
				end)
				schedulePage:RegisterElement('button', {
					label = _U("backButton"),
					slot = "footer",
					style = {},
					sound = {
						action = "SELECT",
						soundset = "RDRO_Character_Creator_Sounds"
					},
				}, function()
					mainPage:RouteTo()
				end)
				schedulePage:RegisterElement('bottomline', {
					slot = "footer",
					-- style = {}
				})
			end
		
			if not viewPage then
				viewPage = mainMenu:RegisterPage('mainmenu:view:page')
				if LocalPlayer.state.Character.Job == business.job and dist < 1.5 then
					mainPage:RegisterElement('button', {
						label = _U('viewButton'),
						style = {
						},
						sound = {
							action = "SELECT",
							soundset = "RDRO_Character_Creator_Sounds"
						},
					}, function()
						TriggerServerEvent('baskin_appointments:GetAllAppointments', job)
					end)
				end
			end
	
			if not checkAppointmentPage then
				checkAppointmentPage = mainMenu:RegisterPage('mainmenu:checkappoint:page')
				checkAppointmentPage:RegisterElement('header', {
					value = business.name,
					slot = "header",
					style = {}
				})
				checkAppointmentPage:RegisterElement('subheader', {
					value = _U('pickText'),
					slot = "header",
					style = {}
				})
				checkAppointmentPage:RegisterElement('bottomline', {
					slot = "footer",
					-- style = {}
				})
				checkAppointmentPage:RegisterElement('button', {
					label = _U('backButton'),
					slot = "footer",
					style = {
						-- ['background-image'] = 'none',
						-- ['background-color'] = '#E8E8E8',
						-- ['color'] = 'black',
						-- ['border-radius'] = '6px'
					},
					sound = {
						action = "SELECT",
						soundset = "RDRO_Character_Creator_Sounds"
					},
				}, function()
					mainPage:RouteTo()
				end)
			end
			mainMenu:Open({
				startupPage = mainPage,
				sound = {
					action = "SELECT",
					soundset = "RDRO_Character_Creator_Sounds"
				}
			})
		end
	end
end
	
RegisterNetEvent('baskin_appointments:DisplayAllAppointments', function (appointments)
	checkAppointmentPage = nil
	OpenMainMenu(true)
	for _, appointment in ipairs(appointments) do
		local label = appointment.charname.." | "..appointment.created_at
		checkAppointmentPage:RegisterElement('button', {
			label = label,
			style = {},
			sound = {
				action = "SELECT",
				soundset = "RDRO_Character_Creator_Sounds"
			},
		}, function()
			CheckAppointment(appointment)
		end)

		checkAppointmentPage:RouteTo()
	end
end)
	
	
function CheckAppointment(appointment)
	appointmentPage = mainMenu:RegisterPage('viewmenu:appointment:page')
	appointmentPage:RegisterElement('header', {
		value = appointment.charname,
		slot = "header",
		style = {}
	})
	appointmentPage:RegisterElement('subheader', {
		value = appointment.created_at,
		slot = "header",
		style = {}
	})
	appointmentPage:RegisterElement('bottomline', {
		slot = "header",
		style = {}
	})
	appointmentPage:RegisterElement('subheader', {
		value = _U('telegramText'),
		slot = "content",
		style = {}
	})
	TextDisplay = appointmentPage:RegisterElement('textdisplay', {
		value = appointment.telegram,
		style = {}
	})
	appointmentPage:RegisterElement('subheader', {
		value = _U("reasonText"),
		slot = "content",
		style = {}
	})
	TextDisplay = appointmentPage:RegisterElement('textdisplay', {
		value = appointment.reason,
		style = {
			['padding'] = '10px 20px',
			['max-height'] = '200px',  -- Fixed maximum height
			['overflow-y'] = 'auto',   -- Allows vertical scrolling
			['overflow-x'] = 'hidden', -- Prevents horizontal scrolling
		}
	})
	appointmentPage:RegisterElement('line', {
		slot = "content",
		style = {}
	})
	appointmentPage:RegisterElement('button', {
		label = _U('backButton'),
		slot = "footer",
		style = {
			-- ['background-image'] = 'none',
			-- ['background-color'] = '#E8E8E8',
			-- ['color'] = 'black',
			-- ['border-radius'] = '6px'
		},
		sound = {
			action = "SELECT",
			soundset = "RDRO_Character_Creator_Sounds"
		},
	}, function()
		checkAppointmentPage:RouteTo()
	end)
	appointmentPage:RegisterElement('button', {
		label = _U('deleteButton'),
		slot = "footer",
		style = {
			['color'] = '#ff454b',
		},
		-- sound = {
		--     action = "SELECT",
		--     soundset = "RDRO_Character_Creator_Sounds"
		-- },
	}, function()
		TriggerServerEvent('baskin_appointments:DeleteAppointment', appointment.id)
		VORPcore.NotifyObjective(_U('deleteNotify'),5000)
		mainPage:RouteTo()
		-- This gets triggered whenever the button is clicked
	end)
	appointmentPage:RouteTo()
end

--[[
    --Sacred Comment
    8========D
]]