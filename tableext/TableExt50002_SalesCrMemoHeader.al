tableextension 50002 "SalesCr.MemoHeader" extends "Sales Cr.Memo Header"
{
    fields
    {
        field(50001; "Deliver On"; Text[100])
        {
            Caption = 'Deliver On';
            DataClassification = ToBeClassified;
        }
        field(50002; "Remarks"; Text[100])
        {
            Caption = 'Remarks';
            DataClassification = ToBeClassified;
        }
    }
}
