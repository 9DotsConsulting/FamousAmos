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

            field("Remarks Info"; rec.Remarks)
            {
                ApplicationArea = All;
                Visible = true;
                MultiLine = true;
                //Editable = true;
            }
        }
    }
}
