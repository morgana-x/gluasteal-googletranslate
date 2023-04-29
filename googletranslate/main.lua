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
    
local validLanguages = {
    ["auto"] = "Auto",
    ["en"] = "English",
    ["es"] = "Spanish",
    ["fr"] = "French",
    ["de"] = "German",
    ["it"] = "Italian",
    ["pt"] = "Portuguese",
    ["ru"] = "Russian",
    ["zh"] = "Chinese",
    ["ja"] = "Japanese",
    ["ko"] = "Korean",
    ["ar"] = "Arabic",
    ["hi"] = "Hindi",
    ["bn"] = "Bengali",
    ["id"] = "Indonesian",
    ["ms"] = "Malay",
    ["tr"] = "Turkish",
    ["th"] = "Thai",
    ["vi"] = "Vietnamese",
    ["nl"] = "Dutch",
    ["sv"] = "Swedish",
}



function googleTranslate(str, from, to,cb)

    if (not from) or (not validLanguages[from] ) then from = "auto" end
    if (not to  ) or (not validLanguages[to]   ) then to = "en" end

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
local oldNick = meta.Nick
local oldGetName = meta.GetName

local translatedNames = {}
function meta:Nick()
    if not translatedNames[oldNick(self)] then
        local oldName = oldNick(self)
        translatedNames[oldName] = oldName
        googleTranslate(oldName, "auto", "en", function(newtext)
            translatedNames[oldName] = newtext
        end)
    end
    return translatedNames[oldNick(self)]
end

function meta:GetName()
    if not translatedNames[oldGetName(self)] then
        local oldName = oldGetName(self)
        translatedNames[oldName] = oldName
        googleTranslate(oldName, "auto", "en", function(newtext)
            translatedNames[oldName] = newtext
        end)
    end
    return translatedNames[oldGetName(self)]
end

GoogleTranslatetranslatedTeamNames = {}


local oldTeamGetName = team.GetName

function team.GetName(index)
    local untranslatedJob = oldTeamGetName(index)

    if not GoogleTranslatetranslatedTeamNames[untranslatedJob] then

        GoogleTranslatetranslatedTeamNames[untranslatedJob] = untranslatedJob

        googleTranslate(untranslatedJob, "auto", "en", function(newtext)

            GoogleTranslatetranslatedTeamNames[untranslatedJob] = newtext
        end)
    end
    return GoogleTranslatetranslatedTeamNames[untranslatedJob] or "TRANSLATING..."
end

gluasteal.include("googletranslate/chat.lua")
gluasteal.include("googletranslate/modules/sup_darkrp.lua")
