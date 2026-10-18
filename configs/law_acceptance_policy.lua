-- Explicit staging integration, NOT the final officer/judge authorization model.
-- Reuses an existing owner-only entitlement without changing the fixed Admin
-- Authority catalog/migration IDs or assigning anyone a role. Law still checks
-- on-duty job, grade and commission; Justice additionally checks case membership.
Config.lawAcceptancePolicy = {
    enabled = true,
    requiredAdminAction = 'roles.assignment.manage',
    actions = {
        ['justice.definition.view']=true,
        ['justice.case.open']=true, ['justice.case.view']=true,
        ['justice.case.update']=true, ['justice.case.transition']=true,
        ['justice.party.view']=true, ['justice.party.manage']=true,
        ['justice.charge.view']=true, ['justice.charge.propose']=true,
        ['justice.charge.file']=true, ['justice.charge.dispose']=true,
        ['justice.warrant.view']=true, ['justice.warrant.draft']=true,
        ['justice.warrant.issue']=true, ['justice.warrant.serve']=true,
        ['justice.warrant.recall']=true, ['justice.warrant.quash']=true,
        ['justice.citation.view']=true, ['justice.citation.issue']=true, ['justice.citation.cancel']=true,
        ['justice.custody.view']=true, ['justice.custody.book']=true, ['justice.custody.release']=true
    }
}
