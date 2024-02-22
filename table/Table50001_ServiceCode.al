table 50001 "Service Code"
{
    Caption = 'Service Code';
    DataClassification = ToBeClassified;
    LookupPageId = 50001;
    fields
    {
        field(1; "Code"; Code[2])
        {
            Caption = 'Code';
        }
        field(2; Description; Text[150])
        {
            Caption = 'Description';
        }
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}
