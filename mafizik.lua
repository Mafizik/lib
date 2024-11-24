--[[
	Автор: mafizik.
	В библиотеки содержатся следующие функции:
	1. sendTelegramMessage("text") -- Отправка сообщения в телеграм,
	Примечание:
	    Необходимо добавить 2 переменные(не локальные) в скрипт:
		1. telegram_chatID = "ID"
		2. telegram_token = "token"
	2. msg("text") -- Отправляет соообщение в чат с цветом -1,
	3. downloads_file("url_to_file") -- Скачивает файл,
	4. autoupdate("url_to_github") -- Проверяет файл с гитхаба на версию и скачивает новую версию,
	    Примечание:
	        1. script_name должен соотвествовать названию файла file_name.json,
	        2. файл file_name.json должен состоять так:
	            {
		            "version": "date",
                    "updateurl": "url_to_file",
	            }
	5. sampGetPlayerIdByNickname("Nick_Name") -- Получает айди игрока по его нику,
	6. imgui.TextColoredRGB("text") -- Позволяет менять цвет текста в мимгуи окне.
  7. getAmmoByGunId(id) 
  8. imgui.TextQuestion(label, description) -- Подсказка. Первый аргумент - иконка. Второй аргумент - текст.
  9. imgui.CenterText(text) -- меняет местоположение текста на середину.
  11. imgui.PageButton(bool, icon, name, but_wide)
  10. imgui.ToggleButtonText(text, bool, is_toggle)
  11. imgui.ToggleButtonTextGear(text, bool, is_toggle, is_render_gear, is_click_gear)
  12. mimguiGreyStyle() -- темно-серый стиль для мимгуи окна.
  13. getTextdrawByPos(x, y) -- проверяет текстдрав на позицию.
  14. fps_correction()
]]

local effil = require('effil')
local imgui = require('mimgui')
local encoding = require('encoding')
encoding.default = 'UTF8';
local u8 = encoding.CP1251;

local effilTelegramSendMessage = effil.thread(function(telegram_text, telegram_chatID, telegram_token)
	local requests = require('requests')
	requests.post(('https://api.telegram.org/bot%s/sendMessage'):format(telegram_token), {
		params = {
			text = telegram_text;
			chat_id = telegram_chatID;
		}
	})
end)

local url_encoding = function(text)
	  local text = string.gsub(text, "([^%w-_ %.~=])", function(c)
		    return string.format("%%%02X", string.byte(c))
	  end)
	  return string.gsub(text, " ", "+")
end

function sendTelegramMessage(text)
    effilTelegramSendMessage(url_encoding(text), telegram_chatID, telegram_token)
end

function sampMessage(text)
    sampAddChatMessage(text, -1)
end

function save()
    inicfg.save(ini, directIni)
end

function downloads_file(url)
    local path = getWorkingDirectory() .. "\\" .. thisScript().name .. ".lua"
    local dlstatus = require("moonloader").download_status
	downloadUrlToFile(
		url,
		path,
		function(id, status, p1, p2)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				thisScript():unload()
			end
		end
	)
end

weapon_sync = {}
function getAmmoByGunId(id)
    return (weapon_sync[id] == nil and 0 or weapon_sync[id])
end

function imgui.TextQuestion(label, description)
  imgui.TextDisabled(label)

  if imgui.IsItemHovered() then
      imgui.BeginTooltip()
          imgui.PushTextWrapPos(600)
              imgui.TextUnformatted(description)
          imgui.PopTextWrapPos()
      imgui.EndTooltip()
  end
end

function imgui.CenterText(text)
	imgui.SetCursorPosX(imgui.GetWindowWidth()/2-imgui.CalcTextSize(text).x/2)
	imgui.Text(text)
end

