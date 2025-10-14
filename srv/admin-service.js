const cds = require('@sap/cds')
const { SELECT } = require('@sap/cds/lib/ql/cds-ql')

module.exports = class AdminService extends cds.ApplicationService { init() {

  const { Books, Authors } = cds.entities('AdminService')

  this.b             efore (['CREATE', 'UPDATE'], Books, async (req) => {
    console.log('Before CREATE/UPDATE Books', req.data)
  })
  this.after ('READ', Books, async (books, req) => {
      const data = Array.isArray(books) ? books : [books];
      console.log("data"+data);
      for (const book of data) {
        let totalRating = 0;
        let ratingCount = 0;
        if (!book.stock) {
          const result = await SELECT.one.from(cds.entities.Books).where({ ID: book.ID }).columns('stock');
          book.stock = result.stock;
        }
        if (book.stock > 100) {
          book.stockCriticality = 3;
        } else if (book.stock >= 10 && book.stock <= 50) {
          book.stockCriticality = 2;
        } else if (book.stock < 10) {
          book.stockCriticality = 1;
        }

        const ratings = await SELECT.from(cds.entities.Ratings).where({book: book.ID});

        if (ratings && ratings.length > 0) {
          for (const rating of ratings) {
            totalRating += rating.stars;
            ratingCount++;
          }
        }
        book.averageRating = ratingCount > 0 ? (totalRating / ratingCount).toFixed(1) : null;
      }
      console.log("books: "+ JSON.stringify(books))
      return books;
  })
  this.before (['CREATE', 'UPDATE'], Authors, async (req) => {
    console.log('Before CREATE/UPDATE Authors', req.data)
  })
  this.after ('READ', Authors, async (authors, req) => {
    console.log('After READ Authors', authors)
  })

  
  this.on('Books.createBook', async (req) => {
    const newBook = {};
    newBook.ID = req.data.ID;
    newBook.title = req.data.title;
    newBook.descr = req.data.descr;
    newBook.author = { ID: req.data.author };
    newBook.genre = { ID: req.data.genre };
    newBook.stock = req.data.stock;
    newBook.price = req.data.price;
    newBook.currency = { code: req.data.currency };
    console.log('Creating new book:', newBook);
    await INSERT.into(Books).entries(newBook);
    return newBook;
  });


  return super.init()
}}
