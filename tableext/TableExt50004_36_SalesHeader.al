tableextension 50004 SalesHeader extends "Sales Header"
{
    fields
    {
        field(50001; "Deliver On"; Text[500])
        {
            Caption = 'Deliver On';
            DataClassification = ToBeClassified;
        }
        //pageexts/PageExt50002_132 PostedSalesInvoicePage.al (21,36) - Error AL0275: 'Ship-to Phone No.' 
        // is an ambiguous reference between 'Ship-to Phone No.' defined by the extension 'Base Application by Microsoft 
        // (25.2.26921.0)' and 'Ship-to Phone No.' defined by the extension 'FamousAmos by 9Dots (1.0.0.2)'. 
        // field(50002; "Ship-to Phone No."; Text[30]) //
        // {
        //     Caption = 'Ship-to Phone No.';
        //     //FieldClass = FlowField;
        //     TableRelation = "Ship-to Address"."Phone No." where("Customer No." = field("Sell-to Customer No."));
        //     //CalcFormula = lookup("Ship-to Address"."Phone No." where("Customer No." = field("Sell-to Customer No.")));
        // }
        //FDD 1.4 starts
        field(50003; "Note"; Text[500])
        {
            Caption = 'Note';
            DataClassification = ToBeClassified;
        }
        //FDD 1.4 ends
    }
}
