tableextension 50010 "DOT Sales Shipment Header" extends "Sales Shipment Header"
{
    fields
    {
        field(50001; "Deliver On"; Text[500])
        {
            Caption = 'Deliver On';
            DataClassification = ToBeClassified;
        }
        field(50002; "Delivery Address"; text[100])
        {
            Caption = 'Delivery Address';
        }
    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;
}