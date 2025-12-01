local pd <const> = playdate
local gfx <const> = pd.graphics

todo = {}

-- ============================================================
-- State
-- ============================================================

local todos = {}
local selected = 1

-- scrolling / physics
local scrollY = 0
local scrollVel = 0
local targetScrollY = 0

-- spring settings
local springK = 0.18
local springDamp = 0.82

-- easing for overshoot
local easingStart = 0
local easingEnd = 0
local easingTime = 0
local easingDuration = 200
local easingFunc = pd.easingFunctions.outCubic
local animating = false

-- layout
local itemHeight = 26
local viewTop = 26
local viewBottom = 240 - 10
local buttonOvershoot = 6

-- ============================================================
-- Save / Load
-- ============================================================

local function loadTodos()
    local data = pd.datastore.read("todos")
    if data then todos = data end
end

local function saveTodos()
    pd.datastore.write(todos, "todos")
end

loadTodos()

-- ============================================================
-- Selection & Scrolling
-- ============================================================

local function moveSelection(delta)
    local newSel = selected + delta

    -- Boundary overshoot bounce
    if newSel < 1 or newSel > #todos then
        local visibleHeight = viewBottom - viewTop
        local totalHeight = #todos * itemHeight
        local maxScroll = math.max(0, totalHeight - visibleHeight)

        easingStart = scrollY
        easingEnd = (newSel < 1)
            and -buttonOvershoot
            or (maxScroll + buttonOvershoot)

        easingTime = 0
        easingFunc = pd.easingFunctions.outElastic
        animating = true
        return
    end

    -- Valid selection
    selected = newSel

    -- Scroll only if selected item goes off-screen
    local selTop = (selected - 1) * itemHeight
    local selBottom = selTop + itemHeight
    local visibleHeight = viewBottom - viewTop
    local viewTopY = scrollY
    local viewBottomY = scrollY + visibleHeight
    local totalHeight = #todos * itemHeight
    local maxScroll = math.max(0, totalHeight - visibleHeight)

    if selBottom > viewBottomY then
        targetScrollY = math.min(selBottom - visibleHeight, maxScroll)
    elseif selTop < viewTopY then
        targetScrollY = math.max(selTop, 0)
    end
end

-- ============================================================
-- Input Handlers
-- ============================================================

local handlers = {
    AButtonDown = function()
        todos[selected].done = not todos[selected].done
        saveTodos()
    end,

    upButtonDown = function() moveSelection(-1) end,
    downButtonDown = function() moveSelection(1) end,

    cranked = function(change)
        if change > 5 then
            selected = math.min(#todos, selected + 1)
        elseif change < -5 then
            selected = math.max(1, selected - 1)
        else
            return
        end

        -- Compute scroll target for crank
        local target = (selected - 1) * itemHeight
        local visibleHeight = viewBottom - viewTop
        local totalHeight = #todos * itemHeight
        local maxScroll = math.max(0, totalHeight - visibleHeight)

        targetScrollY = math.min(math.max(target, 0), maxScroll)
    end
}

pd.inputHandlers.push(handlers)

-- ============================================================
-- Drawing UI
-- ============================================================

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

local function drawTodos()
    gfx.setLineWidth(2)
    gfx.setStrokeLocation(gfx.kStrokeInside)
    for i, todo in ipairs(todos) do
        local y = viewTop + (i - 1) * itemHeight - scrollY

        if i == selected then
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRoundRect(5, y - 2, 380, itemHeight - 2, 4)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            gfx.setColor(gfx.kColorWhite)
            gfx.drawText(todo.text, 40, y + 2)
        else
            gfx.setColor(gfx.kColorBlack)
            gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
            gfx.drawText(todo.text, 40, y + 2)
        end

        gfx.drawRect(15, y + 2, itemHeight - 8, itemHeight - 8)

        if todo.done then
            -- Draw checkmark
            local cx = 15
            local cy = y + 2
            local size = itemHeight - 8
            gfx.setLineWidth(3)
            gfx.drawLine(cx + 4, cy + size / 2, cx + size / 2 - 2, cy + size - 4)
            gfx.drawLine(cx + size / 2 - 2, cy + size - 4, cx + size - 4, cy + 4)
            gfx.setLineWidth(2)
        end
    end

    drawScrollbar()
end

-- ============================================================
-- Update Loop
-- ============================================================

function todo.update()
    if animating then
        easingTime += pd.getElapsedTime()
        if easingTime >= easingDuration then
            scrollY = easingEnd
            animating = false
        else
            scrollY =
                easingFunc(easingTime, easingStart, easingEnd - easingStart, easingDuration)
        end
    else
        -- Normal spring physics
        local displacement = targetScrollY - scrollY
        scrollVel = scrollVel + displacement * springK
        scrollVel = scrollVel * springDamp
        scrollY = scrollY + scrollVel
        scrollY = math.max(scrollY, 0)
    end

    drawTodos()
end

-- ============================================================
-- Cleanup
-- ============================================================

function todo.save()
    saveTodos()
end

return todo
