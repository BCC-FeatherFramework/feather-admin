-- Staff money commands: /givemoney and /takemoney.
--
--   givemoney <server id|character UUID> <amount> [dollars|gold]   issue into the character's wallet
--   takemoney <server id|character UUID> <amount> [dollars|gold]   destroy from the character's wallet
--
-- A character UUID works while the character is offline (corrections). The journal
-- records the staff member's character as the actor (none for the server console).
--
-- Amounts are whole currency units with up to two decimals (12.50). Players need the
-- Admin owner capability economy.<currency>.add / .remove; the server console may
-- always use them. The Admin menu Economy screens stay disabled
-- (Config.identity.disabledActionPrefixes); these commands check the capability
-- directly. Economy asks the Core policy for economy.currency.issue/destroy as the
-- service principal feather-admin (configs/service_policy.lua), and each change is
-- recorded in the Admin audit outbox.

local settings = type(Config.money) == 'table' and Config.money or {}
if settings.enabled == false then return end

local CURRENCIES = { dollars = true, gold = true }

local function Reply(src, message)
    if src == 0 then return print('[feather-admin] ' .. message) end
    FeatherAdmin.Notify(src, message, 5000)
end

local function Wallet(characterId, currency)
    local wallets = exports['feather-economy']:EnsureCharacterWallets({ characterId = characterId })
    if type(wallets) ~= 'table' or not wallets.ok then return nil, wallets end
    for _, account in ipairs(wallets.value or {}) do
        if account.currency == currency then return account end
    end
    return nil
end

-- The target: a connected player's server id, or a character UUID (online or not).
local function Target(argument)
    local uuid = type(argument) == 'string' and argument:match(
        '^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$')
    if uuid then
        local provider = exports['feather-core']:GetProvider('character-profile', nil, 1)
        if type(provider) ~= 'table' or provider.ok ~= true then return nil, 'The character provider is unavailable.' end
        local profile = provider.value.implementation.GetProfile(uuid:lower())
        if type(profile) ~= 'table' or profile.ok ~= true or type(profile.value) ~= 'table' then
            return nil, 'No character has that UUID.'
        end
        local name = ('%s %s'):format(profile.value.firstName or '', profile.value.lastName or ''):gsub('^%s+', ''):gsub('%s+$', '')
        return { characterId = uuid:lower(), name = name ~= '' and name or uuid:lower() }
    end
    local source = FeatherAdmin.ValidTarget(argument)
    if not source then return nil end
    local session = exports['feather-core']:GetSessionContext(source)
    if type(session) ~= 'table' or not session.ok then
        return nil, ('Player %d has no active character.'):format(source)
    end
    return { characterId = session.value.characterId, name = GetPlayerName(source), source = source }
end

local function Format(minor, currency)
    return ('%d.%02d %s'):format(minor // 100, minor % 100, currency)
end

local function Run(src, args, operation)
    local command = operation == 'issue' and settings.giveCommand or settings.takeCommand
    local currency, amount = (args[3] or 'dollars'):lower(), tonumber(args[2])
    if args[1] == nil or not CURRENCIES[currency] or not amount or args[4] ~= nil then
        return Reply(src, ('Usage: /%s <server id|character UUID> <amount> [dollars|gold]'):format(command))
    end
    local minor = math.floor(amount * 100 + 0.5)
    local maximum = math.floor((tonumber(settings.maxAmount) or 100000) * 100)
    if amount <= 0 or math.abs(amount * 100 - minor) > 1e-6 or minor < 1 or minor > maximum then
        return Reply(src, ('Amount must be between 0.01 and %s.'):format(Format(maximum, currency)))
    end

    local action = ('economy.%s.%s'):format(currency, operation == 'issue' and 'add' or 'remove')
    if src ~= 0 and not FeatherAdmin.IsEntitled(src, action) then return FeatherAdmin.DenyAction(src) end

    local target, problem = Target(args[1])
    if not target then
        return Reply(src, problem or ('Usage: /%s <server id|character UUID> <amount> [dollars|gold]'):format(command))
    end
    local characterId = target.characterId
    local wallet = Wallet(characterId, currency)
    if not wallet then return Reply(src, 'Economy is unavailable or the wallet could not be opened.') end
    if operation == 'destroy' and (tonumber(wallet.balance) or 0) < minor then
        return Reply(src, ('%s only has %s.'):format(target.name, Format(tonumber(wallet.balance) or 0, currency)))
    end

    local reference = ('%s:%d:%d'):format(tostring(src), os.time(), GetGameTimer())
    local request = {
        accountId = wallet.accountId, currency = currency, amount = minor,
        reasonCode = operation == 'issue' and 'admin.grant' or 'admin.removal',
        referenceType = 'admin_command', referenceId = reference,
        idempotencyKey = 'admin-money:' .. operation .. ':' .. reference
    }
    -- No actorSource: Core then treats the call as the service principal feather-admin.
    -- The actor in the journal is the staff member's character (none for the console).
    local staff = src ~= 0 and exports['feather-core']:GetSessionContext(src) or nil
    local context = { correlationId = 'admin-money:' .. reference,
        actorCharacterId = type(staff) == 'table' and staff.ok and staff.value.characterId or nil }
    local result = operation == 'issue' and exports['feather-economy']:Issue(request, context)
        or exports['feather-economy']:Destroy(request, context)

    local subject = { characterId = characterId, name = target.name }
    local summary = ('%s %s wallet=%s'):format(operation, Format(minor, currency), wallet.accountId)
    if type(result) ~= 'table' or not result.ok then
        local code = type(result) == 'table' and result.code or 'invalid_result'
        AdminAudit.RecordTarget(src, 'economy.money.failed', subject, summary .. ' code=' .. tostring(code))
        return Reply(src, ('Money change failed (%s).'):format(tostring(code)))
    end
    AdminAudit.RecordTarget(src, operation == 'issue' and 'economy.money.give' or 'economy.money.take',
        subject, summary)

    local after = exports['feather-economy']:GetAccount({ accountId = wallet.accountId })
    local balance = type(after) == 'table' and after.ok and Format(after.value.balance, currency) or '?'
    Reply(src, ('%s %s %s %s. New balance: %s.'):format(
        operation == 'issue' and 'Gave' or 'Took', Format(minor, currency),
        operation == 'issue' and 'to' or 'from', target.name, balance))
    if target.source and target.source ~= src then
        FeatherAdmin.Notify(target.source, ('%s %s %s your wallet.'):format(
            operation == 'issue' and 'Staff added' or 'Staff removed', Format(minor, currency),
            operation == 'issue' and 'to' or 'from'), 5000)
    end
end

for _, entry in ipairs({ { settings.giveCommand, 'issue' }, { settings.takeCommand, 'destroy' } }) do
    if type(entry[1]) == 'string' and entry[1] ~= '' then
        RegisterCommand(entry[1], function(src, args)
            CreateThread(function()
                local ok, problem = pcall(Run, tonumber(src) or 0, args, entry[2])
                if not ok then
                    print('[feather-admin] ' .. entry[1] .. ' failed: ' .. tostring(problem))
                    Reply(tonumber(src) or 0, 'Money change failed.')
                end
            end)
        end, false)
    end
end
