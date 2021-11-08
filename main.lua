-- reminder to self for splitting command:
-- python -m spleeter separate -p spleeter:2stems -o bjork/bachelorette bachelorette.mp3

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
    local original_sd = lsound.newSoundData(n_samples, stems_SD[i]:getSampleRate(), stems_SD[i]:getBitDepth(), 1)
    local reverse_sd = lsound.newSoundData(n_samples, stems_SD[i]:getSampleRate(), stems_SD[i]:getBitDepth(), 1)

    for j = 0, n_samples - 1 do

        -- if stems_SD[i]:getChannelCount() == 2 then
        original_sd:setSample(j, 1, (stems_SD[i]:getSample(j, 1) + stems_SD[i]:getSample(j, 2)) / 2)
        reverse_sd:setSample(j, 1, stems_SD[i]:getSample(n_samples - 1 - j, 1) + stems_SD[i]:getSample(n_samples - 1 - j, 1) / 2)

        -- end


        -- for k = 1, stems_SD[i]:getChannelCount() do
        --     reverse_sd:setSample(j, k, stems_SD[i]:getSample(n_samples - 1 - j, k))
        -- end
    end

    original_stems[i] = la.newSource(original_sd)
    reverse_stems[i] = la.newSource(reverse_sd)

end

for i = 1, 4 do
    stems[i]:play()
    stems[i]:setLooping(true)
end

joystick = lj.getJoysticks()[1]

font = lg.newFont(80)
timer_text = lg.newText(font,"")

-- for later
-- stems[1]:setFilter({type="lowpass",volume=1,highgain=.001})


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

    local joystick_x = joystick:getAxis(1)
    local joystick_y = joystick:getAxis(2)
    if math.abs(joystick_x) < 0.5 then joystick_x = 0 end
    if math.abs(joystick_y) < 0.5 then joystick_y = 0 end

    -- VOLUME

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

    -- REVERSE

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

    -- FILTER EFFECTS

    for i = 1, 4 do
        if joystick_y < 0 then
            stems[i]:setFilter({type="bandpass",volume=1,lowgain = 1, highgain = 0.01 / math.abs(joystick_y)})
        elseif joystick_y > 0 then
            stems[i]:setFilter({type="bandpass",volume=1,lowgain = 0.01 / math.abs(joystick_y), highgain = 1})
        else
            stems[i]:setFilter()
        end
    end

    -- POSITION EFFECTS

    for i = 1, 4 do
        stems[i]:setPosition(joystick_x, 0, 0)
    end

    -- TIMER

    local length = stems[4]:tell()
    if stems == reverse_stems then
        length = stems[4]:getDuration() - length
    end

    timer_text:set(string.format("%.2f", tostring(length)))

end

function love.keypressed(key)
    if key == "escape" then le.quit() end
end

function love.gamepadpressed(joystick, button)

    -- FORWARD + BACK

    if button == "dpleft" then
        for i = 1, 4 do
            stems[i]:seek(math.max(0, stems[i]:tell() - 10))
        end
    end
    if button == "dpright" then
        for i = 1, 4 do
            stems[i]:seek((stems[i]:tell() + 10))
        end
    end
end