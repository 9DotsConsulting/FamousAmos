pageextension 50002 PostedSalesInvoicePage extends "Posted Sales Invoice"
{
    layout
    {
        addafter("Work Description")
        {
            field("Deliver On"; rec."Deliver On")
            {
                ApplicationArea = All;
                Visible = true;
                MultiLine = true;
                //Editable = true;
            }
        }
        modify("Work Description")
        {
            Visible = false;
        }
        addafter("Ship-to Contact")
        {
            field("Phone No."; rec."Ship-to Phone No.")
            {
                ApplicationArea = All;
            }
        }
    }
}
