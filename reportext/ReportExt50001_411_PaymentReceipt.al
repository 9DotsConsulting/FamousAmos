reportextension 50001 "DOT Vendor - Payment Receipt" extends "Vendor - Payment Receipt"
{
    dataset
    {
        add("Vendor Ledger Entry")
        {
            column(CompanyLogo; CI.Picture) { }
            column(ApprovedBy; GetApprovedBy("Document No.", 1)) { }
            column(Vendor_Name; lrVendor.Name) { }
            column(Payment_Reference; "Payment Reference") { }

            column(CompanyName; CI.Name) { }
            column(CompanyAddress; CI.Address) { }
            column(CompanyAddress2; CI."Address 2") { }
            column(City; CI.City) { }
            column(PostCode; CI."Post Code") { }
            column(Phone_No; CI."Phone No.") { }
            column(CoRegNo; CI."Registration No.") { }
        }
        modify("Vendor Ledger Entry")
        {
            trigger OnAfterAfterGetRecord()
            begin
                lrVendor.Get("Vendor Ledger Entry"."Vendor No.");
            end;
        }
        add(Total)
        {
            column(AmountTotal; AmountTotal) { }
            column(AmountInWord; AmountInWord) { }
        }
        modify(Total)
        {
            trigger OnAfterAfterGetRecord()
            var
                AmtToWord: report "DOT AmountToWords";
                NoDec, Dec : decimal;
            begin
                AmountTotal += "Vendor Ledger Entry"."Original Amount";
                //amount to word
                AmtToWord.InitTextVariable();
                AmtToWord.FormatNoText_Integer(NoText1, AmountTotal, '');//NegOriginalAmt_VendLedgEntry
                AmountInWord += NoText1[1];

                NoDec := Round(AmountTotal, 1, '<');
                Dec := (AmountTotal - NoDec) * 100;
                AmtToWord.FormatNoText_Decimal(NoText2, Dec, '');
                AmountInWord += NoText2[1];
            end;
        }
    }

    requestpage
    {
        // Add changes to the requestpage here
    }

    rendering
    {
        layout("DOT Vendor - Payment Receipt")
        {
            Type = RDLC;
            LayoutFile = './reportextlayout/ReportExt50001_411_PaymentReceipt.rdlc';
        }
    }
    local procedure GetApprovedBy(DocNo: Code[20]; No: Integer): Text
    var
        PostedApprEntry: Record "Posted Approval Entry";
    begin
        PostedApprEntry.Reset();
        PostedApprEntry.SetRange("Document No.", DocNo);
        PostedApprEntry.SetRange("Sequence No.", No);
        if PostedApprEntry.FindFirst() then
            exit(Format(PostedApprEntry."Last Modified By ID"))
        else
            exit('');
    end;

    trigger OnPreReport()
    begin
        CI.Get;
        CI.CalcFields(Picture);
    end;

    var
        CI: Record "Company Information";
        lrVendor: Record Vendor;
        GLSetup2: Record "General Ledger Setup";
        TotalAmt, ShowAmount_LCY, AmountTotal : Decimal;
        NoText1, NoText2 : array[2] of Text[80];
        AmountInWord: Text;
}