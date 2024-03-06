pageextension 50012 "Sales Order Subform Extension" extends "Sales Order Subform"
{
    layout
    {
        addafter("Shortcut Dimension 2 Code")
        {
            field("Delivery Adress"; Rec."Delivery Address")
            {
                ApplicationArea = All;
                Visible = true;
            }
        }
    }
}
