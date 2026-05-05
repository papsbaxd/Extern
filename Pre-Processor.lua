local Processor = {}

-- Функция для декодирования Hex-строки (\xFF) обратно в байты
local function decodeHex(hexString)
    local bytes = {}
    -- Ищем все последовательности вида \xXX
    for hex in hexString:gmatch("\\x(%x%x)") do
        table.insert(bytes, tonumber(hex, 16))
    end
    -- Если байтов нет, возвращаем пустую строку
    if #bytes == 0 then return "" end
    return string.char(table.unpack(bytes))
end

-- Основная функция обфускации
function Processor.obf(chunk)
    -- Парсим формат: @eX = "..."; @exec
    local level, data = chunk:match("@(e%d)%s*=%s*\"(.-)\";%s*@exec")
    
    if not level or not data then
        error("Invalid obfuscation format")
    end

    -- Декодируем Hex строку в исходный Lua код
    local decryptedCode = decodeHex(data)
    
    -- Отладка: если код пустой, значит ошибка в шифровании или передаче
    if #decryptedCode == 0 then
        error("Decryption resulted in empty code")
    end

    -- Выполняем расшифрованный код
    -- "bt" означает: разрешить и бинарный код, и текст. Это самый надежный режим.
    local func, err = load(decryptedCode, "obfuscated_chunk", "bt")
    
    if func then
        -- Запускаем функцию
        local success, result = pcall(func)
        if not success then
            warn("Runtime Error in obfuscated script: " .. tostring(result))
        end
    else
        -- Если load вернул ошибку компиляции
        error("Compilation Error: " .. tostring(err) .. "\nFirst 50 chars of code: " .. decryptedCode:sub(1, 50))
    end
end

return Processor
