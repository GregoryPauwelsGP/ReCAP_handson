using { sap.capire.bookshop as my } from '../db/schema';
using { sap.common as common } from '@sap/cds/common';
service AdminService @(requires:'authenticated-user') { 
  entity Books as projection on my.Books;
  entity Authors as projection on my.Authors;
  entity Genres as projection on my.Genres;
  entity Currencies as projection on common.Currencies;

  // action Books.createBook(
  //   ID : Integer,
  //   title  : String(111),
  //   descr  : String(1111),
  //   author : Authors,
  //   //genre  : Genres,
  //   stock  : Integer,
  //   price  : Decimal(9,2),
  //   //currency : String(5),
  // ) returns Books;

  action Books.createBook(
    ID     :inCreateBook:ID,
    title  :inCreateBook:title,
    descr  :inCreateBook:descr,
    author :inCreateBook:author,
    genre  :inCreateBook:genre,
    stock  :inCreateBook:stock,
    price  :inCreateBook:price,
    currency :inCreateBook:currency,
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

}