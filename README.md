# ReCAP_handson
ReCAP hands on sessie
# Getting Started

Welcome to your new project.

It contains these folders and files, following our recommended project layout:

File or Folder | Purpose
---------|----------
`app/` | content for UI frontends goes here
`db/` | your domain models and data go here
`srv/` | your service models and code go here
`package.json` | project metadata and configuration
`readme.md` | this getting started guide


## Next Steps

- Open a new terminal and run `cds watch`
- (in VS Code simply choose _**Terminal** > Run Task > cds watch_)
- Start adding content, for example, a [db/schema.cds](db/schema.cds).


## Learn More

Learn more at https://cap.cloud.sap/docs/get-started/.




## 📚 Bookshop Project (SAP CAP)
This project demonstrates how to build a simple CAP (Cloud Application Programming) model with Node.js, including domain models, services, and custom logic.
________________________________________


🚀 1. Initialize the Project
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



🧩 2. Capture Domain Models
Create a new file named db/schema.cds and paste the following content:
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
________________________________________



🧠 3. Provide Services
After saving the model, cds watch will now display:
No service definitions found in loaded models.
Waiting for some to arrive...
We’ll now define two services:
•	AdminService — For administrators to manage Books and Authors.
•	CatalogService — For users to browse and order books under /browse.
Create the following files:
srv/admin-service.cds
using { sap.capire.bookshop as my } from '../db/schema';

service AdminService @(requires: 'authenticated-user') {
  entity Books as projection on my.Books;
  entity Authors as projection on my.Authors;
}
srv/cat-service.cds
using { sap.capire.bookshop as my } from '../db/schema';

service CatalogService {
  entity Books as projection on my.Books;
}
________________________________________



⚙️ 4. Add Custom Logic
While the generic CAP service provides CRUD operations automatically, you can add custom logic by placing .js files next to their corresponding .cds files.
Folder Structure
bookshop/
├─ db/
│  └─ schema.cds
├─ srv/
│  ├─ admin-service.cds
│  ├─ cat-service.cds
│  └─ cat-service.js
└─ package.json
________________________________________
🧑‍💻 5. Implement Service Logic
Create the file srv/cat-service.js and add custom event handlers:
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
________________________________________
🔄 6. Consuming Other Services
You can also connect to other CAP services from within event handlers.
Here’s an example that updates stock levels when an order is submitted:
const cds = require('@sap/cds')

class CatalogService extends cds.ApplicationService {
  async init() {
    const db = await cds.connect.to('db')
    const { Books } = db.entities

    // Handle order submissions
    this.on('submitOrder', async req => {
      const { book, quantity } = req.data

      const n = await UPDATE(Books, book)
        .with({ stock: { '-=': quantity } })
        .where({ stock: { '>=': quantity } })

      n > 0 || req.error(409, `${quantity} exceeds stock for book #${book}`)
    })

    // Add discount for overstocked books
    this.after('each', 'Books', book => {
      if (book.stock > 111) book.title += ` -- 11% discount!`
    })

    return super.init()
  }
}

module.exports = CatalogService

Before running the CAP project, you can seed initial data for your Authors and Books entities using CSV files. This helps quickly populate your database for testing and development.
________________________________________
📄 Step 1: Create Authors CSV
Create a file named:
db/data/sap.capire.bookshop-Authors.csv
Add the following content:
ID,name
101,Emily Brontë
107,Charlotte Brontë
150,Edgar Allen Poe
170,Richard Carpenter
Each row represents an author with a unique ID and name.
________________________________________
📄 Step 2: Create Books CSV
Create a file named:
db/data/sap.capire.bookshop-Books.csv
Add the following content:
ID,title,author_ID,stock
201,Wuthering Heights,101,12
207,Jane Eyre,107,11
251,The Raven,150,333
252,Eleonora,150,555
271,Catweazle,170,22
Each row represents a book with:
•	ID: unique identifier
•	title: book title
•	author_ID: links to an author in Authors.csv
•	stock: current stock quantity
________________________________________
⚡ Step 3: Load the CSV Data
When you start your CAP application with cds watch, these CSV files are automatically picked up and loaded into the corresponding database tables (Authors and Books).
This ensures your CAP project starts with ready-to-use data for testing services, UI, and custom actions.

