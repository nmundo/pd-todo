local pd <const> = playdate
local gfx <const> = pd.graphics
local font = gfx.font.new('font/Mini Sans 2X')

local todos = {}
local selected = 1
local scrollY = 0
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
    end,
    upButtonDown = function()
        selected = math.max(1, selected - 1)
    end,
    cranked = function(change)
        if change > 5 then
            selected = math.min(#todos, selected + 1)
        elseif change < -5 then
            selected = math.max(1, selected - 1)
        end
    end
}
pd.inputHandlers.push(inputHandlers)

function pd.update()
    gfx.clear()
    gfx.setFont(font)

    for i, todo in ipairs(todos) do
        local y = viewTop + (i - 1) * itemHeight - scrollY
        if i == selected then
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRoundRect(10, y - 2, 380, itemHeight - 2, 4)
            local label = (todo.done and "[x] " or "[ ] ") .. todo.text
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            gfx.drawText(label, 16, y + 2)
        else
            local label = (todo.done and "[x] " or "[ ] ") .. todo.text
            gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
            gfx.drawText(label, 16, y + 2)
        end
    end

    local selY = viewTop + (selected - 1) * itemHeight - scrollY

    if selY < viewTop then
        scrollY = scrollY - (viewTop - selY)
    elseif selY + itemHeight > viewBottom then
        scrollY = scrollY + (selY + itemHeight - viewBottom)
    end
end



function pd.gameWillTerminate()
    saveTodos()
end

function pd.deviceWillSleep()
    saveTodos()
end