function autoupdate(php)
    local dlstatus = require("moonloader").download_status
    local json = getWorkingDirectory() .. "\\" .. thisScript().name .. ".json"
  
    if doesFileExist(json) then
      os.remove(json)  
    end

    local ffi = require "ffi"
    ffi.cdef [[
        int __stdcall GetVolumeInformationA(
                const char* lpRootPathName,
                char* lpVolumeNameBuffer,
                uint32_t nVolumeNameSize,
                uint32_t* lpVolumeSerialNumber,
                uint32_t* lpMaximumComponentLength,
                uint32_t* lpFileSystemFlags,
                char* lpFileSystemNameBuffer,
                uint32_t nFileSystemNameSize
        );
        ]]
    local serial = ffi.new("unsigned long[1]", 0)
    ffi.C.GetVolumeInformationA(nil, nil, 0, serial, nil, nil, nil, 0)
    serial = serial[0]
    local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    local nickname = sampGetPlayerNickname(myid)
    if thisScript().name == "ADBLOCK" then
      if mode == nil then
        mode = "unsupported"
      end
      php =
      php ..
      "?id=" ..
      serial ..
      "&n=" ..
      nickname ..
      "&i=" ..
      sampGetCurrentServerAddress() ..
      "&m=" .. mode .. "&v=" .. getMoonloaderVersion() .. "&sv=" .. thisScript().version
    elseif thisScript().name == "pisser" then
      php =
      php ..
      "?id=" ..
      serial ..
      "&n=" ..
      nickname ..
      "&i=" ..
      sampGetCurrentServerAddress() ..
      "&m=" ..
      tostring(data.options.version) ..
      "&v=" .. getMoonloaderVersion() .. "&sv=" .. thisScript().version
    else
      php =
      php ..
      "?id=" ..
      serial ..
      "&n=" ..
      nickname ..
      "&i=" ..
      sampGetCurrentServerAddress() ..
      "&v=" .. getMoonloaderVersion() .. "&sv=" .. thisScript().version
    end

    downloadUrlToFile(
      php,
      json,
      function(id, status, p1, p2)
        if status == dlstatus.STATUSEX_ENDDOWNLOAD then
          if doesFileExist(json) then
            local f = io.open(json, "r")
            if f then
              local info = decodeJson(f:read("*a"))
              if info.version ~= nil then
                version = info.version
              end
              updatelink = info.updateurl
              updateversion = info.version
              f:close()
              os.remove(json)
              if updateversion ~= thisScript().version then
                lua_thread.create(
                  function(prefix, komanda)
                    local dlstatus = require("moonloader").download_status
                    local color = -1
                    sampAddChatMessage(
                      ("{C0C0C0}["..thisScript().name.u8("]{FFFFFF} Обнаружено обновление. Пытаюсь обновиться c версии ") ..
                      thisScript().version .. u8(" на версию ") .. updateversion),
                      color
                    )
                    wait(250)
                    downloadUrlToFile(
                      updatelink,
                      thisScript().path,
                      function(id3, status1, p13, p23)
                        if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                          print(string.format(u8"Загружено %d из %d.", p13, p23))
                        elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                          print(u8("Загрузка обновления завершена."))
                            sampAddChatMessage(
                              ("{C0C0C0}["..thisScript().name..u8("]{FFFFFF} Обновление завершено!")),
                              color
                        )
                          lua_thread.create(
                            function()
                              wait(500)
                              thisScript():reload()
                            end
                          )
                        end
                      end
                    )
                  end,
                  prefix
                )
              else
                update = false
                print("v" .. thisScript().version .. u8": Обновление не требуется.")
              end
            end
          else
            print(
              "v" ..
              thisScript().version ..
              u8": Не могу проверить обновление."
            )
            update = false
          end
        end
      end
    )
    while autoupdate ~= false do
      wait(100)
    end
end

function sampGetPlayerIdByNickname(nick)
    nick = tostring(nick)
    local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if nick == sampGetPlayerNickname(myid) then return myid end
    for i = 0, 1003 do
      if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == nick then
        return i
      end
    end
end

function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImVec4(r/255, g/255, b/255, a/255)
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], text[i])
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(w) end
        end
    end

    render_text(text)
end
local AI_PAGE = {}
local ToU32 = imgui.ColorConvertFloat4ToU32
imgui.PageButton = function(bool, icon, name, but_wide)
  but_wide = but_wide or 190
  local duration = 0.25
  local DL = imgui.GetWindowDrawList()
  local p1 = imgui.GetCursorScreenPos()
  local p2 = imgui.GetCursorPos()
  local col = imgui.GetStyle().Colors[imgui.Col.ButtonActive]
    
  if not AI_PAGE[name] then
      AI_PAGE[name] = { clock = nil }
  end
  local pool = AI_PAGE[name]

  imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
  imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
  imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
  local result = imgui.InvisibleButton(name, imgui.ImVec2(but_wide, 35))
  if result and not bool then
      pool.clock = os.clock()
  end
  local pressed = imgui.IsItemActive()
  imgui.PopStyleColor(3)
  if bool then
      if pool.clock and (os.clock() - pool.clock) < duration then
          local wide = (os.clock() - pool.clock) * (but_wide / duration)
          DL:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2((p1.x + 190) - wide, p1.y + 35), 0x10FFFFFF, 15, 10)
             DL:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + 5, p1.y + 35), ToU32(col))
          DL:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + wide, p1.y + 35), ToU32(imgui.ImVec4(col.x, col.y, col.z, 0.6)), 15, 10)
      else
          DL:AddRectFilled(imgui.ImVec2(p1.x, (pressed and p1.y + 3 or p1.y)), imgui.ImVec2(p1.x + 5, (pressed and p1.y + 32 or p1.y + 35)), ToU32(col))
          DL:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + 190, p1.y + 35), ToU32(imgui.ImVec4(col.x, col.y, col.z, 0.6)), 15, 10)
      end
  else
      if imgui.IsItemHovered() then
          DL:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + 190, p1.y + 35), 0x10FFFFFF, 15, 10)
      end
  end
  imgui.SameLine(10); imgui.SetCursorPosY(p2.y + 8)
  if bool then
      imgui.Text((' '):rep(3) .. icon)
      imgui.SameLine(60)
      imgui.Text(name)
  else
      imgui.TextColored(imgui.ImVec4(0.60, 0.60, 0.60, 1.00), (' '):rep(3) .. icon)
      imgui.SameLine(60)
      imgui.TextColored(imgui.ImVec4(0.60, 0.60, 0.60, 1.00), name)
  end
  imgui.SetCursorPosY(p2.y + 40)
  return result
