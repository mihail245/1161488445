--[[
    Многофункциональный скрипт для Roblox с 20 невизуальными функциями
    Автор: Ассистент
    Версия: 1.0
]]

local Utilities = {}

-- 1. Генератор случайных чисел в диапазоне
function Utilities.RandomRange(min, max)
    return math.random(min, max)
end

-- 2. Проверка, является ли число простым
function Utilities.IsPrime(num)
    if num <= 1 then return false end
    for i = 2, math.sqrt(num) do
        if num % i == 0 then return false end
    end
    return true
end

-- 3. Округление числа до N знаков после запятой
function Utilities.RoundDecimal(num, decimalPlaces)
    local mult = 10^(decimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- 4. Проверка, находится ли игрок в радиусе от точки
function Utilities.IsInRadius(position, targetPosition, radius)
    return (position - targetPosition).Magnitude <= radius
end

-- 5. Конвертер секунд в формат MM:SS
function Utilities.SecondsToMinutes(seconds)
    local minutes = math.floor(seconds / 60)
    local remainingSeconds = seconds % 60
    return string.format("%02d:%02d", minutes, remainingSeconds)
end

-- 6. Генератор уникального ID
function Utilities.GenerateUID(length)
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local uid = ""
    for i = 1, length or 10 do
        uid = uid .. string.sub(chars, math.random(1, #chars), 1)
    end
    return uid
end

-- 7. Проверка на столкновение с лучом (raycast)
function Utilities.RaycastCheck(origin, direction, distance, ignoreList)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = ignoreList or {}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    return workspace:Raycast(origin, direction * distance, raycastParams)
end

-- 8. Таблица с глубоким копированием
function Utilities.DeepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            v = Utilities.DeepCopy(v)
        end
        copy[k] = v
    end
    return copy
end

-- 9. Фильтрация таблицы по условию
function Utilities.FilterTable(tbl, predicate)
    local result = {}
    for k, v in pairs(tbl) do
        if predicate(v, k) then
            result[k] = v
        end
    end
    return result
end

-- 10. Перемешивание элементов таблицы (Fisher-Yates алгоритм)
function Utilities.ShuffleTable(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
    return t
end

-- 11. Проверка видимости между двумя точками
function Utilities.IsVisible(pointA, pointB, ignoreList)
    local direction = (pointB - pointA).Unit
    local distance = (pointB - pointA).Magnitude
    local hit = Utilities.RaycastCheck(pointA, direction, distance, ignoreList)
    return hit == nil
end

-- 12. Интерполяция между двумя значениями (Lerp)
function Utilities.Lerp(a, b, t)
    return a + (b - a) * t
end

-- 13. Ограничение значения в диапазоне
function Utilities.Clamp(value, min, max)
    return math.min(math.max(value, min), max)
end

-- 14. Проверка, содержит ли строка подстроку (регистронезависимая)
function Utilities.StringContains(str, substr)
    return string.find(string.lower(str), string.lower(substr)) ~= nil
end

-- 15. Разделение строки по разделителю
function Utilities.SplitString(str, delimiter)
    local result = {}
    for part in string.gmatch(str, "[^"..delimiter.."]+") do
        table.insert(result, part)
    end
    return result
end

-- 16. Проверка вероятности (вернет true с заданной вероятностью)
function Utilities.RollChance(probability)
    return math.random() <= probability
end

-- 17. Получение всех потомков с определенным тегом
function Utilities.GetDescendantsWithTag(parent, tagName)
    local collectionService = game:GetService("CollectionService")
    return collectionService:GetTagged(tagName)
end

-- 18. Троттлинг функции (вызов не чаще чем раз в delay секунд)
function Utilities.Throttle(func, delay)
    local lastCall = 0
    return function(...)
        local now = tick()
        if now - lastCall >= delay then
            lastCall = now
            return func(...)
        end
    end
end

-- 19. Дебаунс функции (вызов только после паузы в delay секунд)
function Utilities.Debounce(func, delay)
    local lastCall = 0
    return function(...)
        local now = tick()
        if now - lastCall >= delay then
            lastCall = now
            return func(...)
        end
        lastCall = now
    end
end

-- 20. Создание таймера с обратным отсчетом
function Utilities.CreateCountdown(duration, callback, interval)
    interval = interval or 1
    local remaining = duration
    local connection
    
    local function update()
        remaining = remaining - interval
        if remaining <= 0 then
            callback(0)
            connection:Disconnect()
        else
            callback(remaining)
        end
    end
    
    connection = game:GetService("RunService").Heartbeat:Connect(function()
        if remaining <= 0 then
            connection:Disconnect()
        else
            update()
        end
    end)
    
    return {
        Stop = function()
            connection:Disconnect()
        end,
        GetRemaining = function()
            return remaining
        end
    }
end

-- Пример использования функций
local function exampleUsage()
    -- 1. Генерация случайного числа
    local randomNum = Utilities.RandomRange(1, 100)
    print("Случайное число:", randomNum)
    
    -- 2. Проверка на простое число
    print("7 простое число?", Utilities.IsPrime(7))
    
    -- 3. Округление
    print("3.14159 округлено до 2 знаков:", Utilities.RoundDecimal(3.14159, 2))
    
    -- 4. Проверка радиуса
    local playerPos = Vector3.new(0, 0, 0)
    local targetPos = Vector3.new(5, 0, 0)
    print("В радиусе 10?", Utilities.IsInRadius(playerPos, targetPos, 10))
    
    -- 5. Конвертация времени
    print("125 секунд =", Utilities.SecondsToMinutes(125))
    
    -- 6. Генерация UID
    print("UID:", Utilities.GenerateUID(8))
    
    -- 20. Таймер обратного отсчета
    local timer = Utilities.CreateCountdown(10, function(remaining)
        print("Осталось:", remaining)
    end, 1)
end

-- Инициализация случайного seed
math.randomseed(tick())

return Utilities
