codeunit 50001 BankExportGIROFAST
{
    //For bulk payment GIRO/FAST
    //TableNo = "Gen. Journal Line";

    procedure GenerateTextFile(var rec: Record "Gen. Journal Line")
    var
        Instr: InStream;
        OutStr: OutStream;
        TempBlob: Codeunit "Temp Blob";
        FileName: Text;
        Content_M: Text;
        txtYear, txtPostYear : code[10];
        txtMonth, txtPostMonth : Code[10];
        txtDay, txtPostDay : Code[10];
        txtTimeNow: Code[20];

        filename1: Text;
        CR, LF : char;
        g_txtFile: Text;

        bSameLine: Boolean;
        paymType: Enum "Bank Payment Type";
        bankAccountNo: Text;

        rowCount: Integer;
        totalamount: Decimal;
        paymJourAmount: Text;
        totalAmt: Text;
        totalRow: Text;

        TempGenJnLine1: Record "Gen. Journal Line" temporary;
        TempGenJnLine: Record "Gen. Journal Line" temporary;
        GenJnlLineBankAcc, lrGJL : Record "Gen. Journal Line";
        GLSetup: record "General Ledger Setup";
        gtxt_JnlTemplate: Code[20];
        gtxt_JnlBatch: Code[20];
        BankAccCode: Code[20];
        grec_GenJnlTemplate: Record "Gen. Journal Template";
        grec_GenJnlBatch: Record "Gen. Journal Batch";
        grec_GenJournalLine: Record "Gen. Journal Line";
        grec_Vendor: Record Vendor;
        bankAccount: Record "Bank Account";
        VendBankAcc: Record "Vendor Bank Account";
        convertStr: Codeunit StringConversionManagement;

        //new start
        CompInfo: Record "Company Information";
        FirstLineServiceCode: Code[1]; //Store the first line of service code from journal line
        FirstLineSettlementMode: Code[1]; //Store the first line of settlement mode from journal line
    //new end

    begin
        GLSetup.get;
        CompInfo.get;

        //Populate TempGenJnLine
        TempGenJnLine.RESET;
        TempGenJnLine.DELETEALL;
        CLEAR(totalamount);
        CLEAR(rowcount);

        bSameLine := FALSE;

        GenJnlLineBankAcc.RESET;
        GenJnlLineBankAcc.SETRANGE("Journal Template Name", rec."Journal Template Name");
        GenJnlLineBankAcc.SETRANGE("Journal Batch Name", rec."Journal Batch Name");
        GenJnlLineBankAcc.SetRange("Document No.", rec."Document No.");
        IF GenJnlLineBankAcc.FINDFIRST THEN bSameLine := TRUE;
        IF bSameLine THEN BEGIN
            //Merge lines with same doc no.
            lrGJL.RESET;
            lrGJL.SETRANGE("Journal Template Name", rec."Journal Template Name");
            lrGJL.SETRANGE("Journal Batch Name", rec."Journal Batch Name");
            IF lrGJL.FINDFIRST THEN
                REPEAT
                    TempGenJnLine.RESET;
                    TempGenJnLine.SETRANGE("Journal Template Name", rec."Journal Template Name");
                    TempGenJnLine.SETRANGE("Journal Batch Name", rec."Journal Batch Name");
                    TempGenJnLine.SETRANGE("Document No.", lrGJL."Document No.");
                    IF TempGenJnLine.FINDFIRST THEN BEGIN
                        TempGenJnLine.Amount += lrGJL.Amount;
                        TempGenJnLine.MODIFY;
                    END ELSE BEGIN
                        TempGenJnLine.INIT;
                        TempGenJnLine := lrGJL;
                        TempGenJnLine.INSERT;
                    END;
                UNTIL lrGJL.NEXT = 0;
        END ELSE BEGIN
            lrGJL.RESET;
            lrGJL.SETRANGE("Journal Template Name", rec."Journal Template Name");
            lrGJL.SETRANGE("Journal Batch Name", rec."Journal Batch Name");
            IF lrGJL.FINDFIRST THEN
                REPEAT
                    TempGenJnLine.RESET;
                    TempGenJnLine.INIT;
                    TempGenJnLine := lrGJL;
                    TempGenJnLine.INSERT;
                UNTIL lrGJL.NEXT = 0;
        END;

        //Filename starts
        #region file format
        IF DATE2DMY(TODAY, 2) < 10 THEN
            txtMonth := '0' + FORMAT(DATE2DMY(TODAY, 2))
        ELSE
            txtMonth := FORMAT(DATE2DMY(TODAY, 2));
        IF DATE2DMY(TODAY, 1) < 10 THEN
            txtDay := '0' + FORMAT(DATE2DMY(TODAY, 1))
        ELSE
            txtDay := FORMAT(DATE2DMY(TODAY, 1));
        txtYear := FORMAT(DATE2DMY(TODAY, 3));
        txtTimeNow := FORMAT(Time, 0, '<Hours24,2><Filler Character,0><Minutes,2><Seconds,2>');
        //Remove unwanted characters (not needed)

        //file naming

        filename1 := 'CIMB' + txtDay + txtMonth;
        filename1 := DelChr(filename1, '', ' ');
        filename1 := DelChr(filename1, '=', '/');
        filename1 := DelChr(filename1, '=', ':');

        #endregion
        CR := 13;
        LF := 10;
        TempBlob.CreateOutStream(OutStr);
        //Filename ends

        TempGenJnLine1.RESET;
        TempGenJnLine1.DELETEALL;
        TempGenJnLine.RESET;
        IF TempGenJnLine.FINDFIRST THEN
            REPEAT
                TempGenJnLine1 := TempGenJnLine;
                TempGenJnLine1.INSERT;
            UNTIL TempGenJnLine.NEXT = 0;

        //Validation bank information
        BankAccCode := '';
        GenJnlLineBankAcc.Reset;
        GenJnlLineBankAcc.SetRange("Journal Template Name", rec."Journal Template Name");
        GenJnlLineBankAcc.SetRange("Journal Batch Name", rec."Journal Batch Name");
        if not bSameLine then begin
            GenJnlLineBankAcc.SetRange("Account Type", GenJnlLineBankAcc."Account Type"::"Bank Account");
            GenJnlLineBankAcc.SetFilter("Account No.", '<>%1', '');
            if GenJnlLineBankAcc.FindFirst then begin
                bankAccount.Get(GenJnlLineBankAcc."Account No.");
                BankAccCode := bankAccount."Bank Account No.";
            end;
        end;


        //format posting date
        IF DATE2DMY(TempGenJnLine."Posting Date", 2) < 10 THEN
            txtPostMonth := '0' + FORMAT(DATE2DMY(TempGenJnLine."Posting Date", 2))
        ELSE
            txtPostMonth := FORMAT(DATE2DMY(TempGenJnLine."Posting Date", 2));
        IF DATE2DMY(TempGenJnLine."Posting Date", 1) < 10 THEN
            txtPostDay := '0' + FORMAT(TempGenJnLine."Posting Date", 1)
        ELSE
            txtPostDay := FORMAT(DATE2DMY(TempGenJnLine."Posting Date", 1));
        txtPostYear := FORMAT(DATE2DMY(TempGenJnLine."Posting Date", 3));


        //Get payment type value
        TempGenJnLine.SetRange("Journal Template Name", rec."Journal Template Name");
        TempGenJnLine.SetRange("Journal Batch Name", rec."Journal Batch Name");

        if TempGenJnLine.FindFirst() then begin
            FirstLineServiceCode := TempGenJnLine."Service Code";
            FirstLineSettlementMode := TempGenJnLine."Settlement Mode";

            //Get balance bank account value
            grec_GenJournalLine.Reset;
            grec_GenJournalLine.SetRange("Journal Batch Name", TempGenJnLine."Journal Batch Name");
            grec_GenJournalLine.SetRange("Journal Template Name", TempGenJnLine."Journal Template Name");
            grec_GenJournalLine.SetRange("Document No.", TempGenJnLine."Document No.");
            grec_GenJournalLine.SetRange("Bal. Account Type", TempGenJnLine."Bal. Account Type"::"Bank Account");
            if grec_GenJournalLine.FindFirst then begin
                //grec_Vendor.Get(grec_GenJournalLine."Account No.");
                //VendBankAcc.Reset;
                //VendBankAcc.SetRange("Vendor No.", grec_Vendor."No.");
                bankAccount.Get(grec_GenJournalLine."Bal. Account No.");
                //FirstBankBranchNo := bankAccount."Bank Branch No.";
                //FirstBankAccNo := bankAccount."Bank Account No.";
            end;
        end;


        TempGenJnLine.SetRange("Journal Template Name", rec."Journal Template Name");
        TempGenJnLine.SetRange("Journal Batch Name", rec."Journal Batch Name");
        //TempGenJnLine.SetRange("Document No.", rec."Document No.");
        //TempGenJnLine.SetRange("Account Type", rec."Account Type"::Vendor);

        if TempGenJnLine.FindFirst then
            repeat
                //looping for lines
                //get vendor bank info
                grec_GenJournalLine.Reset;
                grec_GenJournalLine.SetRange("Journal Batch Name", TempGenJnLine."Journal Batch Name");
                grec_GenJournalLine.SetRange("Journal Template Name", TempGenJnLine."Journal Template Name");
                grec_GenJournalLine.SetRange("Document No.", TempGenJnLine."Document No.");
                grec_GenJournalLine.SetRange("Account Type", TempGenJnLine."Account Type"::Vendor);
                if grec_GenJournalLine.FindFirst then begin
                    grec_Vendor.Get(grec_GenJournalLine."Account No.");
                    VendBankAcc.Reset;
                    VendBankAcc.SetRange("Vendor No.", grec_Vendor."No.");
                    if not VendBankAcc.Find('-') then
                        Error('Vendor bank account of vendor %1 is not setup', grec_Vendor."No.");
                end;

                if grec_GenJournalLine.FindFirst then
                    repeat
                        rowCount += 1;
                    until grec_GenJournalLine.Next() = 0;

                totalamount += Abs(TempGenJnLine.Amount);
            until TempGenJnLine.Next() = 0;

        //---------------File Header starts----------------//

        //#1 First line service code (1)
        //Need to change the rest to g_txtFile := g_txtFile + so it won't be replaced
        g_txtFile := FirstLineServiceCode + '%';

        //#2 Bal. Account No (Comp bank account) (10)
        //g_txtFile := g_txtFile + bankAccount."No." + '%';
        g_txtFile := g_txtFile + bankAccount."Bank Account No." + '%';

        //#3 Company name
        g_txtFile := g_txtFile + CompInfo.Name + '%';

        //#4 Currency code (if blank use lcy)
        if (grec_GenJournalLine."Currency Code" = '') then
            g_txtFile := g_txtFile + 'SGD'
        else
            g_txtFile := g_txtFile + 'SGD';
        g_txtFile := g_txtFile + grec_GenJournalLine."Currency Code";

        //#5 Total Batch Amount (2 decimals place)
        //Make a function that sum up all the payment lines
        //g_txtFile := g_txtFile + convertDecimal(getTotalAmount(rec)) + '%';
        g_txtFile := g_txtFile + convertDecimal(totalamount) + '%';
        //g_txtFile := g_txtFile + format(totalamount) + '%';

        //#6 Quantity of line record
        //Make a function that sum up the total number of lines
        //g_txtFile := g_txtFile + Format(getTotalLines(rec)) + '%';
        g_txtFile := g_txtFile + format(rowCount) + '%';

        //#7 Settlement Mode
        g_txtFile := g_txtFile + FirstLineSettlementMode + '%';

        //#8 Posting Indicator
        if (FirstLineServiceCode = '3') then
            g_txtFile := g_txtFile + 'C' + '%'
        else
            g_txtFile := g_txtFile + grec_GenJournalLine."Posting Indicator" + '%';

        //#9 Posting Date
        g_txtFile := g_txtFile + txtPostDay + txtPostMonth + txtPostYear;

        OutStr.WriteText(g_txtFile + CR + LF);
        //OutStr.Write(g_txtFile);
        //---------------------File Header ends---------------------//

        Clear(g_txtFile);

        TempGenJnLine.SetRange("Journal Template Name", rec."Journal Template Name");
        TempGenJnLine.SetRange("Journal Batch Name", rec."Journal Batch Name");
        //TempGenJnLine.SetRange("Document No.", rec."Document No.");
        //TempGenJnLine.SetRange("Account Type", rec."Account Type"::Vendor);

        if TempGenJnLine.FindFirst then
            repeat
                //looping for lines
                //get vendor bank info
                grec_GenJournalLine.Reset;
                grec_GenJournalLine.SetRange("Journal Batch Name", TempGenJnLine."Journal Batch Name");
                grec_GenJournalLine.SetRange("Journal Template Name", TempGenJnLine."Journal Template Name");
                grec_GenJournalLine.SetRange("Document No.", TempGenJnLine."Document No.");
                grec_GenJournalLine.SetRange("Account Type", TempGenJnLine."Account Type"::Vendor);
                if grec_GenJournalLine.FindFirst then begin
                    grec_Vendor.Get(grec_GenJournalLine."Account No.");
                    VendBankAcc.Reset;
                    VendBankAcc.SetRange("Vendor No.", grec_Vendor."No.");
                    if not VendBankAcc.Find('-') then
                        Error('Vendor bank account of vendor %1 is not setup', grec_Vendor."No.");

                end;

                if grec_GenJournalLine.FindFirst then
                    repeat

                        //---------------Detailed Payment records start-------------//

                        //#1 Recepient Bank Account No.
                        //if (FirstLineServiceCode = '3') and (FirstLineSettlementMode = 'PayNow FAST') or (FirstLineSettlementMode = 'PayNow GIRO') then
                        if (FirstLineServiceCode = '3') and (FirstLineSettlementMode = 'F') or (FirstLineSettlementMode = 'G') then
                            g_txtFile := VendBankAcc."Proxy ID" + '%'
                        else
                            g_txtFile := VendBankAcc."Bank Account No." + '%';

                        //#2 Beneficiary name (Supplier name or Staff name)
                        g_txtFile := g_txtFile + grec_Vendor.Name + '%';

                        //#3 Local amount paid (2 decimal places)
                        g_txtFile := g_txtFile + format(grec_GenJournalLine.Amount) + '%';
                        //g_txtFile := g_txtFile + convertDecimal(grec_GenJournalLine.Amount) + '%';
                        //Message(format(grec_GenJournalLine.Amount));

                        //#4 Currency code
                        if (grec_GenJournalLine."Currency Code" = '') then
                            g_txtFile := g_txtFile + 'SGD' + '%'
                        else
                            g_txtFile := g_txtFile + grec_GenJournalLine."Currency Code" + '%';

                        //#4 SWIFTCode or Proxy Type
                        //if (FirstLineServiceCode = '3') and (FirstLineSettlementMode = 'PayNow FAST') or (FirstLineSettlementMode = 'PayNow GIRO') then
                        if (FirstLineServiceCode = '3') and (FirstLineSettlementMode = 'F') or (FirstLineSettlementMode = 'G') then
                            g_txtFile := g_txtFile + VendBankAcc."Payroll Proxy Type" + '%'
                        else
                            g_txtFile := g_txtFile + VendBankAcc."SWIFT Code" + '%';

                        //#5 Purpose Code
                        g_txtFile := g_txtFile + grec_GenJournalLine."Purpose Code" + '%';

                        //#6 Remark Info to Counterparty (35)
                        g_txtFile := g_txtFile + cutExtraText(grec_GenJournalLine.Description, 35);
                        /*
                        if (StrLen(grec_GenJournalLine.Description) > 35) then
                            g_txtFile := g_txtFile + '%'
                        else
                            g_txtFile := g_txtFile + grec_GenJournalLine.Description;
                        */

                        OutStr.WriteText(g_txtFile + CR + LF);
                        //----------------Detailed Payment records end--------------//

                        rowCount += 1;
                    until grec_GenJournalLine.Next() = 0;

                totalamount += Abs(TempGenJnLine.Amount);
            until TempGenJnLine.Next() = 0;

        filename := filename1 + '.txt';

        //Export out
        TempBlob.CreateInStream(Instr); //to create instream
        lrGJL.Reset;
        lrGJL.SetRange("Journal Template Name", rec."Journal Template Name");
        lrGJL.SetRange("Journal Batch Name", rec."Journal Batch Name");
        if lrGJL.FindFirst then
            repeat
                lrGJL.Modify(false);
            until lrGJL.Next() = 0;
        DownloadFromStream(Instr, '', '', '', FileName); //to download the file 
        MESSAGE('%1 - CIMB payment file has been exported!', FileName);
    end;

    //Get the total lines for payment journal
    procedure getTotalLines(var rec: Record "Gen. Journal Line"): Integer
    var
        GenJnLine: Record "Gen. Journal Line";
        TempGenJnLine1: Record "Gen. Journal Line" temporary;
        TempGenJnLine: Record "Gen. Journal Line" temporary;
        GenJnlLineBankAcc, lrGJL : Record "Gen. Journal Line";
        GLSetup: record "General Ledger Setup";
        gtxt_JnlTemplate: Code[20];
        gtxt_JnlBatch: Code[20];
        grec_GenJnlTemplate: Record "Gen. Journal Template";
        grec_GenJnlBatch: Record "Gen. Journal Batch";
        grec_GenJournalLine: Record "Gen. Journal Line";
        grec_Vendor: Record Vendor;
        totalLines: Integer;
    begin
        TempGenJnLine.SetRange("Journal Template Name", GenJnLine."Journal Template Name");
        TempGenJnLine.SetRange("Journal Batch Name", GenJnLine."Journal Batch Name");

        if TempGenJnLine.FindFirst then
            repeat
                //looping for lines
                grec_GenJournalLine.Reset;
                grec_GenJournalLine.SetRange("Journal Batch Name", TempGenJnLine."Journal Batch Name");
                grec_GenJournalLine.SetRange("Journal Template Name", TempGenJnLine."Journal Template Name");
                grec_GenJournalLine.SetRange("Document No.", TempGenJnLine."Document No.");
                grec_GenJournalLine.SetRange("Account Type", TempGenJnLine."Account Type"::Vendor);
                if grec_GenJournalLine.FindFirst then begin
                    grec_Vendor.Get(grec_GenJournalLine."Account No.");
                end;
                if grec_GenJournalLine.FindFirst then
                    repeat
                        totalLines += 1;
                    until grec_GenJournalLine.Next() = 0;
            until TempGenJnLine.Next() = 0;
        exit(totalLines);
    end;

    //Get the total amount for payment journal
    procedure getTotalAmount(var rec: Record "Gen. Journal Line"): Decimal
    var
        GenJnLine: Record "Gen. Journal Line";
        TempGenJnLine1: Record "Gen. Journal Line" temporary;
        TempGenJnLine: Record "Gen. Journal Line" temporary;
        GenJnlLineBankAcc, lrGJL : Record "Gen. Journal Line";
        GLSetup: record "General Ledger Setup";
        gtxt_JnlTemplate: Code[20];
        gtxt_JnlBatch: Code[20];
        grec_GenJnlTemplate: Record "Gen. Journal Template";
        grec_GenJnlBatch: Record "Gen. Journal Batch";
        grec_GenJournalLine: Record "Gen. Journal Line";
        grec_Vendor: Record Vendor;
        totalAmount: Decimal;
    begin
        TempGenJnLine.SetRange("Journal Template Name", GenJnLine."Journal Template Name");
        TempGenJnLine.SetRange("Journal Batch Name", GenJnLine."Journal Batch Name");

        if TempGenJnLine.FindFirst then
            repeat
                //looping for lines
                grec_GenJournalLine.Reset;
                grec_GenJournalLine.SetRange("Journal Batch Name", TempGenJnLine."Journal Batch Name");
                grec_GenJournalLine.SetRange("Journal Template Name", TempGenJnLine."Journal Template Name");
                grec_GenJournalLine.SetRange("Document No.", TempGenJnLine."Document No.");
                grec_GenJournalLine.SetRange("Account Type", TempGenJnLine."Account Type"::Vendor);
                if grec_GenJournalLine.FindFirst then begin
                    grec_Vendor.Get(grec_GenJournalLine."Account No.");
                end;
                if grec_GenJournalLine.FindFirst then
                    repeat
                    until grec_GenJournalLine.Next() = 0;
                totalAmount += Abs(TempGenJnLine.Amount);
            until TempGenJnLine.Next() = 0;
        exit(totalAmount);
    end;

    //Cut extra characters for text that exceed max character amount
    procedure cutExtraText(Input: Text;
        MaxLength: Integer): Text
    var
        returnText: Text;
        cutAmount: Integer;
    begin
        clear(returnText);
        if (StrLen(Input) > MaxLength) then begin
            cutAmount := StrLen(Input) - MaxLength;
            returnText := DelStr(Input, MaxLength + 1, cutAmount);
        end
        else
            returnText := Input;
        exit(returnText);
    end;

    //Convert Decimal to Text while maintaining at least 2 decimal places
    procedure convertDecimal(Input: Decimal): Text
    var
        Result: Decimal;
        ReturnText: Text;
    begin
        if ((Input - Round(Input, 1, '<')) <> 0) then begin
            //ReturnText := DelChr(Format(Input), '=', '.');
            //ReturnText := DelChr(Format(ReturnText), '=', ',');
            //if (StrLen(DelChr(Format(Input - Round(Input, 1, '<')), '=', '.')) = 2) then
            //ReturnText := ReturnText + '0';
            //Message('%1', DelChr(Format(Input - Round(Input, 1, '<')), '=', '.'));
            ReturnText := Format(Input) + '0';
            exit(ReturnText);
        end;
        //ReturnText := DelChr(Format(Input), '=', '.');
        //ReturnText := DelChr(Format(ReturnText), '=', ',');
        ReturnText := Format(Input) + '.00';
        exit(ReturnText);
    end;
}
