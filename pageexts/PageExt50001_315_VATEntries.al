pageextension 50001 "VAT Entries Extension" extends "VAT Entries"
{
    layout
    {
        addafter("Bill-to/Pay-to No.")
        {
            field("Customer Name"; GetCustName(Rec."Bill-to/Pay-to No."))
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("Vendor Name"; GetVendName(Rec."Bill-to/Pay-to No."))
            {
                ApplicationArea = All;
                Visible = true;
            }
        }
    }

    local procedure GetCustName(No: Code[20]): Text
    var
        Cust: Record "Customer";
    begin
        if (Rec.Type = Rec.Type::Sale) then begin
            if not Cust.Get(No) then
                exit('');
            exit(Cust.Name);
        end
    end;

    local procedure GetVendName(No: Code[20]): Text
    var
        Vend: Record "Vendor";
    begin
        if (Rec.Type = Rec.Type::Purchase) then begin
            if not Vend.Get(No) then
                exit('');
            exit(Vend.Name);
        end;
    end;
}
