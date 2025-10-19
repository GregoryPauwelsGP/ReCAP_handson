
# 📚 Bookshop Project (SAP CAP)
This project demonstrates how to build a simple CAP (Cloud Application Programming) model with Node.js, including domain models, services, and custom logic.


## 1. Basic setup

### Initialize the Project
Create a new project using the CDS (Core Data Services) CLI:
```
cds init bookshop
cd bookshop
```

Then, start the project watcher:
```
cds watch
```

You’ll see: 
```
No models found in db/, srv/, app/, schema, services.
Waiting for some to arrive...
```

Let’s fix that by adding our domain models.
________________________________________



### Capture Domain Models
Create a new file named db/schema.cds and paste the following content:
```
using { Currency, managed, sap } from '@sap/cds/common';

namespace sap.capire.bookshop;

entity Books : managed {
  key ID : Integer;
  title     : localized String(111);
  descr     : localized String(1111);
  author    : Association to Authors;
  genre     : Association to Genres;
  stock     : Integer;
  price     : Decimal(9,2);
  currency  : Currency;
}

entity Authors : managed {
  key ID : Integer;
  name   : String(111);
  books  : Association to many Books on books.author = $self;
}

/** Hierarchically organized Code List for Genres */
entity Genres : sap.common.CodeList {
  key ID   : Integer;
  parent   : Association to Genres;
  children : Composition of many Genres on children.parent = $self;
}
```
________________________________________



### Provide Services
After saving the model, cds watch will now display:
```
No service definitions found in loaded models.
Waiting for some to arrive...
```

We’ll now define two services:
•	AdminService — For administrators to manage Books and Authors.
•	CatalogService — For users to browse and order books under /browse.

Create the following files:

srv/admin-service.cds
```
using { sap.capire.bookshop as my } from '../db/schema';

service AdminService @(requires: 'authenticated-user') {
  entity Books as projection on my.Books;
  entity Authors as projection on my.Authors;
}
```

srv/cat-service.cds
```
using { sap.capire.bookshop as my } from '../db/schema';
service CatalogService @(path:'/browse') { 

  @readonly entity Books as select from my.Books {*,
    author.name as author
  } excluding { createdBy, modifiedBy };

  @requires: 'authenticated-user'
  action submitOrder (book: Books:ID, quantity: Integer);
}
```
________________________________________



### Add Custom Logic
While the generic CAP service provides CRUD operations automatically, you can add custom logic by placing .js files next to their corresponding .cds files.

Folder Structure:
bookshop/
├─ db/
│  └─ schema.cds
├─ srv/
│  ├─ admin-service.cds
│  ├─ cat-service.cds
└─ package.json
________________________________________


### Implement Service Logic
Create the file srv/cat-service.js and add custom event handlers:

```
const cds = require('@sap/cds')

class CatalogService extends cds.ApplicationService {
  init() {
    const { Books } = cds.entities('CatalogService')

    // Add discount for overstocked books
    this.after('each', Books, book => {
      if (book.stock > 111) {
        book.title += ` -- 11% discount!`
      }
    })
    return super.init()
  }
}
module.exports = CatalogService
```

Create file admin-service.js

```
const cds = require('@sap/cds')

module.exports = class AdminService extends cds.ApplicationService { init() {

  const { Books, Authors } = cds.entities('AdminService')

  this.before (['CREATE', 'UPDATE'], Books, async (req) => {
    console.log('Before CREATE/UPDATE Books', req.data)
  })
  this.after ('READ', Books, async (books, req) => {
  })
  this.before (['CREATE', 'UPDATE'], Authors, async (req) => {
    console.log('Before CREATE/UPDATE Authors', req.data)
  })
  this.after ('READ', Authors, async (authors, req) => {
    console.log('After READ Authors', authors)
  })


  return super.init()
}}
```
________________________________________



### Create Authors CSV
Create a file named:
db/data/sap.capire.bookshop-Authors.csv
Add the following content:
```
ID,name
101,Emily Brontë
107,Charlotte Brontë
150,Edgar Allen Poe
170,Richard Carpenter
```
Each row represents an author with a unique ID and name.
________________________________________


### Create Books CSV
Create a file named:
db/data/sap.capire.bookshop-Books.csv

Add the following content:
```
ID,title,author_ID,stock
201,Wuthering Heights,101,12
207,Jane Eyre,107,11
251,The Raven,150,333
252,Eleonora,150,555
271,Catweazle,170,22
```
Each row represents a book with:
•	ID: unique identifier
•	title: book title
•	author_ID: links to an author in Authors.csv
•	stock: current stock quantity
________________________________________



