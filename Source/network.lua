local net <const> = playdate.network

local url = "jsonplaceholder.typicode.com"
local conn = nil


function initConnection()
    conn = net.http.new(url)
end

function getTodos()
    if conn == nil then
        initConnection()
    end

    conn:get("/todos")

    conn:setRequestCompleteCallback(function()
        print("HTTP requestComplete called")
        local bytes = conn:getBytesAvailable()
        local response = conn:read()
        print(string.format("\tHTTP GET getBytesAvailable: %i", bytes))
        print(response)
    end
    )
end
