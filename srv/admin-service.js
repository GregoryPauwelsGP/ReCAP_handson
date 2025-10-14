const cds = require('@sap/cds')

module.exports = class AdminService extends cds.ApplicationService { init() {

  const { Books, Authors } = cds.entities('AdminService')

  this.before (['CREATE', 'UPDATE'], Books, async (req) => {
    console.log('Before CREATE/UPDATE Books', req.data)
  })
  this.after ('READ', Books, async (books, req) => {
      const data = Array.isArray(books) ? books : [books];
      console.log("data"+data);
      for (const book of data) {
        if (book.stock > 100) {
          book.stockCriticality = 3;
        } else if (book.stock >= 10 && book.stock <= 50) {
          book.stockCriticality = 2;
        } else if (book.stock < 10) {
          book.stockCriticality = 1;
        }
      }
      console.log("books: "+books)
      return books;
  })
  this.before (['CREATE', 'UPDATE'], Authors, async (req) => {
    console.log('Before CREATE/UPDATE Authors', req.data)
  })
  this.after ('READ', Authors, async (authors, req) => {
    console.log('After READ Authors', authors)
  })

  
  this.on('Books.createBook', async (req) => {
    const newBook = req.data;
    await INSERT.into(Books).entries(newBook);
    return newBook;
  });


  return super.init()
}}
