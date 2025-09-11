if gurt.crumbs.get("username") then
	gurt.location.goto("/")
end

trace.log("Signin page loaded")

local usernameInput = gurt.select('#username')
local passwordInput = gurt.select('#password')
local submitBtn = gurt.select('#submit')
local submitBtn2 = gurt.select('#submit2')
local notificationDiv = gurt.select('#notification')

function showNotification(message)
    local notificationText = gurt.create('div')
    notificationText.text = message
    local oldNotification = gurt.select('#notification').firstChild
    if oldNotification then
        oldNotification:remove()
    end
    notificationDiv:append(notificationText)
end

function validateForm(username, password)
	if not username or username == '' then
        showNotification("Username cannot be empty.")
		return false
	end
	
	if not password or password == '' then
        showNotification("Password cannot be empty.")
		return false
	end

	
	if string.len(password) < 6 then
        showNotification("Password must be at least 6 characters long.")
		return false
	end
	
	return true
end

submitBtn:on('submit', function(event)
	local username = event.data.username
	local password = event.data.password

	local request_body = JSON.stringify({
    	username = username,
		password = password
	})
	local url = 'https://ahf2139b.pythonanywhere.com/gurtrugauth/login'
	local headers = {
		['Content-Type'] = 'application/json'
	}

	local responsetwo = fetch(url, {
		method = 'POST',
		headers = headers,
		body = request_body
	})
	
	if responsetwo:ok() then
		local jsonData = responsetwo:json()
		if jsonData then

			gurt.crumbs.set({
				name = "username",
				value = username
			})
			gurt.crumbs.set({
				name = "password",
				value = password
			})

			gurt.location.goto("/")
		end
	else
		local error_data = responsetwo:text()
        local jsonData = responsetwo:json()
        trace.log(table.tostring(responsetwo:json()))
        showNotification(jsonData.error)
	end
end)

submitBtn2:on('submit', function(event)
	local username = event.data.username
	local password = event.data.password
	
	if not validateForm(username, password) then
		return
	end

	local request_body = JSON.stringify({
    	username = username,
		password = password
	})
	
	local url = 'https://ahf2139b.pythonanywhere.com/gurtrugauth/register'
	local headers = {
		['Content-Type'] = 'application/json'
	}

	local response = fetch(url, {
		method = 'POST',
		headers = headers,
		body = request_body
	})
	
	if response:ok() then
		local jsonData = response:json()
		if jsonData then
			gurt.crumbs.set({
                name = "username",
				value = username
			})
			gurt.crumbs.set({
                name = "password",
				value = password
			})
			gurt.location.goto("/")
        end
    else
        local error_data = response:text()
        local jsonData = response:json()
        trace.log(table.tostring(response:json()))
        showNotification(jsonData.error)
	end
end)