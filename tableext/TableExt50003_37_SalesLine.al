tableextension 50003 SalesLine extends "Sales Line"
{
    fields
    {
        field(50001; "Item Group No."; Code[20])
        {
            Caption = 'Item Group No.';
            //DataClassification = ToBeClassified;
        }
        field(50002; "Delivery Address"; Text[100])
        {
            Caption = 'Delivery Address';
            TableRelation = "Multiple Delivery Address".Name where("Customer No." = field("Sell-to Customer No."));
        }
    }
}
