local QBCore = exports['qb-core']:GetCoreObject()

-- We check for the log table and create it if not exists
CreateThread(function()
local tablecheck = exports.oxmysql:executeSync('SHOW TABLES LIKE @logsraw',{['@logsraw'] = 'logsraw',})
  if tablecheck[1] ~= 'logsraw' then
     exports.oxmysql:execute("CREATE TABLE IF NOT EXISTS `logsraw` ( `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT, `name` VARCHAR(100) NULL DEFAULT NULL COLLATE 'utf8mb4_0900_ai_ci', `title` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_0900_ai_ci', `color` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_0900_ai_ci', `message` TEXT NULL DEFAULT NULL COLLATE 'utf8mb4_0900_ai_ci', `tageveryone` TINYINT(1) NULL DEFAULT '0', `parsed` TINYINT(1) NOT NULL DEFAULT '0', `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, PRIMARY KEY (`id`) USING BTREE, INDEX `created_at` (`created_at`) USING BTREE, INDEX `name` (`name`) USING BTREE, INDEX `tageveryone` (`tageveryone`) USING BTREE , INDEX `parsed` (`parsed`)  )    COLLATE='utf8mb4_0900_ai_ci'    ENGINE=InnoDB    ",{})
  end
end)

RegisterNetEvent('qb-log:server:CreateLog', function(name, title, color, message, tagEveryone) 
    local tag = tagEveryone or false
    local webHook = Config.Webhooks[name] or Config.Webhooks['default']
    local embedData = {
 {
            ['title'] = title,
            ['color'] = Config.Colors[color] or Config.Colors['default'],
            ['footer'] = {
                ['text'] = os.date('%c'),
            },
            ['description'] = message,
            ['author'] = {
                ['name'] = 'QBCore Logs',
                ['icon_url'] = 'https://media.discordapp.net/attachments/870094209783308299/870104331142189126/Logo_-_Display_Picture_-_Stylized_-_Red.png?width=670&height=670',
            },
        }
    }
    -- Insert into Database for later use
    exports.oxmysql:execute('INSERT INTO logsraw (name ,title, color ,message, tageveryone) VALUES (@name ,@title, @color ,@message, @tageveryone)',
    {['@name'] = name ,['@title'] = title, ['@color'] = color ,['@message'] = message, ['@tageveryone'] = tageveryone, })
    -- Send to discord webhook
    PerformHttpRequest(webHook, function(err, text, headers) end, 'POST', json.encode({ username = 'QB Logs', embeds = embedData}), { ['Content-Type'] = 'application/json' })
    Citizen.Wait(100)
    if tag then
        PerformHttpRequest(webHook, function(err, text, headers) end, 'POST', json.encode({ username = 'QB Logs', content = '@everyone'}), { ['Content-Type'] = 'application/json' })
    end
end)

QBCore.Commands.Add('testwebhook', 'Test Your Discord Webhook For Logs (God Only)', {}, false, function(source, args)
    TriggerEvent('qb-log:server:CreateLog', 'testwebhook', 'Test Webhook', 'default', 'Webhook setup successfully')
end, 'god')
