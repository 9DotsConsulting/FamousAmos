tableextension 50008 GenJournalLine extends "Gen. Journal Line"
{
    fields
    {
        field(50001; "Service Code"; Code[2])
        {
            Caption = 'Service Code';
            DataClassification = ToBeClassified;
        }
        field(50002; "Settlement Mode"; Code[1])
        {
            Caption = 'Settlement Mode';
            DataClassification = ToBeClassified;
        }
        field(50003; "Posting Indicator"; Code[1])
        {
            Caption = 'Posting Indicator';
            DataClassification = ToBeClassified;
        }
        field(50004; "Payroll Proxy Type"; Code[4])
        {
            Caption = 'Payroll Proxy Type';
            DataClassification = ToBeClassified;
        }
        field(50005; "Purpose Code"; Code[4])
        {
            Caption = 'Purpose Code';
            DataClassification = ToBeClassified;
        }
        //Proxy ID has no predefined length - for now, use 50
        field(50006; "Proxy ID"; Text[50])
        {
            Caption = 'Proxy ID';
            DataClassification = ToBeClassified;
        }
    }
}
