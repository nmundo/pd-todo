import 'CoreLibs/easing'
import 'CoreLibs/graphics'
import 'todo'

local pd <const> = playdate
local gfx <const> = pd.graphics

local function drawHeader()
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.fillRect(0, 0, 400, 20)
    gfx.drawLine(0, 20, 400, 20)
    gfx.drawText("To Do", 16, 2)

    local time = pd.getTime()
    local timestr = string.format("%02d:%02d", time.hour, time.minute)
    local tw = gfx.getTextSize(timestr)
    gfx.drawText(timestr, 400 - tw - 12, 2)
end

function playdate.update()
    todo.update()
    drawHeader()
end

function playdate.gameWillTerminate()
    todo.save()
end

function playdate.deviceWillSleep()
    todo.save()
end
