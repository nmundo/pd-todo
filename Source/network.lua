local net <const> = playdate.network

local conn = nil

function getTodos()
    local url = "jsonplaceholder.typicode.com"

    conn = net.http.new(url)

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
