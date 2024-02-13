pageextension 50006 PostedSalesInvoiceSubPage extends "Posted Sales Invoice Subform"
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
