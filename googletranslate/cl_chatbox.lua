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



local function googleTranslate(str, from, to,cb)

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
surface.CreateFont( "FancyChatBox", {font = "Tahoma", extended = false,size = 18,weight = 700,} )
surface.CreateFont( "FancyChatBox12", {font = "Tahoma", extended = false,size = 19,weight = 600,} )

local myChat = {}
local size1, size2 = ScrW() / 2.5, ScrH() / 4
local pos1, pos2 = 30, ScrH() / 1.6
local chatbox_isteam = false
local myChat_chathistory = {}
local myChat_TextEntry_chathistory_cursor_pos = 0

myChat.dFrame = vgui.Create("DFrame")
myChat.dFrame:SetPos(pos1, pos2)
myChat.dFrame:SetTitle("")
myChat.dFrame:ShowCloseButton(false)
myChat.dFrame:SetAlpha(255)
myChat.dFrame:SetSize(size1, size2)
myChat.dFrame:SetDraggable( false )
myChat.dFrame.Paint = function ()  end
myChat.dFrame:Show()

myChat.dTextEntry = vgui.Create("DTextEntry", myChat.dFrame)
myChat.dTextEntry:SetFont("FancyChatBox")
myChat.dTextEntry:SetPos(0,size2 - size2 / 10)
myChat.dTextEntry:SetSize(size1, ScrH() / 50)
myChat.dTextEntry:SetPaintBackgroundEnabled( true )
myChat.dTextEntry:SetAlpha(255)
myChat.dTextEntry:Hide()
myChat.dTextEntry.OnKeyCodeTyped = function( self, code )
	if code == KEY_ESCAPE then
		myChat.closeChatbox()
		gui.HideGameUI()
	elseif code == KEY_ENTER then
		local text = self:GetText()

		if string.Trim( self:GetText() ) != "" then  
			if !chatbox_isteam then
				 googleTranslate(self:GetText(), "auto", "ru", function(newtext)
					 LocalPlayer():ConCommand( "say " .. newtext ) ;
				 end)
			else
				googleTranslate(self:GetText(), "auto", "ru", function(newtext)
					LocalPlayer():ConCommand( "say_team " .. newtext ); 
				end)
			end 
		end
		myChat.closeChatbox()
	end
end

myChat.dRichText = vgui.Create("RichText", myChat.dFrame)
myChat.dRichText:SetPos(0,0)
myChat.dRichText:SetSize(size1, size2 - size2 / 10)
myChat.dRichText:SetVerticalScrollbarEnabled( false )
myChat.dRichText.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(20,20,20,0)) end
myChat.dRichText:Show()
myChat.dRichText.PerformLayout = function (self)
self:SetFontInternal("FancyChatBox12")
self:SetFGColor( color_white )
end

hook.Add( "PlayerBindPress", "overrideChatbind", function( ply, bind, pressed )
    local bTeam = false
	chatbox_isteam = false
    if bind == "messagemode" then
    elseif bind == "messagemode2" then
        bTeam = true
		chatbox_isteam = true
	elseif bind == "cancelselect" then 
		myChat.closeChatbox()
    else
        return
    end

    myChat.openChatbox( bTeam )

    return true 
end )

hook.Add( "ChatText", "serverNotifications", function( index, name, text, type )
    if type == "joinleave" or type == "none" then
		myChat.dRichText:InsertColorChange( 255,255,255, 255)
        myChat.dRichText:AppendText( text .. "\n" )
		myChat.dRichText:InsertFade(8, 2)
    end
end )

hook.Add( "HUDShouldDraw", "noMoreDefault", function( name )
	if name == "CHudChat" then
		return false
	end
end )

local oldAddText = chat.AddText
function chat.AddText( ... )
	local args = {...}
	for _, obj in ipairs( args ) do
		if type( obj ) == "table" then
			myChat.dRichText:InsertColorChange( obj.r, obj.g, obj.b, 255 )
		elseif type( obj ) == "string"  then 
			myChat.dRichText:AppendText( obj )
			myChat.dRichText:InsertFade(8, 2)
		elseif obj:IsPlayer() then
			local col = GAMEMODE:GetTeamColor( obj ) 
			myChat.dRichText:InsertColorChange( col.r, col.g, col.b, 255 )
			myChat.dRichText:AppendText( obj:Nick() )
			myChat.dRichText:InsertFade(8, 2)
		end
	end
	myChat.dRichText:AppendText( "\n" )
	myChat.dRichText:InsertFade(8, 2)
	oldAddText( ... )
end



function myChat.openChatbox(bTeam)
	myChat.dFrame:MakePopup()
	myChat.dFrame:SetMouseInputEnabled( true )

	myChat.dRichText:SetBGColor(20, 20, 20, 200)
	myChat.dRichText:ResetAllFades(true, false, 100000)
	myChat.dRichText:SetVerticalScrollbarEnabled( true)
	myChat_TextEntry_chathistory_cursor_pos = 1

	if bTeam then myChat.dTextEntry:SetBGColor(Color(100,230,100,255)); else myChat.dTextEntry:SetBGColor(Color(210,210,210,255));end
	myChat.dTextEntry:Show()
	myChat.dTextEntry:RequestFocus()

	hook.Run( "StartChat" )
end

function myChat.closeChatbox()
	myChat.dFrame:SetMouseInputEnabled( false )
	myChat.dFrame:SetKeyboardInputEnabled( false )

	myChat.dTextEntry:SetText( "" )
	myChat.dTextEntry:Hide()
	if string.Trim( myChat.dRichText:GetText() ) != "" then table.insert(myChat_chathistory, self:GetText()) end
	if #myChat_chathistory > 6 then table.remove(myChat_chathistory, 1) end
	myChat.dRichText:ResetAllFades(false, false, 2)
	myChat.dRichText:SetBGColor(20, 20, 20, 0)
	myChat.dRichText:SetVerticalScrollbarEnabled( false )

	gui.EnableScreenClicker( false )

	hook.Run( "FinishChat" )
	hook.Run( "ChatTextChanged", "" )
end

--timer.Simple(1, function() chat.AddText(Color(255,255,255,255), "Welcome to " .. GetHostName() .. "!" ) end)