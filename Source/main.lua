import 'CoreLibs/easing'
import 'network'

local pd <const> = playdate
local gfx <const> = pd.graphics
local menu <const> = pd.getSystemMenu()
local font = gfx.font.new('font/Mini Sans 2X')

local todos = {}
local selected = 1
local scrollY = 0
local scrollVel = 0
local springK = 0.18
local springDamp = 0.82
local targetScrollY = 0
local easingStart = 0
local easingEnd = 0
local easingTime = 0
local easingDuration = 200 -- ms
local easingFunc = pd.easingFunctions.outCubic
local animating = false
local buttonOvershoot = 6
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
        local old = selected
        if selected == #todos then
            -- rubber-band overshoot at bottom
            local totalHeight = #todos * itemHeight
            local visibleHeight = viewBottom - viewTop
            local maxScroll = math.max(0, totalHeight - visibleHeight)
            easingStart = scrollY
            easingEnd = maxScroll + buttonOvershoot
            easingTime = 0
            easingFunc = pd.easingFunctions.outElastic
            animating = true
            return
        end

        selected = math.min(#todos, selected + 1)

        -- Only scroll if selected item goes off-screen
        local selTop = (selected - 1) * itemHeight
        local selBottom = selTop + itemHeight
        local viewTopY = scrollY
        local viewBottomY = scrollY + (viewBottom - viewTop)
        local totalHeight = #todos * itemHeight
        local visibleHeight = viewBottom - viewTop
        local maxScroll = math.max(0, totalHeight - visibleHeight)

        if selBottom > viewBottomY then
            targetScrollY = math.min(selBottom - visibleHeight, maxScroll)
        elseif selTop < viewTopY then
            targetScrollY = math.max(selTop, 0)
        end
    end,
    upButtonDown = function()
        local old = selected
        if selected == 1 then
            -- rubber-band overshoot at top
            easingStart = scrollY
            easingEnd = -buttonOvershoot
            easingTime = 0
            easingFunc = pd.easingFunctions.outElastic
            animating = true
            return
        end

        selected = math.max(1, selected - 1)

        -- Only scroll if selected item goes off-screen
        local selTop = (selected - 1) * itemHeight
        local selBottom = selTop + itemHeight
        local viewTopY = scrollY
        local viewBottomY = scrollY + (viewBottom - viewTop)
        local totalHeight = #todos * itemHeight
        local visibleHeight = viewBottom - viewTop
        local maxScroll = math.max(0, totalHeight - visibleHeight)

        if selBottom > viewBottomY then
            targetScrollY = math.min(selBottom - visibleHeight, maxScroll)
        elseif selTop < viewTopY then
            targetScrollY = math.max(selTop, 0)
        end
    end,
    cranked = function(change)
        if change > 5 then
            selected = math.min(#todos, selected + 1)
        elseif change < -5 then
            selected = math.max(1, selected - 1)
        else
            return
        end

        local target = (selected - 1) * itemHeight
        local visibleHeight = viewBottom - viewTop
        local totalHeight = #todos * itemHeight
        local maxScroll = math.max(0, totalHeight - visibleHeight)
        target = math.min(math.max(target, 0), maxScroll)

        targetScrollY = target
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
        gfx.fillRoundRect(390, scrollbarY, 6, scrollbarHeight, 3)
    end
end

menu:addMenuItem("Fetch todos", function()
    getTodos()
end)

function pd.update()
    pd.network.http.requestAccess()
    gfx.clear()
    gfx.setFont(font)
    -- Overshoot easing when animating
    if animating then
        easingTime += pd.getElapsedTime()
        if easingTime >= easingDuration then
            scrollY = easingEnd
            animating = false
        else
            scrollY = easingFunc(easingTime, easingStart, easingEnd - easingStart, easingDuration)
        end
    else
        -- Normal spring physics for scroll
        local displacement = targetScrollY - scrollY
        scrollVel = scrollVel + displacement * springK
        scrollVel = scrollVel * springDamp
        scrollY = scrollY + scrollVel
    end

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
end

function pd.gameWillTerminate()
    saveTodos()
end

function pd.deviceWillSleep()
    saveTodos()
end
