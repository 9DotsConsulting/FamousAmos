reportextension 50002 "DOT - Gen. Journal Test" extends "General Journal - Test"
{
    dataset
    {
        add("Gen. Journal Line")
        {
            column(CompanyLogo; CI.Picture) { }
            column(ApprovedBy; GetApprovedBy("Gen. Journal Line"."Journal Template Name", "Gen. Journal Line"."Journal Batch Name", "Gen. Journal Line"."Line No.")) { }
            column(Vendor_Name; Vendor_Name) { }
            column(Payment_Reference; "Payment Reference") { }

            column(Company_Name; CI.Name) { }
            column(CompanyAddress; CI.Address) { }
            column(CompanyAddress2; CI."Address 2") { }
            column(City; CI.City) { }
            column(PostCode; CI."Post Code") { }
            column(Phone_No; CI."Phone No.") { }
            column(CoRegNo; CI."Registration No.") { }
            column(AmountTotal; AmountTotal) { }
            column(AmountInWord; AmountInWord) { }
            column(BankAccName; BankAccName) { }
        }
        modify("Gen. Journal Line")
        {
            trigger OnAfterAfterGetRecord()
            var
                AmtToWord: report "DOT AmountToWords";
                NoDec, Dec : decimal;
            begin
                lrVendor.Get("Gen. Journal Line"."Account No.");
                Vendor_Name := lrVendor.Name;

                BankAccount.Get("Gen. Journal Line"."Bal. Account No.");
                BankAccName := BankAccount.Name;

                //amount to word
                AmountTotal += "Gen. Journal Line".Amount;
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
        layout("DOT - Gen. Journal Test")
        {
            Type = RDLC;
            LayoutFile = './reportextlayout/ReportExt50002_2_GenJournalTest.rdlc';
        }
    }
    local procedure GetApprovedBy(Template: Text; Batch: Text; LineNo: Integer): Text
    var
        GenJournalLine: Record "Gen. Journal Line";
        PostedApprEntry: Record "Approval Entry";
        RecToApprove: Text;
    begin
        RecToApprove := 'Gen. Journal Batch: ' + Template + ',' + Batch + '|' + 'Gen. Journal Line: ' + Template + ',' + Batch + ',' + Format(LineNo);
        PostedApprEntry.Reset();
        PostedApprEntry.SetFilter("Table ID", '232|81');
        PostedApprEntry.SetFilter("Record ID to Approve", RecToApprove);
        if PostedApprEntry.FindFirst() then
            exit(PostedApprEntry."Sender ID");
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
        BankAccount: Record "Bank Account";
        TotalAmt, ShowAmount_LCY, AmountTotal : Decimal;
        NoText1, NoText2 : array[2] of Text[80];
        AmountInWord: Text;
        Vendor_Name, BankAccName : text[100];
}