import 'CoreLibs/easing'
import 'CoreLibs/graphics'
import 'todo/todo'

local pd <const> = playdate
local gfx <const> = pd.graphics
local font = gfx.font.new('font/Mini Sans 2X')
gfx.setFont(font)

local function drawHeader(title)
    local titleWidth = gfx.getTextSize(title)
    local tabWidth = titleWidth + 16
    local headerHeight = 20

    -- Header background
    gfx.fillRect(0, 0, 400, headerHeight)

    -- Tab background
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, headerHeight / 2, tabWidth, headerHeight / 2)
    gfx.fillRoundRect(0, 0, tabWidth, headerHeight, 6) -- tab shape
    gfx.setColor(gfx.kColorBlack)

    -- Dotted line at bottom of tab
    gfx.setColor(gfx.kColorBlack)
    for x = 0, tabWidth, 4 do
        gfx.drawPixel(x, headerHeight)
    end
    gfx.setColor(gfx.kColorBlack)

    -- Tab text
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    gfx.drawText(title, 8, 4)

    -- Time on right side
    local time = pd.getTime()
    local timestr = string.format("%02d:%02d", time.hour, time.minute)
    local tw = gfx.getTextSize(timestr)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawText(timestr, 400 - tw - 12, 2)
end

function playdate.update()
    gfx.clear()
    todo.update()
    drawHeader("To Do")
end

function playdate.gameWillTerminate()
    todo.save()
end

function playdate.deviceWillSleep()
    todo.save()
end
