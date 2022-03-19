local Card = require 'card'
local Hand = Class{}

local N = 1
local holdTime = 0.1
local offset_x = 10
local card_width = 100
local card_height = 150

---Hand of a cards
---@param x number center
---@param y number bottom
function Hand:init(x, y, board)
    self.pos = Vector(x, y)
    self.cards = {}
    self.maxCards = 10
    self.clickTime = 0
    self.board = board
    self.index = 0
end

function Hand:addCard(card)
    if not Card.holding then
        if self.index < self.maxCards then
            self.index = self.index + 1
            card = card or Card(self.board, card_width, card_height)
            if not card.board then card.board = self.board end
            card:setText(N)
            self.cards[#self.cards+1] = card
            self.cards[card] = #self.cards
            self:rearrange()
            
            N = N + 1
        end
    end
end

function Hand:setCardPosition(card, position)
    local n = self.index
    local p = position-1
    local w = n*card_width + (n-1)*offset_x
    local x = (self.pos.x-w/2) + (card_width*p) + (offset_x*p)
    local y = self.pos.y - card_height

    card:moveTo(Vector(x, y), 'IN_HAND')
end

function Hand:rearrange(n)
    if n then
        for i = n+1, #self.cards do
            local card = self.cards[i]
            self.cards[n] = card
            self.cards[card] = n
            n = n + 1
        end
        self.cards[n] = nil
    else
        local j = 1
        for i, card in ipairs(self.cards) do
            if card ~= self.board.card then
                self:setCardPosition(card, j)
                j = j + 1
            end
        end
    end
end

function Hand:removeCard()
    local card = self.board.card
    if card then
        self:rearrange(self.cards[card])
        self.board.card = nil
    end
end

function Hand:release(x, y)
    for i, v in ipairs(self.cards) do
        if v:isHeld() then
            if v:release(x, y) then
                self.board.card = v
                self.index = self.index - 1
                self:rearrange()
            end
        end
    end
end

function Hand:update(dt)
    for i, v in ipairs(self.cards) do
        v:update(dt)
    end
    if Card.holding then
        self.clickTime = self.clickTime + dt
    end
end

function Hand:draw()
    for i, v in ipairs(self.cards) do
        v:draw()
    end
end

function Hand:keypressed(key)
    
end

function Hand:mousepressed( x, y, button, istouch, presses )
    if button == 1 then
        if Card.holding then
            self:release(x, y)
        else
            for i, v in ipairs(self.cards) do
                if (v:isPointInside({x, y})) and not v.locked then
                    v:hold(true)
                    self.clickTime = 0
                    return
                end
            end
        end
    end
end

function Hand:mousereleased( x, y, button, istouch, presses )
    if button == 1 then
        if Card.holding
        and self.clickTime > holdTime then
            self:release(x, y)
        end
    end
end

return Hand