pageextension 50011 "DOT Cash Receipt Journals" extends "Cash Receipt Journal"
{
    layout
    {
        addafter("Applies-to Doc. No.")
        {
            field("Payment Method Code"; Rec."Payment Method Code")
            {
                ApplicationArea = All;
                Visible = true;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}