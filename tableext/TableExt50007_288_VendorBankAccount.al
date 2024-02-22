tableextension 50007 VendorBankAccount extends "Vendor Bank Account"
{
    fields
    {
        field(50001; "Payroll Proxy Type"; Code[4])
        {
            Caption = 'Payroll Proxy Type';
            DataClassification = ToBeClassified;
        }
        //Proxy ID has no predefined length - for now, use 50
        field(50002; "Proxy ID"; Text[50])
        {
            Caption = 'Proxy ID';
            DataClassification = ToBeClassified;
        }

    }
}
