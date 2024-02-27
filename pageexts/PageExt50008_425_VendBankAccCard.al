pageextension 50008 VendBankAccCard extends "Vendor Bank Account Card"
{
    layout
    {
        addafter(General)
        {
            group(Staff)
            {
                Caption = 'Staff';
                field("Payroll Proxy Type"; Rec."Payroll Proxy Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Payroll Proxy Type';
                    TableRelation = "Proxy Type".Type;
                }
                field("Proxy ID"; Rec."Proxy ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Proxy ID';
                }
            }
        }
    }
}