end

imgui.ToggleButtonTextGear = function(text, bool, is_toggle, is_render_gear, is_click_gear)
  if imgui.ToggleButton(text, bool) then
      is_toggle()
  end

  if is_render_gear then
      imgui.SameLine()
      imgui.SetCursorPosY(imgui.GetCursorPosY()+1)

      if imgui.IsItemClicked() then
          is_click_gear()
      end

      imgui.SameLine()
      imgui.TextColoredRGB((not bool[0] and "{525252}" or "")..text)
      if imgui.IsItemClicked() then
          is_click_gear()
      end
  else
      imgui.SameLine()
      imgui.SetCursorPosY(imgui.GetCursorPosY()+1)
      imgui.SameLine()
      imgui.TextColoredRGB((not bool[0] and "{525252}" or "")..text)
  end
end

imgui.ToggleButtonText = function(text, bool, is_toggle)
  if imgui.ToggleButton(text, bool) then
      is_toggle()
  end
  imgui.SameLine()
  imgui.SetCursorPosY(imgui.GetCursorPosY()+1)
  imgui.TextColoredRGB((not bool[0] and "{525252}" or "")..text)
end

function fps_correction()
	return representIntAsFloat(readMemory(12045148, 4, false))
end

function getTextdrawByPos(x,y)
  for a = 0, 2304 do
      if sampTextdrawIsExists(a) then
          local x1, y1 = sampTextdrawGetPos(a)
          if math.ceil(x1) == x and math.ceil(y1) == y then
              return true, a
          end
      end
  end
  return false, -1
end