### Load the CSV Data
When you start your CAP application with cds watch, these CSV files are automatically picked up and loaded into the corresponding database tables (Authors and Books).
This ensures your CAP project starts with ready-to-use data for testing services, UI, and custom actions.

________________________________________



### Run the Application
Start the watcher again (if it’s not already running):
```
cds watch
```
Open the provided URL in your browser — you’ll see your CAP Bookshop services in action.
________________________________________


### Summary
You’ve now built a complete CAP Bookshop project featuring:
•	Domain models (db/schema.cds)
•	Services (srv/*.cds)
•	Custom logic (srv/*.js)

________________________________________


## 2. Custom action

### Adding Custom Actions
To extend the functionality of the CAP Bookshop application, we’ll add a custom action that allows administrators to create new books via a dedicated API endpoint.


### Define the Action in srv/admin-service.cds
Open your srv/admin-service.cds file and add the following action and type inside the AdminService definition:
```
  action Books.createBook(
    ID     :inCreateBook:ID,
    title  :inCreateBook:title,
    descr  :inCreateBook:descr,
    author :inCreateBook:author,
    genre  :inCreateBook:genre,
    stock  :inCreateBook:stock,
    price  :inCreateBook:price,
    currency : inCreateBook:currency,
  ) returns Books;

    type inCreateBook :{
    ID      : Integer;
    title   : String;
    descr   : String;
    author  : Integer;
    genre   : Integer;
    stock   : Integer;
    price   : Decimal(9,2);
    currency : String;
  }
```
________________________________________



### Implement the Action Logic in srv/admin-service.js
Next, open the srv/admin-service.js file.
Add the following implementation:

```
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

```
________________________________________



### Test the Action
1.	Make sure your CAP server is running:
2.	cds watch
3.	Open the AdminService endpoint (e.g., http://localhost:4004/admin/Books) in your browser or test tool.
4.	Use Postman or curl to call your new action:
Example using curl
curl -X POST \
http://localhost:4004/admin/Books/createBook \
-H "Content-Type: application/json" \
-d '{
  "ID": 101,
  "title": "New CAP Adventures",
  "descr": "A practical guide to CAP with Node.js",
  "stock": 50,
  "price": 29.99
}'
5.	You should get a JSON response containing the created book record.
________________________________________



### Verify the Results
You can check the new entry by querying the Books entity directly:
curl http://localhost:4004/admin/Books
or by visiting the AdminService endpoint in your browser.

________________________________________



### Summary
You’ve successfully extended your CAP project with a custom action that:
•	Defines a new API (Books.createBook) in the service layer.
•	Implements server-side logic in admin-service.js.
•	Enables administrators to create new books through HTTP POST calls.
________________________________________


## 3. Adding Fiori UI
🎨 9. Adding a Fiori UI (List Report Page)
After creating and testing the backend services, let’s add a Fiori Elements UI to manage and visualize book data from our CAP project.
We’ll use the Fiori Application Generator built into  Visual Studio Code with the SAP Fiori tools extension.

________________________________________



### Open the Application Generator
1.	Open your CAP project folder (e.g., bookshop) in VS Code.
2.	Press Ctrl + Shift + P (or Cmd + Shift + P on Mac).
3.	Choose Fiori: Open Application Generator from the command palette.
4.	Select the following options:

o	Template: List Report Page
o	Data Source: Use a local CAP project
o	Main Entity: Books
o	Service: AdminService
o	Application Title: Bookshop UI
Click Finish to generate the app.
________________________________________



### Restart Your CAP Application
Restart your CAP server so that it picks up the new Fiori UI module:
cds watch
When the server restarts, you’ll notice some changes:
•	A new folder, usually named app/bookshop, has been created.
•	The package.json file now includes Fiori build dependencies.
•	The xs-app.json (for routing) and ui5.yaml configuration files are added automatically.
________________________________________



### Explore the UI Structure
The generated Fiori app typically looks like this:
bookshop/
├─ app/
│  └─ bookshop/
│     ├─ webapp/
│     │  ├─ manifest.json
│     │  ├─ annotations.cds
│     │  ├─ pages/
│     │  └─ ...
│     └─ package.json
├─ srv/
│  ├─ admin-service.cds
│  ├─ admin-service.js
│  ├─ cat-service.cds
│  └─ cat-service.js
└─ db/
   └─ schema.cds
________________________________________


## 4. Add button in UI for custom action
### Add a Custom Action Button to the Table
1.	In your Application Info panel, click “Open Page Map”.
This opens the Page Editor view for your Fiori app.
2.	Select the Books List Report Page (or the page showing your book table).
3.	Navigate to the Table section and click the “+” button to add a new action to the toolbar.
4.	Under Add Actions, you’ll find your custom action
→ Books.createBook
5.	Select this action and modify its Label property (for example, change it to:
“Add New Book” or “Create Book Entry”).
________________________________________



### Review the Changes
Once the action is added:
•	Check your manifest.json — it now includes metadata for your new button and its binding to the CAP action.
•	The Fiori app automatically adds a toolbar button in your Books table UI.
•	When pressed, it calls your custom CAP action (Books.createBook) defined earlier in admin-service.cds and admin-service.js.
________________________________________



### Run and Test the Fiori App
From your CAP project root, start the development server again:
cds watch
Then open the provided URL (usually http://localhost:4004) and select your Fiori App.
You should now see:
•	A Book List table populated with data from your CAP service.
•	A button for your custom action (e.g., “Add New Book”) on the toolbar.
Clicking the button triggers your backend action and inserts a new book record.
________________________________________




### Summary
You’ve now successfully:
•	Generated a Fiori List Report Page using the Application Generator
•	Integrated it with your CAP service layer
•	Added a custom UI button that calls your Books.createBook action
•	Verified that UI and backend work seamlessly together

________________________________________



## 5. Adding Stock Criticality with Virtual Field
To provide a visual indicator of stock levels in your Books table, we’ll add a virtual field stockCriticality to the Books entity and calculate its value dynamically in the service layer.

### Update the Books Entity
Open db/schema.cds and add the new virtual field:
```
entity Books : managed {
  key ID      : Integer;
  title       : localized String(111);
  descr       : localized String(1111);
  author      : Association to Authors;
  genre       : Association to Genres;
  stock       : Integer;
  price       : Decimal(9,2);
  
  // Virtual field for stock criticality
  virtual stockCriticality : Int16;
}
```


💡 Virtual fields are not stored in the database but calculated dynamically at runtime.
________________________________________



### Change representation of the stock in the UI

Open srv/cat-service.js (or the service handling Books) and add logic to populate stockCriticality after reading Books:
```
this.after('READ', Books, async (books, req) => {
  const data = Array.isArray(books) ? books : [books];

  for (const book of data) {
    if (book.stock > 100) {
      book.stockCriticality = 3;
    } else if (book.stock >= 10 && book.stock <= 50) {
      book.stockCriticality = 2;
    } else if (book.stock < 10) {
      book.stockCriticality = 1;
    }
  }

  return books;
});
```

This ensures that every time Books are read, the stockCriticality field is dynamically calculated based on the stock value.
________________________________________



### Configure Criticality in the Fiori UI
1.	Open the Page Editor in your Fiori application.
(Application Info → Open Page Map)
2.	Select the Books table and locate the Stock field.
3.	Configure the Criticality property:
o	Bind it to the stockCriticality field you just added.
o	Enable “With Icon” under Criticality Representation.
4.	Save and refresh your application.
________________________________________



### Observe the Result
When you run your CAP + Fiori app:
•	The Books table now displays the stock values with color-coded indicators based on stock levels:
o	High stock (>100) → Criticality 3
o	Medium stock (10–50) → Criticality 2
o	Low stock (<10) → Criticality 1
•	The icon representation makes it easy to quickly identify low, medium, or high stock books.


### Summary
You’ve now successfully:
•	Added a virtual field stockCriticality to the Books entity
•	Populated it dynamically in the after READ event handler
•	Configured the Fiori UI to visually display stock criticality with color-coded icons
This improves usability by giving end-users a quick visual insight into stock levels.

________________________________________



## 6. Value help 
🧩 Adding Value Help for Authors in the Create Book Popup

To enable Value Help (F4 help) for the Authors field in the popup used to create a book, several additions were made.

### Add Annotations for Author Value Help

To display a dropdown list of available authors in the popup, the following annotation must be added to your annotation.cds file in your app folder:
```
annotate service.inCreateBook with {
    author @Common.ValueList : {
        $Type : 'Common.ValueListType',
        CollectionPath : 'Authors',
        Parameters : [
            {
                $Type : 'Common.ValueListParameterInOut',
                LocalDataProperty : author,
                ValueListProperty : 'ID',
            },
            {
                $Type : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'name',
            },
        ],
    };
};
```

This annotation connects the author field in the popup to the Authors entity, allowing users to select an author by name while binding the corresponding ID value.

### Update the Books Entity

Ensure that the author property in your Books entity is not commented out so it can be properly linked and used by the value help.


