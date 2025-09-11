local username = gurt.crumbs.get("username")
local notificationDiv = gurt.select("#notification")

function showNotification(message)
    local notificationText = gurt.create('div')
    notificationText.text = message
    local oldNotification = gurt.select('#notification').firstChild
    if oldNotification then
        oldNotification:remove()
    end
    notificationDiv:append(notificationText)
end

local homeButton = gurt.select("#homebutton")
local homeButtonClick = homeButton:on('click', function()
    gurt.location.goto('/')
end)
local signoutButton = gurt.select("#signoutbutton")
local signoutButtonClick = signoutButton:on('click', function()
    gurt.crumbs.delete("username")
    gurt.crumbs.delete("password")
    gurt.location.goto('/signin.html')
end)

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

local dailyMoneyButton = gurt.select("#dailymoneybutton")
local dailyMoneyButtonClick = dailyMoneyButton:on('click', function()
    if username then
        local request_body = JSON.stringify({
            username = username,
            password = gurt.crumbs.get("password")
        })
        local url = 'https://ahf2139b.pythonanywhere.com/gurtrugauth/daily'
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
                showNotification("You have claimed your daily money of $" .. jsonData.money)
                refreshMoney()
            end
        else
            local error_data = response:text()
            local jsonData = response:json()
            showNotification(jsonData.error)
        end
    end
end)

local createCoinButton = gurt.select("#createcoinbutton")
local createCoinButtonClick = createCoinButton:on('click', function()
    gurt.location.goto('/createcoin.html')
end)

