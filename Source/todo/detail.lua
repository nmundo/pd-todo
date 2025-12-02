local pd <const> = playdate
local gfx <const> = pd.graphics

detail = {}

local selectedButton = "doneBtn"

-- Draw the popup for the given todo
function detail.draw(todo, selectedIndex, closeCallback)
    local btnActions = {
        doneBtn = function()
            todo.done = not todo.done
        end,
        deleteBtn = function()
            -- TODO Delete confirmation dialog
        end,
    }

    local handlers = {
        AButtonDown = function()
            btnActions[selectedButton]()
        end,
        BButtonDown = function()
            pd.inputHandlers.pop()
            closeCallback()
        end,
        rightButtonDown = function()
            selectedButton = "deleteBtn"
        end,
        leftButtonDown = function()
            selectedButton = "doneBtn"
        end,
        upButtonDown = function()
            -- TODO
        end,
        downButtonDown = function()
            -- TODO
        end,
    }
    pd.inputHandlers.push(handlers)

    -- Dim + dither background
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, 400, 240)
    gfx.setColor(gfx.kColorWhite)
    gfx.setDitherPattern(0.4, gfx.image.kDitherTypeBayer2x2)
    gfx.fillRect(0, 0, 400, 240)
    gfx.setDitherPattern(0)

    -- Panel
    local panelX, panelY = 20, 25
    local panelW, panelH = 360, 200

    gfx.setColor(gfx.kColorBlack)
    gfx.fillRoundRect(panelX + 3, panelY + 3, panelW, panelH, 12)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(panelX, panelY, panelW, panelH, 12)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRoundRect(panelX, panelY, panelW, panelH, 12)

    local textX = panelX + 12
    local y = panelY + 20

    gfx.drawText("Details", textX, y)

    -- Buttons
    local btnSize = 30
    local btnY    = panelY + 8
    local deleteX = 400 - btnSize - 28
    local doneX   = deleteX - btnSize - 6

    -- Done
    if selectedButton == "doneBtn" then
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRoundRect(doneX + 3, btnY + 3, btnSize, btnSize, 6) -- shadow
    end
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(doneX, btnY, btnSize, btnSize, 6)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRoundRect(doneX, btnY, btnSize, btnSize, 6)
    gfx.drawText("1", doneX + 9, btnY + 6)

    -- Delete
    if selectedButton == "deleteBtn" then
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRoundRect(deleteX + 3, btnY + 3, btnSize, btnSize, 6) -- shadow
    end
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(deleteX, btnY, btnSize, btnSize, 6)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRoundRect(deleteX, btnY, btnSize, btnSize, 6)
    gfx.drawText("2", deleteX + 9, btnY + 6)

    y += 24
    gfx.drawLine(panelX + 8, y, panelX + panelW - 8, y)
    y += 16

    gfx.drawText("Task:", textX, y)
    y += 18
    gfx.drawText(todo.text or "", textX, y)
    y += 26

    gfx.drawText("Due Date:", textX, y)
    y += 18
    gfx.drawText(todo.dueDate or "None", textX, y)
    y += 26

    gfx.drawText("Priority:", textX, y)
    y += 18
    gfx.drawText(todo.priority or "None", textX, y)
end
