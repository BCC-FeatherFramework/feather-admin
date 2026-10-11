-- Server-only policy grants. No wildcards, staff-role fallback, or client actors.
-- The broker caller authenticates the delegated subject.resource principal.
Config.servicePolicy = {
    ['feather-organizations'] = {
        ['feather-shops'] = {
            ['organizations.organization.create']=true,
            ['organizations.organization.update']=true
        },
        ['feather-organizations'] = {
            ['organizations.organization.create']=true,
            ['organizations.organization.update']=true,
            ['organizations.organization.suspend']=true,
            ['organizations.organization.dissolve']=true,
            ['organizations.relationship.manage']=true,
            ['organizations.interest.manage']=true
        },
        ['feather-admin'] = {
            ['organizations.organization.create']=true,
            ['organizations.organization.update']=true,
            ['organizations.organization.suspend']=true,
            ['organizations.organization.dissolve']=true,
            ['organizations.relationship.manage']=true,
            ['organizations.interest.manage']=true
        },
        -- One bank organization per branch: create and update.
        ['bcc-banks'] = {
            ['organizations.organization.create']=true,
            ['organizations.organization.update']=true
        },
        -- One business organization per society: create, activate/rename, dissolve.
        ['bcc-society'] = {
            ['organizations.organization.create']=true,
            ['organizations.organization.update']=true,
            ['organizations.organization.dissolve']=true
        }
    },
    ['feather-economy'] = {
        -- Bank supply allow-listed in feather-economy Config.BankSupply
        -- (bank.migration.import, bank.reserve.funding). Banks never destroy currency.
        ['bcc-banks'] = {
            ['economy.currency.issue']=true
        },
        -- Staff /givemoney and /takemoney (money_commands.lua), owner capability checked first.
        ['feather-admin'] = {
            ['economy.currency.issue']=true,
            ['economy.currency.destroy']=true
        }
    },
    ['feather-assets'] = {
        -- Horse ownership and transfers for stables.
        ['bcc-stables'] = {
            ['assets.asset.manage']=true,
            ['assets.ownership.transfer']=true
        }
    },
    ['feather-jobs'] = {
        -- Shared job types, grades, and member assignments/duty.
        ['bcc-society'] = {
            ['jobs.definition.manage']=true,
            ['jobs.assignment.manage']=true
        }
    }
}
