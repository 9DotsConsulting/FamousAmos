pageextension 50007 "Posted Sales Cr.Memo Subpage" extends "Posted Sales Cr. Memo Subform"
{
    layout
    {
        addafter(Description)
        {
            field("Item Group No."; Rec."Item Group No.")
            {
                ApplicationArea = All;
                Visible = true;
            }
        }
    }
}
