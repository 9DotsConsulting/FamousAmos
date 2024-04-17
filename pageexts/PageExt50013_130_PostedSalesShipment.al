pageextension 50013 "DOT Posted Sales Shipment" extends "Posted Sales Shipment"
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