local username = gurt.crumbs.get("username")
if username then
    trace.log("Welcome to GurtRug, " .. username)
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

-- display coin info based on query parameter 'symbol'
local symbol = gurt.location.query.get('symbol')
local welcometext = gurt.select("#welcometext")
if symbol then
    local url = 'https://ahf2139b.pythonanywhere.com/gurtrugauth/coin/' .. symbol .. "?username=" .. username
    local request_body = JSON.stringify({
    	username = username,
        password = password
    })
    local response = fetch(url, {
        method = 'GET',
        body = request_body
    })

    if response:ok() then
        local jsonData = response:json()
        if jsonData then
            trace.log(table.tostring(response:json()))
            welcometext.text = "Coin: " .. jsonData.name .. " (" .. jsonData.symbol .. ") \nCreator: " .. jsonData.creator .. " \nPrice: $" .. jsonData.currentPrice .. " \nPrice Change (24h): " .. jsonData.change24h .. "% \nYou own: " .. jsonData.amountOwned .. " " .. jsonData.symbol .. "($" .. jsonData.valueOwned .. ")"
        end
    else
        local error_data = response:text()
        local jsonData = response:json()
        showNotification("Error fetching coin data: " .. jsonData.message)
    end
else
    gurt.location.goto('/')
end

local buyamountInput = gurt.select('#buyamount')
local buyButton = gurt.select('#buybutton')
local sellamountInput = gurt.select('#sellamount')
local sellButton = gurt.select('#sellbutton')

function refreshMoney()
    local moneyCountDiv = gurt.select("#moneycount")
    if username then
        local request_body = JSON.stringify({
            username = username,
            password = gurt.crumbs.get("password")
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
                moneyCountDiv.text = "Wallet: $" .. jsonData.user.money
            end
        else
            local error_data = response:text()
            local jsonData = response:json()
            notificationDiv.text = jsonData.message
        end
    end
end
refreshMoney()

buyButton:on('click', function()
    local amount = tonumber(buyamountInput.value)
    if not amount or amount <= 0 then
        showNotification("Please enter a valid buy amount")
        return
    end

    local username = gurt.crumbs.get("username")
    local password = gurt.crumbs.get("password")

    local request_body = JSON.stringify({
    	username = username,
        password = password,
        symbol = symbol,
        amount = amount
    })
    local url = 'https://ahf2139b.pythonanywhere.com/gurtrugauth/buy_coin'
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
            showNotification("Successfully bought " .. amount .. " of " .. symbol)
            if symbol then
                local url = 'https://ahf2139b.pythonanywhere.com/gurtrugauth/coin/' .. symbol .. "?username=" .. username
                local request_body = JSON.stringify({
                    username = username,
                    password = password
                })
                local response = fetch(url, {
                    method = 'GET',
                    body = request_body
                })

                if response:ok() then
                    local jsonData = response:json()
                    if jsonData then
                        trace.log(table.tostring(response:json()))
                        welcometext.text = "Coin: " .. jsonData.name .. " (" .. jsonData.symbol .. ") \nCreator: " .. jsonData.creator .. " \nPrice: $" .. jsonData.currentPrice .. " \nPrice Change (24h): " .. jsonData.change24h .. "% \nYou own: " .. jsonData.amountOwned .. " " .. jsonData.symbol .. "($" .. jsonData.valueOwned .. ")"
                        refreshMoney()
                    end
                else
                    local error_data = response:text()
                    local jsonData = response:json()
                    showNotification("Error fetching coin data: " .. jsonData.message)
                end
            else
                gurt.location.goto('/')
            end
        end
    else
        local error_data = response:text()
        local jsonData = response:json()
        showNotification("Error buying coin: " .. jsonData.message)
    end
end)

sellButton:on('click', function()
    local amount = tonumber(sellamountInput.value)
    if not amount or amount <= 0 then
        showNotification("Please enter a valid sell amount")
        return
    end

    local username = gurt.crumbs.get("username")
    local password = gurt.crumbs.get("password")

    local request_body = JSON.stringify({
    	username = username,
        password = password,
        symbol = symbol,
        amount = amount
    })
    local url = 'https://ahf2139b.pythonanywhere.com/gurtrugauth/sell_coin'
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
            showNotification("Successfully sold " .. amount .. " of " .. symbol)
            if symbol then
                local url = 'https://ahf2139b.pythonanywhere.com/gurtrugauth/coin/' .. symbol
                local response = fetch(url)

                if response:ok() then
                    local jsonData = response:json()
                    if jsonData then
                        trace.log(table.tostring(response:json()))
                        if symbol then
                            local url = 'https://ahf2139b.pythonanywhere.com/gurtrugauth/coin/' .. symbol .. "?username=" .. username
                            local request_body = JSON.stringify({
                                username = username,
                                password = password
                            })
                            local response = fetch(url, {
                                method = 'GET',
                                body = request_body
                            })

                            if response:ok() then
                                local jsonData = response:json()
                                if jsonData then
                                    trace.log(table.tostring(response:json()))
                                    welcometext.text = "Coin: " .. jsonData.name .. " (" .. jsonData.symbol .. ") \nCreator: " .. jsonData.creator .. " \nPrice: $" .. jsonData.currentPrice .. " \nPrice Change (24h): " .. jsonData.change24h .. "% \nYou own: " .. jsonData.amountOwned .. " " .. jsonData.symbol .. "($" .. jsonData.valueOwned .. ")"
                                    refreshMoney()
                                end
                            else
                                local error_data = response:text()
                                local jsonData = response:json()
                                showNotification("Error fetching coin data: " .. jsonData.message)
                            end
                        else
                            gurt.location.goto('/')
                        end
                    end
                else
                    local error_data = response:text()
                    local jsonData = response:json()
                    showNotification("Error fetching coin data: " .. jsonData.message)
                end
            else
                gurt.location.goto('/')
            end
        end
    else
        local error_data = response:text()
        local jsonData = response:json()
        showNotification("Error selling coin: " .. jsonData.message)
    end
end)