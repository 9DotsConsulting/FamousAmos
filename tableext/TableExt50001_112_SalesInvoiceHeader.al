tableextension 50001 SalesInvoiceHeader extends "Sales Invoice Header"
{
    fields
    {
        field(50001; "Deliver On"; Text[500])
        {
            Caption = 'Deliver On';
            DataClassification = ToBeClassified;
        }
        field(50002; "Ship-to Phone No."; Text[30])
        {
            Caption = 'Ship-to Phone No.';
            TableRelation = "Ship-to Address"."Phone No." where("Customer No." = field("Sell-to Customer No."));
        }
    }
}
