local pd <const> = playdate
local gfx <const> = pd.graphics
local font = gfx.font.new('font/Mini Sans 2X')

local todos = {}
local selected = 1
local scrollY = 0
local targetScrollY = 0
local scrollVel = 0
local springK = 0.18
local springDamp = 0.75
local buttonOvershoot = 6
local scrollEase = 0.2
local itemHeight = 26
local viewTop = 10
local viewBottom = 240 - 10

local function loadTodos()
    local data = pd.datastore.read("todos")
    if data then todos = data end
end

local function saveTodos()
    pd.datastore.write(todos, "todos")
end

loadTodos()

local inputHandlers = {
    AButtonDown = function()
        todos[selected].done = not todos[selected].done
        saveTodos()
    end,
    downButtonDown = function()
        selected = math.min(#todos, selected + 1)
        targetScrollY = targetScrollY + buttonOvershoot
    end,
    upButtonDown = function()
        selected = math.max(1, selected - 1)
        targetScrollY = targetScrollY - buttonOvershoot
    end,
    cranked = function(change)
        if change > 5 then
            selected = math.min(#todos, selected + 1)
            scrollVel = scrollVel - 4 -- crank spring impulse
        elseif change < -5 then
            selected = math.max(1, selected - 1)
            scrollVel = scrollVel + 4 -- crank spring impulse
        end
    end
}
pd.inputHandlers.push(inputHandlers)

local function drawScrollbar()
    local totalHeight = #todos * itemHeight
    local visibleHeight = viewBottom - viewTop

    if totalHeight > visibleHeight then
        local scrollbarHeight = math.max(20, visibleHeight * (visibleHeight / totalHeight))
        local scrollPercent = scrollY / (totalHeight - visibleHeight)
        local scrollbarY = viewTop + (visibleHeight - scrollbarHeight) * scrollPercent

        gfx.setColor(gfx.kColorBlack)
        gfx.fillRoundRect(400 - 12, scrollbarY, 6, scrollbarHeight, 3)
    end
end

function pd.update()
    gfx.clear()
    gfx.setFont(font)
    local displacement = targetScrollY - scrollY
    scrollVel = scrollVel + displacement * springK
    scrollVel = scrollVel * springDamp
    scrollY = scrollY + scrollVel

    for i, todo in ipairs(todos) do
        local y = viewTop + (i - 1) * itemHeight - scrollY
        if i == selected then
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRoundRect(10, y - 2, 375, itemHeight - 2, 4)
            local label = (todo.done and "[x] " or "[ ] ") .. todo.text
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            gfx.drawText(label, 16, y + 2)
        else
            local label = (todo.done and "[x] " or "[ ] ") .. todo.text
            gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
            gfx.drawText(label, 16, y + 2)
        end
    end

    drawScrollbar()

    local selY = viewTop + (selected - 1) * itemHeight - scrollY

    if selY < viewTop then
        targetScrollY = targetScrollY - (viewTop - selY)
    elseif selY + itemHeight > viewBottom then
        targetScrollY = targetScrollY + (selY + itemHeight - viewBottom)
    end
end

function pd.gameWillTerminate()
    saveTodos()
end

function pd.deviceWillSleep()
    saveTodos()
end
