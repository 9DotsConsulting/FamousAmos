pageextension 50012 "Sales Order Subform Extension" extends "Sales Order Subform"
{
    layout
    {
        addafter("Shortcut Dimension 2 Code")
        {
            field("Item Group No."; Rec."Item Group No.")
            {
                ApplicationArea = all;
                Visible = true;
            }
            field("Delivery Adress"; Rec."Delivery Address")
            {
                ApplicationArea = All;
                Visible = true;
            }
        }
    }
}
