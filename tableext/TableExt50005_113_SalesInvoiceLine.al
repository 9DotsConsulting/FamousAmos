tableextension 50005 SalesInvoiceLine extends "Sales Invoice Line"
{
    fields
    {
        field(50001; "Item Group No."; Code[20])
        {
            Caption = 'Item Group No.';
            //DataClassification = ToBeClassified;
        }
    }
}