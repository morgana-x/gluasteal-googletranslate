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
timer.Simple(0, function()
    gluasteal.include("googletranslate/cl_chatbox.lua")
    local old = chat.AddText

    function chat.AddText(...)
                
                local tbl = {...}

                local text = ""

                local transforms = {}
                local x = 1
                for _, obj in ipairs(tbl) do
                        if not isstring(obj) then continue end
                        text = text ..  obj .. ";"
                        transforms[x] = _
                        --print( tostring(x) .. " = " .. tostring(_))
                        --print( text .. " = " .. tostring(x))
                        x = x + 1
                end

--                    print(text)
                
                googleTranslate(text, "auto", "en", function(newtext)


                        local stuff = string.Split(newtext, ";")

                        local doublechecktext = ""



                        
                        for _, thing in ipairs(stuff) do
                                local pos = transforms[_] --_*2
                                --print( "Index: " .. tostring(_))
                               -- print( "Transform: " ..  tostring(pos))
                                if not isstring(tbl[pos]) then 
                                    --print(thing .. " does not exist at position " .. tostring(pos) ); 
                                    continue 
                                end

                                --print(tbl[pos])

                                doublechecktext = doublechecktext .. thing

                                tbl[pos] = thing

                        end
                       -- print(doublechecktext)
                        
                        --print(util.TableToJSON(tbl))

                        old(unpack(tbl))



                        --old(Color(255,255,100), "[EN]", Color(255,255,255), newtext )
                end)
    end

   
end)