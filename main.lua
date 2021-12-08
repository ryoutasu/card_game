Class = require 'class'
Vector = require 'vector'
Utils = require 'utils'
local Hand = require 'hand'

local hand = nil

function love.load()
    love.window.setMode(1200, 800)

    hand = Hand(50, 750)
    hand:addCard()
    hand:addCard()
end

function love.update(dt)
    hand:update(dt)
end

function love.draw()
    hand:draw()
end

function love.keypressed(key)
    if key == 'space' then
        hand:addCard()
    elseif key == 'r' then
        hand:removeCard()
    end
end

function love.mousepressed( x, y, button, istouch, presses )
    hand:mousepressed( x, y, button, istouch, presses )
end

function love.mousereleased( x, y, button, istouch, presses )
    hand:mousereleased( x, y, button, istouch, presses )
end