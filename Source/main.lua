local pd <const> = playdate
local gfx <const> = pd.graphics
local font = gfx.font.new('font/Mini Sans 2X')

local todos = {}
local selected = 1

local function loadTodos()
    local data = pd.datastore.read("todos")
    if data then todos = data end
end

local function saveTodos()
    pd.datastore.write(todos, "todos")
end

loadTodos()

function pd.update()
    gfx.clear()
    gfx.setFont(font)

    for i, todo in ipairs(todos) do
        local y = 10 + (i - 1) * 26
        if i == selected then
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRoundRect(10, y, 220, 22, 4)
            local label = (todo.done and "[x] " or "[ ] ") .. todo.text
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            gfx.drawText(label, 16, y + 2)
        else
            local label = (todo.done and "[x] " or "[ ] ") .. todo.text
            gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
            gfx.drawText(label, 16, y + 2)
        end
    end

    local change = pd.getCrankChange()

    if change > 5 then
        selected = math.min(#todos, selected + 1)
    elseif change < -5 then
        selected = math.max(1, selected - 1)
    end

    if pd.buttonJustPressed(pd.kButtonDown) then
        selected = math.min(#todos, selected + 1)
    elseif pd.buttonJustPressed(pd.kButtonUp) then
        selected = math.max(1, selected - 1)
    end

    if pd.buttonJustPressed(pd.kButtonA) then
        todos[selected].done = not todos[selected].done
        saveTodos()
    end

    if pd.buttonJustPressed(pd.kButtonB) then
        table.remove(todos, selected)
        selected = math.min(selected, #todos)
        saveTodos()
    end
end



function pd.gameWillTerminate()
    saveTodos()
end

function pd.deviceWillSleep()
    saveTodos()
end