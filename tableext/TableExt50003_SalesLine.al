tableextension 50003 SalesLine extends "Sales Line"
{
    fields
    {
        field(50001; "Item Group No."; Code[20])
        {
            Caption = 'Item Group No.';
            DataClassification = ToBeClassified;
        }
    }
}
