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

original_stems = {}
reverse_stems = {}
stems = original_stems
stems_SD = {}


for i = 1, 4 do
    stems[i] = la.newSource(file_path..tostring(i)..".wav", "static")
    stems_SD[i] = lsound.newSoundData(file_path..tostring(i)..".wav")

    local n_samples = stems[i]:getDuration("samples")
    local temp_sd = lsound.newSoundData(n_samples, stems_SD[i]:getSampleRate(), stems_SD[i]:getBitDepth(), stems_SD[i]:getChannelCount())
    for j = 0, n_samples - 1 do
        temp_sd:setSample(j, 1, stems_SD[i]:getSample(n_samples - 1 - j, 1))
        temp_sd:setSample(j, 2, stems_SD[i]:getSample(n_samples - 1 - j, 2))
    end
    reverse_stems[i] = la.newSource(temp_sd)

end

for i = 1, 4 do
    stems[i]:play()
end

joystick = lj.getJoysticks()[1]

font = lg.newFont(80)
timer_text = lg.newText(font,"")

-- for later
-- stems[1]:setFilter({type="highpass",volume=1,lowgain=.001})


function love.draw()

    -- rotation off for now but keeping it for fun to show to people
    local length = stems[1]:tell()
    if stems == reverse_stems then
        length = stems[1]:getDuration() - length
    end
    local rotation = (length / 4) % (math.pi * 2)
    -- rotation = 0

    lg.draw(icon, lg:getWidth() / 2, lg:getHeight() / 2, rotation, 1, 1, icon:getWidth() / 2, icon:getHeight() / 2)

    lg.draw(timer_text)
end

-- 4 is a very awkward number to for loop,
-- because it makes it almost less readable to do a 4 loop
-- for 4 things, so I will only do it when it's helpful.
function love.update(dt)

    local button_1_down = joystick:isGamepadDown("y")
    local button_2_down = joystick:isGamepadDown("b")
    local button_3_down = joystick:isGamepadDown("a")
    local button_4_down = joystick:isGamepadDown("x")
    local button_rs = joystick:isGamepadDown("rightshoulder")
    local button_ls = joystick:isGamepadDown("leftshoulder")
    local button_back = joystick:isGamepadDown("back")

    if button_1_down or button_2_down or button_3_down or button_4_down then
        stems[1]:setVolume(tovolume(button_1_down))
        stems[2]:setVolume(tovolume(button_2_down))
        stems[3]:setVolume(tovolume(button_3_down))
        stems[4]:setVolume(tovolume(button_4_down))
    else
        stems[1]:setVolume(1)
        stems[2]:setVolume(1)
        stems[3]:setVolume(1)
        stems[4]:setVolume(1)
    end

    if button_rs then
        if stems ~= reverse_stems then
            stems = reverse_stems
            for i = 1, 4 do
                stems[i]:seek(original_stems[i]:getDuration() - original_stems[i]:tell())
                original_stems[i]:pause()
                stems[i]:play()
            end
        end
    else
        if stems ~= original_stems then
            stems = original_stems
            for i = 1, 4 do
                stems[i]:seek(reverse_stems[i]:getDuration() - reverse_stems[i]:tell())
                reverse_stems[i]:pause()
                stems[i]:play()
            end
        end

    end

    local length = stems[1]:tell()
    if stems == reverse_stems then
        length = stems[1]:getDuration() - length
    end

    timer_text:set(string.format("%.2f", tostring(length)))

end

function love.keypressed(key)
    if key == "escape" then le.quit() end
end