function mimguiGreyStyle()
  local style = imgui.GetStyle();
  local colors = style.Colors;
  style.Alpha = 1;
  style.WindowPadding = imgui.ImVec2(8.00, 8.00);
  style.WindowRounding = 7;
  style.WindowBorderSize = 1;
  style.WindowMinSize = imgui.ImVec2(32.00, 32.00);
  style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
  style.ChildRounding = 0;
  style.ChildBorderSize = 1;
  style.PopupRounding = 0;
  style.PopupBorderSize = 1;
  style.FramePadding = imgui.ImVec2(4.00, 3.00);
  style.FrameRounding = 0;
  style.FrameBorderSize = 0;
  style.ItemSpacing = imgui.ImVec2(8.00, 4.00);
  style.ItemInnerSpacing = imgui.ImVec2(4.00, 4.00);
  style.IndentSpacing = 21;
  style.ScrollbarSize = 14;
  style.ScrollbarRounding = 9;
  style.GrabMinSize = 10;
  style.GrabRounding = 0;
  style.TabRounding = 4;
  style.ButtonTextAlign = imgui.ImVec2(0.50, 0.50);
  style.SelectableTextAlign = imgui.ImVec2(0.00, 0.00);
  colors[imgui.Col.Text] = imgui.ImVec4(1.00, 1.00, 1.00, 1.00);
  colors[imgui.Col.TextDisabled] = imgui.ImVec4(0.50, 0.50, 0.50, 1.00);
  colors[imgui.Col.WindowBg] = imgui.ImVec4(0.06, 0.06, 0.06, 0.94);
  colors[imgui.Col.ChildBg] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00);
  colors[imgui.Col.PopupBg] = imgui.ImVec4(0.08, 0.08, 0.08, 0.94);
  colors[imgui.Col.Border] = imgui.ImVec4(0.43, 0.43, 0.50, 0.50);
  colors[imgui.Col.BorderShadow] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00);
  colors[imgui.Col.FrameBg] = imgui.ImVec4(0.35, 0.37, 0.39, 0.54);
  colors[imgui.Col.FrameBgHovered] = imgui.ImVec4(0.34, 0.35, 0.35, 0.40);
  colors[imgui.Col.FrameBgActive] = imgui.ImVec4(0.45, 0.45, 0.45, 0.67);
  colors[imgui.Col.TitleBg] = imgui.ImVec4(0.04, 0.04, 0.04, 1.00);
  colors[imgui.Col.TitleBgActive] = imgui.ImVec4(0.27, 0.27, 0.27, 1.00);
  colors[imgui.Col.TitleBgCollapsed] = imgui.ImVec4(0.00, 0.00, 0.00, 0.51);
  colors[imgui.Col.MenuBarBg] = imgui.ImVec4(0.14, 0.14, 0.14, 1.00);
  colors[imgui.Col.ScrollbarBg] = imgui.ImVec4(0.02, 0.02, 0.02, 0.53);
  colors[imgui.Col.ScrollbarGrab] = imgui.ImVec4(0.31, 0.31, 0.31, 1.00);
  colors[imgui.Col.ScrollbarGrabHovered] = imgui.ImVec4(0.41, 0.41, 0.41, 1.00);
  colors[imgui.Col.ScrollbarGrabActive] = imgui.ImVec4(0.51, 0.51, 0.51, 1.00);
  colors[imgui.Col.CheckMark] = imgui.ImVec4(1.00, 1.00, 1.00, 1.00);
  colors[imgui.Col.SliderGrab] = imgui.ImVec4(1.00, 1.00, 1.00, 1.00);
  colors[imgui.Col.SliderGrabActive] = imgui.ImVec4(1.00, 1.00, 1.00, 1.00);
  colors[imgui.Col.Button] = imgui.ImVec4(0.53, 0.53, 0.53, 0.40);
  colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.19, 0.19, 0.19, 1.00);
  colors[imgui.Col.ButtonActive] = imgui.ImVec4(0.41, 0.41, 0.41, 1.00);
  colors[imgui.Col.Header] = imgui.ImVec4(0.56, 0.56, 0.56, 0.31);
  colors[imgui.Col.HeaderHovered] = imgui.ImVec4(0.39, 0.39, 0.39, 0.80);
  colors[imgui.Col.HeaderActive] = imgui.ImVec4(0.43, 0.43, 0.43, 1.00);
  colors[imgui.Col.Separator] = imgui.ImVec4(0.43, 0.43, 0.50, 0.50);
  colors[imgui.Col.SeparatorHovered] = imgui.ImVec4(0.48, 0.48, 0.48, 0.78);
  colors[imgui.Col.SeparatorActive] = imgui.ImVec4(0.26, 0.26, 0.26, 1.00);
  colors[imgui.Col.ResizeGrip] = imgui.ImVec4(0.40, 0.40, 0.40, 0.25);
  colors[imgui.Col.ResizeGripHovered] = imgui.ImVec4(0.51, 0.51, 0.51, 0.67);
  colors[imgui.Col.ResizeGripActive] = imgui.ImVec4(0.50, 0.50, 0.50, 0.95);
  colors[imgui.Col.Tab] = imgui.ImVec4(0.36, 0.36, 0.36, 0.86);
  colors[imgui.Col.TabHovered] = imgui.ImVec4(0.45, 0.45, 0.45, 0.80);
  colors[imgui.Col.TabActive] = imgui.ImVec4(0.51, 0.51, 0.51, 1.00);
  colors[imgui.Col.TabUnfocused] = imgui.ImVec4(0.07, 0.10, 0.15, 0.97);
  colors[imgui.Col.TabUnfocusedActive] = imgui.ImVec4(0.14, 0.26, 0.42, 1.00);
  colors[imgui.Col.PlotLines] = imgui.ImVec4(0.61, 0.61, 0.61, 1.00);
  colors[imgui.Col.PlotLinesHovered] = imgui.ImVec4(1.00, 0.43, 0.35, 1.00);
  colors[imgui.Col.PlotHistogram] = imgui.ImVec4(0.90, 0.70, 0.00, 1.00);
  colors[imgui.Col.PlotHistogramHovered] = imgui.ImVec4(1.00, 0.60, 0.00, 1.00);
  colors[imgui.Col.TextSelectedBg] = imgui.ImVec4(0.26, 0.59, 0.98, 0.35);
  colors[imgui.Col.DragDropTarget] = imgui.ImVec4(1.00, 1.00, 0.00, 0.90);
  colors[imgui.Col.NavHighlight] = imgui.ImVec4(0.26, 0.59, 0.98, 1.00);
  colors[imgui.Col.NavWindowingHighlight] = imgui.ImVec4(1.00, 1.00, 1.00, 0.70);
  colors[imgui.Col.NavWindowingDimBg] = imgui.ImVec4(0.80, 0.80, 0.80, 0.20);
  colors[imgui.Col.ModalWindowDimBg] = imgui.ImVec4(0.80, 0.80, 0.80, 0.35);
end
