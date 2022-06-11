describe('kx.as.code portal', () => {
  it('welcome-page loaded', () => {
    cy.visit('http://localhost:3000')
    cy.contains('Transfer Knowledge as Code - All in One VM.')
  })
})