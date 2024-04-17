pageextension 50014 "DOT Sales Order" extends "Sales Order"
{
    layout
    {
        addafter("Work Description")
        {
            field("Deliver On"; Rec."Deliver On")
            {
                ApplicationArea = all;
                Visible = true;
                MultiLine = true;
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