tableextension 50005 SalesInvoiceLine extends "Sales Invoice Line"
{
    fields
    {
        field(50001; "Item Group No."; Code[20])
        {
            Caption = 'Item Group No.';
            //DataClassification = ToBeClassified;
        }

        field(50100; "Set Indicator"; Code[5])
        {
            Caption = 'Set Indicator';
        }
        field(50004; "DOT Line No."; Integer)
        {
            Caption = 'Line No.';
        }
    }
}
