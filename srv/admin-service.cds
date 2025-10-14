using { sap.capire.bookshop as my } from '../db/schema';
service AdminService @(requires:'authenticated-user') { 
  entity Books as projection on my.Books;
  entity Authors as projection on my.Authors;
  entity Genres as projection on my.Genres;

  action Books.createBook(
      ID : Integer,
  title  : String(111),
  descr  : String(1111),
  //author : Authors,
  //genre  : Genres,
  stock  : Integer,
  price  : Decimal(9,2),
  //currency : String(5),
  ) returns Books;

}