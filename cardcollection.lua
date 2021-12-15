local Card = require 'card'
local CardCollection = Class{}

function CardCollection:init()
    self.cards = {}
end

local N = 0
function CardCollection:newCard()
    local card = Card()
    self.cards[#self.cards+1] = card
    
    card:setText(N)
    N = N + 1

    return card
end

function CardCollection:update(dt)
    
end

function CardCollection:draw()
    
end

function CardCollection:mousepressed( x, y, button, istouch, presses )
    if button == 1 then
        if Card.holding then
            for i, v in ipairs(self.cards) do
                if v:isHeld() then
                    v:release(x, y)
                end
            end
        else
            for i, v in ipairs(self.cards) do
                if (v:isPointInside({x, y})) then
                    v:hold(true)
                    self.clickTime = 0
                    return
                end
            end
        end
    end
end

function CardCollection:mousereleased( x, y, button, istouch, presses )
    if button == 1 then
        if Card.holding
        and self.clickTime > holdTime then
            for i, v in ipairs(self.cards) do
                if v:isHeld() then
                    v:release(x, y)
                end
            end
        end
    end
end

return CardCollection