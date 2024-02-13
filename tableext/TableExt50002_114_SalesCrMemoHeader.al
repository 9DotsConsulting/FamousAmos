tableextension 50002 "SalesCr.MemoHeader" extends "Sales Cr.Memo Header"
{
    fields
    {
        field(50001; "Deliver On"; Text[500])
        {
            Caption = 'Deliver On';
            DataClassification = ToBeClassified;
        }
    }
}
