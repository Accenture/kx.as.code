describe('kx.as.code portal', () => {
  it('welcome-page loaded', () => {
    cy.visit(Cypress.env('EXTERNAL_URL'))
    cy.contains('Transfer Knowledge as Code - All in One VM.')
  })
})