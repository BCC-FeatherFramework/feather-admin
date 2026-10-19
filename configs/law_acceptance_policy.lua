-- Explicit Law action integration: qualified duty/commission policy by default.
-- Staff-only mode remains available explicitly without changing the fixed Admin
-- Authority catalog/migration IDs or assigning anyone a role. Law still checks
-- on-duty job, grade and commission; Justice additionally checks case membership.
Config.lawAcceptancePolicy = {
    enabled = true,
    mode = 'qualified', -- user decision: active duty + commission; no staff fallback
    requiredAdminAction = 'roles.assignment.manage',
    actions = {
        ['law.restraint.manage']=true, ['law.armory.issue']=true,
        ['law.search.inspect']=true, ['law.evidence.collect']=true,
        ['justice.charge.amend']=true,
        ['justice.ruling.record']=true, ['justice.ruling.view']=true,
        ['justice.sentence.impose']=true, ['justice.sentence.activate']=true, ['justice.sentence.modify']=true,
        ['justice.sentence.effect']=true, ['justice.sentence.progress']=true, ['justice.sentence.view']=true,
        ['justice.evidence.link']=true, ['justice.evidence.dispose']=true, ['justice.evidence.view']=true,
        ['justice.record.seal']=true, ['justice.record.expunge']=true, ['justice.case.view_sealed']=true,
        ['justice.audit.view']=true, ['justice.status.view']=true,
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
