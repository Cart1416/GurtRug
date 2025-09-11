local welcometext = gurt.select("#welcometext")
local username = gurt.crumbs.get("username")
if username then
    trace.log("Welcome to GurtRug, " .. username)
    welcometext.text = "Welcome to GurtRug, " .. username
else
    gurt.location.goto('/signin.html')
end

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

-- add all of the buttons for each coin
local url = 'https://ahf2139b.pythonanywhere.com/gurtrugauth/market'
local response = fetch(url)
if response:ok() then
    local jsonData = response:json()
    if jsonData then
        local marketDiv = gurt.select("#market")
        for k, v in pairs(jsonData.names) do
            trace.log(k .. ", " .. v)
        end
        for i, coin in ipairs(jsonData.names) do
            local coinButton = gurt.create("button")
            coinButton.text = coin .. " (" .. jsonData.symbols[i] .. ") - $" .. jsonData.prices[i]
            coinButton.style = "bg-[#131516] text-white px-4 py-2 rounded hover:bg-[#1e2122] transition m-2"
            coinButton:on('click', function()
                gurt.location.goto('/coin.html?symbol=' .. jsonData.symbols[i])
            end)
            marketDiv:append(coinButton)
        end
    end
else
    local error_data = response:text()
    trace.log("Failed to load market data: " .. error_data)
    showNotification("Failed to load market data.")
end