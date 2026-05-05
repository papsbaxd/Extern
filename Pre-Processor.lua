local Processor = {}
local function decodeHex(hexString)
    local bytes = {}
    for hex in hexString:gmatch("\\x(%x%x)") do
        table.insert(bytes, tonumber(hex, 16))
    end
    return string.char(table.unpack(bytes))
end
function Processor.obf(chunk)
    local level, data = chunk:match("@(e%d)%s*=%s*\"(.-)\";%s*@exec")
    if not level or not data then
        error("Invalid obfuscation format: " .. tostring(chunk):sub(1, 50))
    end
    local decryptedCode = decodeHex(data)
    if not decryptedCode or #decryptedCode == 0 then
        error("Decryption failed: empty result")
    end
    local func, err = load(decryptedCode, "obfuscated_chunk", "t")
    if func then
        local success, result = pcall(func)
        if not success then
            warn("Error in obfuscated script: " .. tostring(result))
        end
    else
        error("Load failed: " .. tostring(err))
    end
end

return Processor
