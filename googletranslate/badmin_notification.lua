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
local old_notification_AddLegacy = notification.AddLegacy
local translatedNotifications = {}
function notification.AddLegacy(text, type, length)
    if not translatedNotifications[text] then
        translatedNotifications[text] = text
        googleTranslate(text, "auto", "en", function(newtext)
            translatedNotifications[text] = newtext
            print(newtext)
            old_notification_AddLegacy(newtext,type,length)
        end)
        return
    end
    print(translatedNotifications[text])
    old_notification_AddLegacy(translatedNotifications[text], type, length)
end