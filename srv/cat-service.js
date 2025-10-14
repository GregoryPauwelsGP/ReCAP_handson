const cds = require('@sap/cds')

module.exports = class CatalogService extends cds.ApplicationService { init() {

  const { Books } = cds.entities('CatalogService')

  this.before (['CREATE', 'UPDATE'], Books, async (req) => {
    console.log('Before CREATE/UPDATE Books', req.data)
  })
  this.after ('READ', Books, async (books, req) => {
    console.log('After READ Books', books)
  })

  this.on ('submitOrder', async (req) => {
    console.log('On submitOrder', req.data)
  })

  return super.init()
}}