________________________________________
🧪 7. Run the Application
Start the watcher again (if it’s not already running):
cds watch
Open the provided URL in your browser — you’ll see your CAP Bookshop services in action.
________________________________________
✅ Summary
You’ve now built a complete CAP Bookshop project featuring:
•	Domain models (db/schema.cds)
•	Services (srv/*.cds)
•	Custom logic (srv/*.js)


🆕 8. Adding Custom Actions
To extend the functionality of the CAP Bookshop application, we’ll add a custom action that allows administrators to create new books via a dedicated API endpoint.
📄 Step 1: Define the Action in srv/admin-service.cds
Open your srv/admin-service.cds file and add the following action inside the AdminService definition:
using { sap.capire.bookshop as my } from '../db/schema';

service AdminService @(requires: 'authenticated-user') {
  entity Books as projection on my.Books;
  entity Authors as projection on my.Authors;

  // --- Custom Action ---
  action Books.createBook(
      ID      : Integer,
      title   : String(111),
      descr   : String(1111),
      stock   : Integer,
      price   : Decimal(9,2)
      // author   : Authors,
      // genre    : Genres,
      // currency : String(5),
  ) returns Books;
}
💡 The commented lines can be activated later if you want to link authors, genres, or currencies when creating books.
________________________________________
⚙️ Step 2: Implement the Action Logic in srv/admin-service.js
Next, create or open the srv/admin-service.js file (it should be placed next to admin-service.cds).
Add the following implementation:
const cds = require('@sap/cds')

class AdminService extends cds.ApplicationService {
  init() {
    const { Books } = cds.entities('AdminService')

    // --- Custom Action Implementation ---
    this.on('Books.createBook', async (req) => {
      const newBook = req.data
      await INSERT.into(Books).entries(newBook)
      return newBook
    })

    return super.init()
  }
}

module.exports = AdminService
________________________________________
🧪 Step 3: Test the Action
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
✅ Step 4: Verify the Results
You can check the new entry by querying the Books entity directly:
curl http://localhost:4004/admin/Books
or by visiting the AdminService endpoint in your browser.
________________________________________
🧾 Summary
You’ve successfully extended your CAP project with a custom action that:
•	Defines a new API (Books.createBook) in the service layer.
•	Implements server-side logic in admin-service.js.
•	Enables administrators to create new books through HTTP POST calls.

🎨 9. Adding a Fiori UI (List Report Page)
After creating and testing the backend services, let’s add a Fiori Elements UI to manage and visualize book data from our CAP project.
We’ll use the Fiori Application Generator built into SAP Business Application Studio (BAS) or Visual Studio Code with the SAP Fiori tools extension.
________________________________________
🧭 Step 1: Open the Application Generator
1.	Open your CAP project folder (e.g., bookshop) in VS Code or SAP BAS.
2.	Press Ctrl + Shift + P (or Cmd + Shift + P on Mac).
3.	Choose Fiori: Open Application Generator from the command palette.
4.	Select the following options:

o	Template: Object Page / List Report Page
o	Data Source: Use a local CAP project
o	Main Entity: Books
o	Service: CatalogService or AdminService (depending on your setup)
o	Application Title: Bookshop UI
Click Finish to generate the app.
________________________________________
🔄 Step 2: Restart Your CAP Application
Restart your CAP server so that it picks up the new Fiori UI module:
cds watch
When the server restarts, you’ll notice some changes:
•	A new folder, usually named app/bookshop, has been created.
•	The package.json file now includes Fiori build dependencies.
•	The xs-app.json (for routing) and ui5.yaml configuration files are added automatically.
________________________________________
🧱 Step 3: Explore the UI Structure
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
🪄 Step 4: Add a Custom Action Button to the Table
1.	In your Application Info panel, click “Open Page Map”.
This opens the Page Editor view for your Fiori app.
2.	Select the Books List Report Page (or the page showing your book table).
3.	Navigate to the Table section and click the “+” button to add a new action.
4.	Under Add Actions, you’ll find your custom action
→ Books.createBook
5.	Select this action and modify its Label property (for example, change it to:
“Add New Book” or “Create Book Entry”).
________________________________________
👀 Step 5: Review the Changes
Once the action is added:
•	Check your manifest.json — it now includes metadata for your new button and its binding to the CAP action.
•	The Fiori app automatically adds a toolbar button in your Books table UI.
•	When pressed, it calls your custom CAP action (Books.createBook) defined earlier in admin-service.cds and admin-service.js.
________________________________________
🧩 Step 6: Run and Test the Fiori App
From your CAP project root, start the development server again:
cds watch
Then open the provided URL (usually http://localhost:4004) and select your Fiori App.
You should now see:
•	A Book List table populated with data from your CAP service.
•	A button for your custom action (e.g., “Add New Book”) on the toolbar.
Clicking the button triggers your backend action and inserts a new book record.
________________________________________
✅ Summary
You’ve now successfully:
•	Generated a Fiori List Report Page using the Application Generator
•	Integrated it with your CAP service layer
•	Added a custom UI button that calls your Books.createBook action
•	Verified that UI and backend work seamlessly together
⚡ 10. Adding Stock Criticality with Virtual Field
To provide a visual indicator of stock levels in your Books table, we’ll add a virtual field stockCriticality to the Books entity and calculate its value dynamically in the service layer.
________________________________________
📝 Step 1: Update the Books Entity
Open db/schema.cds and add the new virtual field:
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
💡 Virtual fields are not stored in the database but calculated dynamically at runtime.
________________________________________
⚙️ Step 2: Add Logic in Service Implementation
Open srv/cat-service.js (or the service handling Books) and add logic to populate stockCriticality after reading Books:
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
This ensures that every time Books are read, the stockCriticality field is dynamically calculated based on the stock value.
________________________________________
🎨 Step 3: Configure Criticality in the Fiori UI
1.	Open the Page Editor in your Fiori application.
(Application Info → Open Page Map)
2.	Select the Books table and locate the Stock field.
3.	Configure the Criticality property:
o	Bind it to the stockCriticality field you just added.
o	Enable “With Icon” under Criticality Representation.
4.	Save and refresh your application.
________________________________________
👀 Step 4: Observe the Result
When you run your CAP + Fiori app:
•	The Books table now displays the stock values with color-coded indicators based on stock levels:
o	High stock (>100) → Criticality 3
o	Medium stock (10–50) → Criticality 2
o	Low stock (<10) → Criticality 1
•	The icon representation makes it easy to quickly identify low, medium, or high stock books.
________________________________________
✅ Summary
You’ve now successfully:
•	Added a virtual field stockCriticality to the Books entity
•	Populated it dynamically in the after READ event handler
•	Configured the Fiori UI to visually display stock criticality with color-coded icons
This improves usability by giving end-users a quick visual insight into stock levels.


🧩 Adding Value Help for Authors in the Create Book Popup

To enable Value Help (F4 help) for the Authors field in the popup used to create a book, several additions were made.

1. Create Book Popup

The popup is used to create a new book using the action createBook on the Books entity within admin-service.cds.

2. Add Annotations for Author Value Help

To display a dropdown list of available authors in the popup, the following annotation must be added to your annotation.cds file:

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


This annotation connects the author field in the popup to the Authors entity, allowing users to select an author by name while binding the corresponding ID value.

3. Update the Books Entity

Ensure that the author property in your Books entity is not commented out so it can be properly linked and used by the value help.


