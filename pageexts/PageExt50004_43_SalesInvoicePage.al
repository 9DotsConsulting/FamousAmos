pageextension 50004 SalesInvoicePage extends "Sales Invoice Subform"
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
