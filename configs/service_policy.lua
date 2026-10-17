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
        -- Sale back to the housing agent and furniture sell-back create money.
        ['bcc-housing'] = {
            ['economy.currency.issue']=true
        },
        -- Horse sales to the stable and to trainers (feather-economy IssueReasons).
        ['bcc-stables'] = {
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
    ['feather-contracts'] = {
        -- Monthly property tax and rent obligations, cancelled when staff delete a house.
        ['bcc-housing'] = {
            ['contracts.obligation.issue']=true,
            ['contracts.obligation.cancel']=true,
            ['contracts.obligation.default']=true
        }
    },
    ['feather-property'] = {
        -- Houses and hotel rooms: registration, owners and tenants.
        ['bcc-housing'] = {
            ['property.property.manage']=true,
            ['property.interest.manage']=true
        }
    },
    ['feather-jobs'] = {
        -- Shared job types, grades, and member assignments/duty.
        ['bcc-society'] = {
            ['jobs.definition.manage']=true,
            ['jobs.assignment.manage']=true
        }
    },
    ['feather-licenses'] = {
        -- Licensing office: its licence kinds, issuing, renewing and revoking.
        ['bcc-documents'] = {
            ['licenses.definition.manage']=true,
            ['licenses.issue']=true,
            ['licenses.revoke']=true
        }
    }
}
