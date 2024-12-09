pageextension 50016 PhyInvOrderSubform extends "Physical Inventory Order Subf."
{
    layout
    {
        //addafter("Neg. Qty. (Base)")
        addafter(Description)
        {
            field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
            {
                //ApplicationArea = Warehouse;
                ApplicationArea = All;
            }
            field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
            {
                //ApplicationArea = Warehouse;
                ApplicationArea = All;
            }
        }
    }
}
