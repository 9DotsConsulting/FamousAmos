table 50004 "Proxy Type"
{
    Caption = 'Proxy Type';
    DataClassification = ToBeClassified;
    LookupPageId = 50004;
    fields
    {
        field(1; "Type"; Code[4])
        {
            Caption = 'Type';
        }
        field(2; Description; Text[150])
        {
            Caption = 'Description';
        }
    }
    keys
    {
        key(PK; "Type")
        {
            Clustered = true;
        }
    }
}
