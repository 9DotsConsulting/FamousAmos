pageextension 50003 PostedSalesCreditMemoPage extends "Posted Sales Credit Memo"
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
    }
}
