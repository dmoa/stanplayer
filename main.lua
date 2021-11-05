la = love.audio
ld = love.data
le = love.event
lfile = love.filesystem
lf = love.font
lg = love.graphics
li = love.image
lj = love.joystick
lk = love.keyboard
lm = love.math
lmouse = love.mouse
lp = love.physics
lsound = love.sound
lsys = love.system
lth = love.thread
lt = love.timer
ltouch = love.touch
lv = love.video
lw = love.window

function tovolume(value) return value and 1 or 0 end

icon = lg.newImage("icon.png")

file_path = "stems/3 follow god/"

stem_1 = la.newSource(file_path.."1.wav", "stream")
stem_2 = la.newSource(file_path.."2.wav", "stream")
stem_3 = la.newSource(file_path.."3.wav", "stream")
stem_4 = la.newSource(file_path.."4.wav", "stream")

stem_1:play()
stem_2:play()
stem_3:play()
stem_4:play()

joystick = lj.getJoysticks()[1]

function love.love()
end

function love.draw()
    lg.draw(icon, lg.getWidth() / 2 - 270)
end

function love.update(dt)

    button_1_down = joystick:isGamepadDown("y")
    button_2_down = joystick:isGamepadDown("b")
    button_3_down = joystick:isGamepadDown("a")
    button_4_down = joystick:isGamepadDown("x")

    if button_1_down or button_2_down or button_3_down or button_4_down then
        stem_1:setVolume(tovolume(button_1_down))
        stem_2:setVolume(tovolume(button_2_down))
        stem_3:setVolume(tovolume(button_3_down))
        stem_4:setVolume(tovolume(button_4_down))
    else
        stem_1:setVolume(1)
        stem_2:setVolume(1)
        stem_3:setVolume(1)
        stem_4:setVolume(1)
    end

end

function love.keypressed(key)
    if key == "escape" then le.quit() end
end