using AdminService as service from '../../srv/admin-service';
annotate service.Books with @(
    UI.FieldGroup #GeneratedGroup : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Label : 'ID',
                Value : ID,
            },
            {
                $Type : 'UI.DataField',
                Label : '{i18n>Title}',
                Value : title,
            },
            {
                $Type : 'UI.DataField',
                Label : '{i18n>Description}',
                Value : descr,
            },
            {
                $Type : 'UI.DataField',
                Label : '{i18n>Author}',
                Value : author_ID,
            },
            {
                $Type : 'UI.DataField',
                Label : '{i18n>Genre}',
                Value : genre_ID,
            },
            {
                $Type : 'UI.DataField',
                Label : '{i18n>Stock}',
                Value : stock,
            },
            {
                $Type : 'UI.DataField',
                Label : '{i18n>Price}',
                Value : price,
            },
        ],
    },
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneratedFacet1',
            Label : 'General Information',
            Target : '@UI.FieldGroup#GeneratedGroup',
        },
    ],
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Label : 'ID',
            Value : ID,
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>Title}',
            Value : title,
            @UI.Importance : #High,
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>Description}',
            Value : descr,
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action : 'AdminService.EntityContainer/Books_createBook',
            Label : 'Create Book',
        },
        {
            $Type : 'UI.DataFieldForAnnotation',
            Target : 'author/@Communication.Contact#contact',
            Label : '{i18n>Author}',
            @UI.Importance : #High,
        },
        {
            $Type : 'UI.DataField',
            Value : genre.name,
            Label : '{i18n>Genre}',
            @UI.Importance : #High,
        },
        {
            $Type : 'UI.DataFieldForAnnotation',
            Target : '@UI.DataPoint#averageRating1',
            Label : '{i18n>Rating}',
            @UI.Importance : #High,
        },
        {
            $Type : 'UI.DataField',
            Value : stock,
            Label : '{i18n>Stock}',
            Criticality : stockCriticality,
            CriticalityRepresentation : #WithIcon,
            @UI.Importance : #High,
        },
    ],
    UI.DataPoint #rating : {
        $Type : 'UI.DataPointType',
        Value : averageRating,
        Title : 'averageRating',
        TargetValue : 5,
        Visualization : #Rating,
    },
    UI.HeaderFacets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'averageRating',
            Target : '@UI.DataPoint#rating',
        },
    ],
    UI.DataPoint #averageRating : {
        Value : averageRating,
        Visualization : #Rating,
        TargetValue : 5,
    },
    UI.DataPoint #averageRating1 : {
        Value : averageRating,
        Visualization : #Rating,
        TargetValue : 5,
    },
    UI.SelectionFields : [
        
    ],
);

annotate service.Books with {
    author @Common.ValueList : {
        $Type : 'Common.ValueListType',
        CollectionPath : 'Authors',
        Parameters : [
            {
                $Type : 'Common.ValueListParameterInOut',
                LocalDataProperty : author_ID,
                ValueListProperty : 'ID',
            },
            {
                $Type : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'name',
            },
        ],
    }
};


annotate service.Authors with @(
    Communication.Contact #contact : {
        $Type : 'Communication.ContactType',
        fn : name,
    }
);

annotate service.Books with {
    averageRating @Common.Label : 'averageRating'
};

annotate service.Books with {
    price @Measures.ISOCurrency : currency.descr
};

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
    genre @Common.ValueList : {
        $Type : 'Common.ValueListType',
        CollectionPath : 'Genres',
        Parameters : [
            {
                $Type : 'Common.ValueListParameterInOut',
                LocalDataProperty : genre,
                ValueListProperty : 'ID',
            },
            {
                $Type : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'name',
            },
        ],
    };
    currency @Common.ValueList : {
        $Type : 'Common.ValueListType',
        CollectionPath : 'Currencies',
        Parameters : [
            {
                $Type : 'Common.ValueListParameterInOut',
                LocalDataProperty : currency,
                ValueListProperty : 'code',
            },
            {
                $Type : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'descr',
            },
        ],
    }
};
