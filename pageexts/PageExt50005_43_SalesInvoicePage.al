pageextension 50005 SalesInvoicePage extends "Sales Invoice"
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

        //pageexts/PageExt50002_132 PostedSalesInvoicePage.al (21,36) - Error AL0275: 'Ship-to Phone No.' 
        // is an ambiguous reference between 'Ship-to Phone No.' defined by the extension 'Base Application by Microsoft 
        // (25.2.26921.0)' and 'Ship-to Phone No.' defined by the extension 'FamousAmos by 9Dots (1.0.0.2)'. 
        // addafter("Ship-to Contact")
        // {
        //     field("Phone No."; rec."Ship-to Phone No.") //
        //     {
        //         ApplicationArea = All;
        //     }

        // }
    }
}
