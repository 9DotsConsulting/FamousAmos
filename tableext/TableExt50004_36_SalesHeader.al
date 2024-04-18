tableextension 50004 SalesHeader extends "Sales Header"
{
    fields
    {
        field(50001; "Deliver On"; Text[500])
        {
            Caption = 'Deliver On';
            DataClassification = ToBeClassified;
        }
        field(50002; "Ship-to Phone No."; Text[30])
        {
            Caption = 'Ship-to Phone No.';
            //FieldClass = FlowField;
            TableRelation = "Ship-to Address"."Phone No." where("Customer No." = field("Sell-to Customer No."));
            //CalcFormula = lookup("Ship-to Address"."Phone No." where("Customer No." = field("Sell-to Customer No.")));
        }
        //FDD 1.4 starts
        field(50003; "Note"; Text[500])
        {
            Caption = 'Note';
            DataClassification = ToBeClassified;
        }
        //FDD 1.4 ends
    }
}
