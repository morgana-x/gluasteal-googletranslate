if not rp then return end
local char_to_hex = function(c)
    return string.format("%%%02X", string.byte(c))
    end
    
    local function urlencode(url)
    if url == nil then
        return
    end
    url = url:gsub("\n", "\r\n")
    url = url:gsub("([^%w ])", char_to_hex)
    url = url:gsub(" ", "+")
    return url
    end
    
    local hex_to_char = function(x)
    return string.char(tonumber(x, 16))
    end
    
    local urldecode = function(url)
    if url == nil then
        return
    end
    url = url:gsub("+", " ")
    url = url:gsub("%%(%x%x)", hex_to_char)
    return url
    end
function googleTranslate(str, from, to,cb)

    if (not from)  then from = "auto" end
    if (not to  )  then to = "en" end

    str = urlencode(str)
    local request = "https://clients5.google.com/translate_a/t?client=dict-chrome-ex&sl=" .. from .. "&tl=" .. to .."&q=" .. str
    
    http.Fetch( request, function(body, size, headers, code)
        local decoded = util.JSONToTable( body )
        --print(body)
        local text = decoded[1][1]
        --print(text)
        cb(text)
    end)
end
local meta = FindMetaTable("Player")

local oldGetJob = meta.GetJobName
function meta:GetJobName()
    local untranslatedJob = oldGetJob(self)

    if not GoogleTranslatetranslatedTeamNames[untranslatedJob] then

        GoogleTranslatetranslatedTeamNames[untranslatedJob] = untranslatedJob

        googleTranslate(untranslatedJob, "auto", "en", function(newtext)

            GoogleTranslatetranslatedTeamNames[untranslatedJob] = newtext
        end)
    end
    return GoogleTranslatetranslatedTeamNames[untranslatedJob] or "TRANSLATING..."
end


if rp.clientlaws then 
    googleTranslate(  rp.clientlaws, "auto", "en", function(newtext)
        rp.clientlaws = newtext
    end)
end
net.Receive("LawUpdate", function()
    if (net.ReadBool() ~= true) then
            local laws =  net.ReadString()

            timer.Simple(1, function()

                googleTranslate(laws, "auto", "en", function(newtext)
                    rp.clientlaws = newtext
                end)

            end)
    end
end)
local function AddDrawingInfo(ent, rawData)
    local drawData = {}
    local textSize = {}

    local totalHeight = 0
    local maxWidth = 0
    local currentHeight = 0

    for i = 1, #rawData do
        -- Setup tables
        if not rawData[i] or not rawData[i].text then continue end
        drawData[i] = {}
        textSize[i] = {}
        -- Text
        drawData[i][TEXT] = rawData[i].text
        -- Font
        drawData[i][FONT] = (ValidFont(rawData[i].font) or textscreenFonts[1])
        -- Text size
        surface.SetFont(drawData[i][FONT])
        textSize[i][1], textSize[i][2] = surface.GetTextSize(drawData[i][TEXT])
        textSize[i][2] = rawData[i].size
        -- Workout max width for render bounds
        maxWidth = maxWidth > textSize[i][1] and maxWidth or textSize[i][1]
        -- Position
        totalHeight = totalHeight + textSize[i][2]
        -- Colour
        drawData[i][COL] = Color(rawData[i].color.r, rawData[i].color.g, rawData[i].color.b, 255)
        -- Size
        drawData[i][SIZE] = rawData[i]["size"]
        -- Remove text if text is empty so we don't waste performance
        if string.len(drawData[i][TEXT]) == 0 or string.len(string.Replace( drawData[i][TEXT], " ", "" )) == 0 then drawData[i][TEXT] = nil end
        --Rainbow
        drawData[i][RAINBOW] = rawData[i]["rainbow"] or 0
    end

    -- Sort out heights
    for i = 1, #rawData do
        if not rawData[i] then continue end
        -- The x position at which to draw the text relative to the text screen entity
        drawData[i][POSX] = math.ceil(-textSize[i][1] / 2)
        -- The y position at which to draw the text relative to the text screen entity
        drawData[i][POSY] = math.ceil(-(totalHeight / 2) + currentHeight)
        -- Calculate the cam.Start3D2D size based on the size of the font
        drawData[i][CAMSIZE] = (0.25 * drawData[i][SIZE]) / 100
        -- Use the CAMSIZE to "scale" the POSY
        drawData[i][POSY] = (0.25 / drawData[i][CAMSIZE] * drawData[i][POSY])
        -- Highest line to lowest, so that everything is central
        currentHeight = currentHeight + textSize[i][2]
    end

    -- Cache the number of lines/length
    drawData[LEN] = #drawData
    -- Add the new data to our text screen list
    screenInfo[ent] = drawData

    -- Calculate the render bounds
    local x = maxWidth / widthBoundsDivider
    local y = currentHeight / heightBoundsDivider + 13 -- Text is above the centre

    -- Setup the render bounds
    ent:SetRenderBounds(Vector(-x, -y, -1.75), Vector(x, y, 1.75))
end
net.Receive("textscreens_update", function(len)
    local ent = net.ReadEntity()

    if IsValid(ent) and ent:GetClass() == "ent_textscreen" then

        local t = net.ReadTable()
        local textTable = {}
        for _, data in ipairs(t) do
            table.insert(textTable, data.text)
        end
        local oldLines = table.concat(textTable, ";")
        googletranslate(oldLines, "auto", "en", function(newtext)

            local newlines = string.Split(newtext, ";")

            for _, text in ipairs(newlines) do
                if t[_] then t[_].text = text end
            end

            ent.lines = t
            AddDrawingInfo(ent, t)
        end)
        -- Incase an addon or something wants to read the information.
        
    end
end)

local oldDoorGetGroup =  ENTITY.DoorGetGroup
local oldDoorGetTitle = ENTITY.DoorGetTitle
local translatedDoorGroups = {}
function ENTITY:DoorGetGroup()

    local oldDoorGroup = oldDoorGetGroup(self)

    if oldDoorGroup then
        if not translatedDoorGroups[oldDoorGroup] then
            translatedDoorGroups[oldDoorGroup] = oldDoorGroup
            googleTranslate(oldDoorGroup, "auto", "en", function(newtext)
                translatedDoorGroups[oldDoorGroup] = newtext
            end)
        end
        return translatedDoorGroups[oldDoorGroup]
    end
    return oldDoorGroup
end

function ENTITY:DoorGetTitle()

    local oldDoorGroup = oldDoorGetTitle(self)

    if oldDoorGroup then
        if not translatedDoorGroups[oldDoorGroup] then
            translatedDoorGroups[oldDoorGroup] = oldDoorGroup
            googleTranslate(oldDoorGroup, "auto", "en", function(newtext)
                translatedDoorGroups[oldDoorGroup] = newtext
            end)
        end
        return translatedDoorGroups[oldDoorGroup]
    end
    return oldDoorGroup
end