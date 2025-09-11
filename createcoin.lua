local username = gurt.crumbs.get("username")
if username then
    trace.log("Welcome to GurtRug, " .. username)
else
    gurt.location.goto('/signin.html')
end

local usernameInput = gurt.select('#name')
local passwordInput = gurt.select('#symbol')
local submitBtn = gurt.select('#submit')
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

function verifySignin()
    local username = gurt.crumbs.get("username")
	local password = gurt.crumbs.get("password")

	local request_body = JSON.stringify({
    	username = username,
		password = password
	})
	local url = 'https://ahf2139b.pythonanywhere.com/gurtrugauth/login'
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
            trace.log("User is signed in")
		end
	else
		local error_data = response:text()
        trace.log("User is not signed in")
        gurt.crumbs.delete("username")
        gurt.crumbs.delete("password")
        gurt.location.goto('/signin.html')
	end
end

verifySignin()

submitBtn:on('submit', function(event)
	local name = event.data.name
	local symbol = event.data.symbol
    local username = gurt.crumbs.get("username")
	local password = gurt.crumbs.get("password")

	local request_body = JSON.stringify({
    	username = username,
		password = password,
        name = name,
        symbol = symbol
	})
	local url = 'https://ahf2139b.pythonanywhere.com/gurtrugauth/create_coin'
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
            trace.log(table.tostring(responsetwo:json()))
            gurt.location.goto('/coin.html?symbol=' .. jsonData.symbol)
		end
	else
		local error_data = responsetwo:text()
        local jsonData = responsetwo:json()
        trace.log(table.tostring(responsetwo:json()))
        showNotification(jsonData.error)
	end
end)