script_name('EASY RPC EMUL')
script_author('ебать, это же чапо!')
local debug_e = false
local debug_mode = true
--[[

	Пример использования (выдача скина с id 49 игроку с id 123):

	local emulBs = {123, 49} --playerId, skinId
	emulRpcReceive(153, emulBs)

	--ИЛИ

	emulRpcReceive(153, {123, 49})

]]

local rpcs = {
    [176] = {'int16', 'float', 'float', 'float'},
    [12] = {'float', 'float', 'float'},
    [13] = {'float', 'float', 'float'},
    [14] = {'float'},
    [171] = {'int16', 'int32', 'float', 'float', 'float', 'float', 'float', 'bool'},
    [172] = {'int16'},
    [173] = {'int16', 'int8', 'string', 'int8', 'string', 'int8', 'string', 'float', 'bool', 'bool', 'bool', 'bool', 'int32'},
    [174] = {'int16'},
    [175] = {'int16', 'float'},
    [178] = {'int16', 'float'},
    [113] = {'int16', 'int32', 'bool', 'int32', 'int32', 'float', 'float', 'float', 'float', 'float', 'float', 'float', 'float', 'float', 'int32', 'int32'},
    [59] = {'int16', 'int32', 'float', 'int32', 'int8', 'string'},
    [37] = {},
    [38] = {'int8', 'float', 'float', 'float', 'float', 'float', 'float', 'float'},
    [39] = {},
    [107] = {'float', 'float', 'float'},
    [61] = {'int16', 'int8', 'int8', 'string', 'int8', 'string', 'int8', 'string', 'string'}, --last ìá äåëèòíóòü íàäî,
    [108] = {'int16', 'float', 'float', 'float', 'float', 'int32'},
    [120] = {'int16'},
    [121] = {'int16', 'int32'},
    [85] = {'int16'},
    [73] = {'int32', 'int32', 'int32', 'string'},
    [146] = {'float'},
    [56] = {'int8', 'float', 'float', 'float', 'int8', 'int32', 'int8'},
    [77] = {'int8'},
    [78] = {'int8'},
    [80] = {'int16', 'int8'},
    [44] = {'int16', 'int32', 'float', 'float', 'float', 'float', 'float', 'float', 'float', 'int8', 'int16', 'int16', 'float', 'float', 'float', 'float', 'float', 'float', 'int8'},
    --[84] = SKIP,
    [75] = {'int16', 'int16', 'float', 'float', 'float', 'float', 'float', 'float'},
    [27] = {'int16'},
    [28] = {'int16'},
    [45] = {'int16', 'float', 'float', 'float'},
    [47] = {'int16'},
    [122] = {'int16'},
    [95] = {'int32', 'int32', 'int32', 'float', 'float', 'float'},
    [137] = {'int16', 'int32', 'int8', 'int8', 'string'},
    [138] = {'int16', 'int8'},
    --[155] = {'int16', 'int32', 'int32'}, --ÔËÓÄÈÒ
    [86] = {'int16', 'int8', 'string', 'int8', 'string', 'float', 'bool', 'bool', 'bool', 'bool', 'int32'},
    [87] = {'int16'},
    [166] = {'int16'},
    [11] = {'int16', 'int8', 'string', 'int8'},
    [34] = {'int16', 'int32', 'int16'},
    [153] = {'int32', 'int32'},
    [29] = {'int8', 'int8'},
    [88] = {'int8'},
    [152] = {'int8'},
    [17] = {'float', 'float', 'float'},
    [90] = {'float', 'float', 'float'},
    [15] = {'int8'},
    [124] = {'int32'},
    [30] = {'int8'},
    [69] = {'int16', 'int8'},
    [16] = {'int32', 'float', 'float'},
    [18] = {'int32'},
    [22] = {'int32', 'int32'},
    [41] = {'int8', 'string', 'float', 'float', 'float', 'float', 'int8'},
    [43] = {'int32', 'float', 'float', 'float', 'float'},
    [66] = {'float'},
    [145] = {'int8', 'int16'},
    [67] = {'int32'},
    [32] = {'int16', 'int8', 'int32', 'float', 'float', 'float', 'float', 'int32', 'int8'},
    [163] = {'int16'},
    [79] = 'float', 'float', 'int16', 'float',
    [55] = {'int16', 'int16', 'int8'},
    [93] = {'int32', 'int32', 'string'},
    [35] = {'int32'},
    [89] = {'int16', 'int8'},
    [156] = {'int8'},
    [72] = {'int16', 'int32'},
    [111] = {'bool'},
    [133] = {'int8'},
    [157] = {'float', 'float', 'float'},
    [158] = {'float', 'float', 'float', 'int8'},
    [126] = {'int16', 'int8'},
    [127] = {'int16', 'int8'},
    [104] = {'int8'},
    [83] = {'int32', 'int8'},
    [105] = {'int16', 'int16', 'string'},
    [134] = {'int16', 'int8', 'float', 'float', 'int32', 'float', 'float', 'int32', 'int8', 'int8', 'int32', 'int8', 'int8', 'float', 'float', 'int16', 'float', 'float', 'float', 'float', 'int16', 'int16', 'int16', 'string'},
    [135] = {'int16'},
    [26] = {'int16', 'int16', 'int8'},
    [154] = {'int16', 'int16'},
    [57] = {'int16', 'int16'},
    [65] = {'int16', 'int8'},
    [70] = {'int16', 'int8'},
    [106] = {'int16', 'int32', 'int32', 'int8', 'int8'},
    [123] = {'int16', 'int8', 'string'},
    [147] = {'int16', 'float'},
    [159] = {'int16', 'float', 'float', 'float'},
    [160] = {'int16', 'float'},
    [161] = {'int16', 'int8', 'int8'},
    [164] = {'int16', 'int32', 'float', 'float', 'float', 'float', 'int8', 'int8', 'float', 'int8', 'int32', 'int32', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int32', 'int32'},
    [165] = {'int16'},
    [58] = {'int16'},
    [94] = {'int8'},
    [170] = {'bool'},
    [106] = {'int16', 'int32', 'int32', 'int8', 'int8'},
    [26] = {'int16', 'int8'},
    [154] = {'int16'},
    [101] = {'int8', 'string'},
    [118] = {'int8'},
    [53] = {'int8', 'int16'},
    [50] = {'int32', 'string'},
    [62] = {'int16', 'int8', 'int16', 'int8', 'string'},
    [103] = {'int8', 'int32', 'int8'},
    [115] = {'bool', 'int16', 'float', 'int32', 'int32'},
    [119] = {'float', 'float', 'float'},
    [128] = {'int16'},
    [132] = {'int8'},
    [25] = {'int32', 'int8', 'int8', 'string', 'int32', 'int8', 'string', 'int8', 'string'},
}

function main()
	while not isSampAvailable() do wait(0) end
	msg('rpc_emul.lua loaded')
	wait(-1)
end

function EXPORTS.emulRpcDebug(bool, mode) --true/false, 1/2 (1 - print, 2 - chat msg)
	debug_e = bool
	debug_mode = mode
end

function EXPORTS.emulRpcReceive(id, bsArray)
	if rpcs[id] ~= nil then
		if bsArray[1] ~= nil then
			bs = raknetNewBitStream()
			for i = 1, #bsArray do
				if bsArray[i] ~= nil then
					if rpcs[id][i] == 'int8' then
						raknetBitStreamWriteInt8(bs, bsArray[i])
					elseif rpcs[id][i] == 'int16' then
						raknetBitStreamWriteInt16(bs, bsArray[i])
					elseif rpcs[id][i] == 'int32' then
						raknetBitStreamWriteInt32(bs, bsArray[i])
					elseif rpcs[id][i] == 'float' then
						raknetBitStreamWriteFloat(bs, bsArray[i])
					elseif rpcs[id][i] == 'string' then
						raknetBitStreamWriteString(bs, bsArray[i])
					elseif rpcs[id][i] == 'bool' then
						raknetBitStreamWriteBool(bs, bsArray[i])
					end
				else
					msg('error: bitStream error, arg num '..i..' == nil!')
				end
			end
			raknetEmulRpcReceiveBitStream(id, bs)
			msg('done! (RPC received: '..id..')')
			raknetDeleteBitStream(bs)
		end

	else
		msg('rpc '..id..' does not exists!')
	end
end

function msg(text)
	if debug_e then
		if debug_mode == 1 then
			print('DEBUG: '..text)
		else
			print('DEBUG: '..text)
			sampAddChatMessage('DEBUG: {ffffff}'..text, 0xFFff004d)
		end
	end
end