pageextension 50004 SalesInvoiceSubPage extends "Sales Invoice Subform"
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
