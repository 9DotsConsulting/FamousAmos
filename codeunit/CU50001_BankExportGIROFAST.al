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
        //rec: Record "Gen. Journal Line";
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
        //FirstPaymentType: Code[1]; // Store first line of Payment Type in journal line
        //FirstBankBranchNo: Text[20]; // Store first line of Bank Account. Bank Branch No in journal line
        //FirstBankAccNo: Text[30]; // Store first line of Bank Account. Bank Account No. in journal line
        //FirstNameHolder: Text[140]; // Store first line of Bank Account. Name Holder in journal line
        //CompRegNo: Text[20];
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

        //---------------File Header starts----------------//

        //#1 First line service code (1)
        //Need to change the rest to g_txtFile := g_txtFile + so it won't be replaced
        g_txtFile := FirstLineServiceCode + '%';

        //#2 Bal. Account No (Comp bank account) (10)
        g_txtFile := g_txtFile + bankAccount."No." + '%';

        //#3 Company name
        g_txtFile := g_txtFile + CompInfo.Name + '%';

        //#4 Currency code (if blank use lcy)
        g_txtFile := g_txtFile + grec_GenJournalLine."Currency Code";

        //#5 Total Batch Amount (2 decimals place)
        //Make a function that sum up all the payment lines
        g_txtFile := g_txtFile + convertDecimal(getTotalAmount()) + '%';

        //#6 Quantity of line record
        //Make a function that sum up the total number of lines
        g_txtFile := g_txtFile + Format(getTotalLines()) + '%';

        //#7 Settlement Mode
        g_txtFile := g_txtFile + FirstLineSettlementMode + '%';

        //#8 Posting Indicator
        if (FirstLineServiceCode = '3') then
            g_txtFile := g_txtFile + 'C' + '%'
        else
            g_txtFile := g_txtFile + grec_GenJournalLine."Posting Indicator" + '%';

        //#9 Posting Date
        g_txtFile := g_txtFile + txtPostYear + txtPostMonth + txtPostDay;

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
                        //g_txtFile := g_txtFile + format(grec_GenJournalLine.Amount) + '%';
                        g_txtFile := g_txtFile + convertDecimal(grec_GenJournalLine.Amount) + '%';

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


                        OutStr.WriteText(g_txtFile + CR + LF);
                        //----------------Detailed Payment records end--------------//

                        rowCount += 1;
                    until grec_GenJournalLine.Next() = 0;

                totalamount += Abs(TempGenJnLine.Amount);
            until TempGenJnLine.Next() = 0;

    end;

    //Get the total lines for payment journal
    procedure getTotalLines(): Integer
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
    procedure getTotalAmount(): Decimal
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
            if (StrLen(DelChr(Format(Input - Round(Input, 1, '<')), '=', '.')) = 2) then
                ReturnText := ReturnText + '0';
            //Message('%1', DelChr(Format(Input - Round(Input, 1, '<')), '=', '.'));
            exit(ReturnText);
        end;
        //ReturnText := DelChr(Format(Input), '=', '.');
        //ReturnText := DelChr(Format(ReturnText), '=', ',');
        ReturnText := ReturnText + '.00';
        exit(ReturnText);
    end;

    //Need to modify
    /*
    procedure GenerateTextFile(var rec: Record "Gen. Journal Line")
        var
            Instr: InStream;
            OutStr: OutStream;
            TempBlob: Codeunit "Temp Blob";
            FileName: Text;
            Content_M: Text;
            //rec: Record "Gen. Journal Line";
            txtYear, txtPostYear : code[10];
            txtMonth, txtPostMonth : Code[10];
            txtDay, txtPostDay : Code[10];
            txtTimeNow: Code[20];
            filename1: Text;
            //DFN: Page "DOT UOB Filename";
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
            testChar: Char;
            testInt, H1, H2, H3, H4, H5, H6, TotalHeader : Integer;
            L1, L2, L3, L4, L5, L6, L7, L8, TotalLine : integer;
            testTxt, TotalHash : Text;

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
            PaymentType: Record "DOT Payment Type";
            Tracker: Record UOBVersionTracker; // Track the current file version
            VerNum: Integer; // Store current file version number
            FirstPaymentType: Code[1]; // Store first line of Payment Type in journal line
            FirstBankBranchNo: Text[20]; // Store first line of Bank Account. Bank Branch No in journal line
            FirstBankAccNo: Text[30]; // Store first line of Bank Account. Bank Account No. in journal line
            FirstNameHolder: Text[140]; // Store first line of Bank Account. Name Holder in journal line
            CompRegNo: Text[20];
        //new end

        begin
            GLSetup.get;
            CompInfo.get;
            //gdat_ValueDate := today;
            //CompanyInfo.GET;
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
            txtTimeNow := DelChr(txtTimeNow, '=', 'PM');
            txtTimeNow := DelChr(txtTimeNow, '=', 'AM');
            txtTimeNow := DelChr(txtTimeNow, '=', ':');
            txtTimeNow := DelChr(txtTimeNow, '=', ' ');

            filename1 := 'PAITX' + txtDay + txtMonth;
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

            //Add Version Number
            if Tracker.FindLast() then begin
                VerNum := Tracker.VersionNo;
            end;

            //---------------File Control Header starts----------------//
            // 7 Fields in total

            //#1 Record type (1) - Hardcoded
            //Need to change the rest to g_txtFile := g_txtFile + so it won't be replaced
            g_txtFile := '0';

            //#2 File name (20) 
            filename1 := filename1 + addBufferZero(Format(VerNum), 3) + Format(VerNum);
            g_txtFile := g_txtFile + filename1 + addBufferSpace(filename1, 20);

            //#3 File Creation Date (8) - YYYYMMDD
            g_txtFile := g_txtFile + txtYear + txtMonth + txtDay;

            //#4 File Creation Time (6) - HHMMSS
            g_txtFile := g_txtFile + txtTimeNow;

            //#5 Company ID (19) - Company Information.Registration No. 
            //g_txtFile := g_txtFile + addBufferZero(CompInfo."Registration No.", 19) + CompInfo."Registration No.";
            CompRegNo := CompInfo."Registration No.";
            CompRegNo := DelChr(CompRegNo, '=', '-');
            g_txtFile := g_txtFile + CompRegNo + addBufferSpace(CompRegNo, 19);

            //#6 Check Summary (15) - Fills with zeros
            //g_txtFile := g_txtFile + '000000000000000';
            g_txtFile := g_txtFile + addZero(15);

            //#7 Filler (1730) - Fills with spaces
            //g_txtFile := g_txtFile + ' ';
            g_txtFile := g_txtFile + addSpace(1730);

            OutStr.WriteText(g_txtFile + CR + LF);
            //OutStr.Write(g_txtFile);
            //---------------------File Control Header ends---------------------//

            //Get payment type value
            TempGenJnLine.SetRange("Journal Template Name", rec."Journal Template Name");
            TempGenJnLine.SetRange("Journal Batch Name", rec."Journal Batch Name");
            //TempGenJnLine.SetRange("Document No.", rec."Document No.");
            //TempGenJnLine.SetRange("Account Type", rec."Account Type"::Vendor);

            if TempGenJnLine.FindFirst() then begin
                FirstPaymentType := TempGenJnLine."DOT Payment Type";
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
                    FirstBankBranchNo := bankAccount."Bank Branch No.";
                    FirstBankAccNo := bankAccount."Bank Account No.";
                    FirstNameHolder := bankAccount."Name Holder";
                end;
            end;

            //-------------Batch Header starts----------------//
            // 14 Fields in total

            // #1 record Type - hardcoded (1)
            g_txtFile := '1';

            // #2 Payment Type (1) - <custom>
            g_txtFile := g_txtFile + FirstPaymentType;

            // #3 Originating Bank Code - hardcoded (8)
            g_txtFile := g_txtFile + 'UOVBMYKL';

            // #4 Bank branch no. (3)
            //g_txtFile := g_txtFile + cutExtraText(bankAccount."Bank Branch No.", 3);
            g_txtFile := g_txtFile + cutExtraText(FirstBankBranchNo, 3);

            // #5 Bank account no. (11)
            //g_txtFile := g_txtFile + cutExtraText(bankAccount."Bank Account No.", 11) + addBufferSpace(cutExtraText(bankAccount."Bank Account No.", 11), 11); //bankAccount."Bank Account No.";
            g_txtFile := g_txtFile + cutExtraText(FirstBankAccNo, 11) + addBufferSpace(cutExtraText(FirstBankAccNo, 11), 11); //bankAccount."Bank Account No.";


            // #6 Bank account name (140) - <custom>
            //g_txtFile := g_txtFile + cutExtraText(bankAccount."Name Holder", 140) + addBufferSpace(cutExtraText(bankAccount."Name Holder", 140), 140);
            g_txtFile := g_txtFile + cutExtraText(FirstNameHolder, 140) + addBufferSpace(cutExtraText(FirstNameHolder, 140), 140);

            // #7 Posting Date (Creation date) (8)
            g_txtFile := g_txtFile + txtPostYear + txtPostMonth + txtPostDay;//Format(TempGenJnLine."Posting Date");

            // #8 Posting Date (Value date) (8)
            g_txtFile := g_txtFile + txtPostYear + txtPostMonth + txtPostDay;

            // #9 - hardcoded (3)
            g_txtFile := g_txtFile + 'MYR';

            // #10 - To fill with space (55)
            g_txtFile := g_txtFile + addSpace(55);

            // #11 - To fill with space (16)
            g_txtFile := g_txtFile + addSpace(16);

            // #12 - To fill with space (105)
            g_txtFile := g_txtFile + addSpace(105);

            // #13 - To fill with space (105)
            g_txtFile := g_txtFile + addSpace(105);

            // #14 - To fill with space (1335)
            g_txtFile := g_txtFile + addSpace(1335);

            OutStr.WriteText(g_txtFile + CR + LF);
            //OutStr.WriteText(g_txtFile + CR + LF);
            //-------------------Batch Header ends----------------------//


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
                            //--------------------Batch details start----------------------//

                            Clear(g_txtFile);

                            // #1 Record type - Hardcoded
                            g_txtFile := g_txtFile + '2';

                            // #2 Processing mode (Instant Transfer) - Hardcoded 
                            // #2 Processing mode (Duitnow) - Hardcoded
                            if (grec_GenJournalLine."Payment Method Code" = 'IT') then
                                g_txtFile := g_txtFile + 'I'
                            else
                                if (grec_GenJournalLine."Payment Method Code" = 'DUITNOW') then
                                    g_txtFile := g_txtFile + 'D';

                            // #3 Bankcode (Instant Transfer) - vend bank swift code
                            // #3 Bankcode (Duitnow) - Bankcode
                            // Left justified, space for unused space
                            if (grec_GenJournalLine."Payment Method Code" = 'IT') then
                                g_txtFile := g_txtFile + cutExtraText(VendBankAcc."SWIFT Code", 11) + addBufferSpace(cutExtraText(VendBankAcc."SWIFT Code", 11), 11)
                            else
                                if (grec_GenJournalLine."Payment Method Code" = 'DUITNOW') then
                                    g_txtFile := g_txtFile + cutExtraText(VendBankAcc.Code, 11) + addBufferSpace(cutExtraText(VendBankAcc.Code, 11), 11);
                            //L1 := calcHash(VendBankAcc."SWIFT Code");
                            //g_txtFile := g_txtFile + BankAccCode + ' ';

                            // #4 vend bank account no
                            // Left justified, space for unused space
                            g_txtFile := g_txtFile + VendBankAcc."Bank Account No." + addBufferSpace(VendBankAcc."Bank Account No.", 34);
                            //g_txtFile := //#5
                            //L2 := calcHash(VendBankAcc."Bank Account No.");

                            // #5 Bank acc type - <custom>
                            // Left justified, space for unused space
                            g_txtFile := g_txtFile + VendBankAcc."Bank Account Type" + addBufferSpace(VendBankAcc."Bank Account Type", 4);

                            // #6 vend bank name (140)
                            //Instant transfer = Vendor Bank Account. Name, for Duitnow = empty (space)
                            if (grec_GenJournalLine."Payment Method Code" = 'IT') then
                                g_txtFile := g_txtFile + VendBankAcc.Name + addBufferSpace(VendBankAcc.Name, 140)
                            else
                                if (grec_GenJournalLine."Payment Method Code" = 'DUITNOW') then
                                    g_txtFile := g_txtFile + addSpace(140);
                            //L3 := calcHash(VendBankAcc.Name);

                            // #7 Transaction code (2)
                            g_txtFile := g_txtFile + grec_GenJournalLine."Transaction Code"; // #7 transaction code (2)

                            //#8 paym journal Amount (18), Right padding with trailing zeros
                            paymJourAmount := DelChr(Format(grec_GenJournalLine.Amount), '=>', '.');
                            paymJourAmount := DelChr(Format(paymJourAmount), '<=', ',');
                            paymJourAmount := PadStr('', 18 - StrLen(paymJourAmount), '0') + paymJourAmount;
                            g_txtFile := g_txtFile + paymJourAmount;
                            //L5 := calcHash(paymJourAmount);

                            // #9 currency code (3) - hardcoded
                            g_txtFile := g_txtFile + 'MYR';
                            //L4 := calcHash('MYR');

                            //#10 Other payment details (140) - To be filled with space
                            g_txtFile := g_txtFile + addSpace(140);

                            //#11 Payment Journal.Payment reference
                            g_txtFile := g_txtFile + cutExtraText(grec_GenJournalLine."Payment Reference", 40) + addBufferSpace(cutExtraText(grec_GenJournalLine."Payment Reference", 40), 40);

                            // #12 Filler (257) - To be filled with space
                            g_txtFile := g_txtFile + addSpace(257);

                            // #13 Payment advice indicator (1) - hardcoded
                            g_txtFile := g_txtFile + 'Y';

                            // #14 Delivery mode (1) - hardcoded
                            g_txtFile := g_txtFile + 'E';

                            // #15 Advice format (1) - hardcoded 
                            g_txtFile := g_txtFile + '2';

                            // #16 vendor card.Vendor name
                            // Maybe this is supposed to be Vendor No.
                            g_txtFile := g_txtFile + cutExtraText(grec_Vendor.Name, 20) + addBufferSpace(cutExtraText(grec_Vendor.Name, 20), 20);

                            // #17 To be filled with space (10)
                            g_txtFile := g_txtFile + addSpace(10);

                            // #18 vendor card.Name (35) space after
                            g_txtFile := g_txtFile + cutExtraText(grec_Vendor.Name, 35) + addBufferSpace(cutExtraText(grec_Vendor.Name, 35), 35);

                            // #19 To be filled with space (35)
                            g_txtFile := g_txtFile + addSpace(35);

                            // #20 To be filled with space (35)
                            g_txtFile := g_txtFile + addSpace(35);

                            // #21 To be filled with space (35)
                            g_txtFile := g_txtFile + addSpace(35);

                            // #22 vendor card.Address 1 (35) space for padding
                            g_txtFile := g_txtFile + cutExtraText(grec_Vendor.Address, 35) + addBufferSpace(cutExtraText(grec_Vendor.Address, 35), 35);

                            // #23 vendor card.Address 2 (35)
                            g_txtFile := g_txtFile + cutExtraText(grec_Vendor."Address 2", 35) + addBufferSpace(cutExtraText(grec_Vendor."Address 2", 35), 35);

                            // #24 To be filled with space (35)
                            g_txtFile := g_txtFile + addSpace(35);

                            // #25 To be filled with space (35)
                            g_txtFile := g_txtFile + addSpace(35);

                            // #26 vendor card.city (17)
                            g_txtFile := g_txtFile + cutExtraText(grec_Vendor.City, 17) + addBufferSpace(cutExtraText(grec_Vendor.City, 17), 17);

                            // #27 vendor card.Country/region code (3)
                            g_txtFile := g_txtFile + cutExtraText(grec_Vendor."Country/Region Code", 3) + addBufferSpace(cutExtraText(grec_Vendor."Country/Region Code", 3), 3);

                            // #28 vendor card.Post code (15)
                            g_txtFile := g_txtFile + cutExtraText(grec_Vendor."Post Code", 15) + addBufferSpace(cutExtraText(grec_Vendor."Post Code", 15), 15);

                            // #29 vendor card.Email address (100)
                            g_txtFile := g_txtFile + grec_Vendor."E-Mail" + addBufferSpace(grec_Vendor."E-Mail", 100);

                            // #30 To be filled with space (100)
                            g_txtFile := g_txtFile + addSpace(100);

                            // #31 To be filled with space (100)
                            g_txtFile := g_txtFile + addSpace(100);

                            // #32 To be filled with space (100)
                            g_txtFile := g_txtFile + addSpace(100);

                            // #33 To be filled with space (100)
                            g_txtFile := g_txtFile + addSpace(100);

                            // #34 Company Information.Company Name (35) - right padding with space
                            g_txtFile := g_txtFile + cutExtraText(CompInfo.Name, 35) + addBufferSpace(cutExtraText(CompInfo.Name, 35), 35);

                            // #35 To be filled with space (35)
                            g_txtFile := g_txtFile + addSpace(35);

                            // #36 To be filled with space (16)
                            g_txtFile := g_txtFile + addSpace(16);

                            //#37 Custom Vendor Card.Citizenship (1) if on 'Y', else 'N'
                            if (grec_Vendor."DOT Citizenship" = true) then
                                g_txtFile := g_txtFile + 'Y'
                            else
                                g_txtFile := g_txtFile + 'N';

                            ////////////////////////////
                            // #38 Custom payment journal.Purpose Code (5) right padding with space
                            /*
                            if ((grec_GenJournalLine."Currency Code" <> 'MYR') or (grec_Vendor."DOT Citizenship" = false)) then begin
                                if (grec_GenJournalLine.amount <= 10000) then
                                    g_txtFile := g_txtFile + 'OP' + addSpace(3)
                                else
                                    if ((grec_GenJournalLine.amount >= 10001) and (grec_GenJournalLine.amount < 200001)) then
                                        g_txtFile := g_txtFile + 'BP' + addSpace(3)
                                    else
                                        if (grec_GenJournalLine.amount >= 200001) then
                                            g_txtFile := g_txtFile + 'P' + addSpace(4);
                            end;
                            */
    //Temporary
    //g_txtFile := g_txtFile + addSpace(5);
    /*///////////////////////////////////////////////////////////////////////////////
                            g_txtFile := g_txtFile + cutExtraText(grec_GenJournalLine."Purpose Code", 5) + addBufferSpace(grec_GenJournalLine."Purpose Code", 5);

                            ////////////////////////////

                            // #39 Custom payment journal.Reason of transaction (60) if LCY > 200,001
                            //Need to set condition for mandatory

                            if (grec_GenJournalLine."Amount" > 200001) then
                                g_txtFile := g_txtFile + cutExtraText(grec_GenJournalLine.ReasonTransaction, 60) + addBufferSpace(cutExtraText(grec_GenJournalLine.ReasonTransaction, 60), 60)
                            else
                                g_txtFile := g_txtFile + addSpace(60);

                            //Temporary
                            //g_txtFile := g_txtFile + addSpace(60);

                            // #40 Custom vendor card.Transaction relationship (1)
                            if (grec_Vendor."DOT Transaction relationship" = true) then
                                g_txtFile := g_txtFile + 'Y'
                            else
                                g_txtFile := g_txtFile + 'N';

                            // #41 to be filled with space (5)
                            g_txtFile := g_txtFile + addSpace(5);

                            //#42 to be filled with space (20)
                            g_txtFile := g_txtFile + addSpace(20);

                            // #43 to be filled with space (122)
                            g_txtFile := g_txtFile + addSpace(122);

                            OutStr.WriteText(g_txtFile + CR + LF);

                            //--------------Batch details end------------------//

                            //------------Payment advice starts---------------//

                            Clear(g_txtFile);

                            // #1 document type (1) - hardcoded
                            g_txtFile := g_txtFile + '4';

                            // #2 spacing lines 9(2) - left padding with zeros
                            g_txtFile := g_txtFile + addZero(1) + '2';

                            // #3 Payment advice details (Beneficiary advice line) (105)
                            g_txtFile := g_txtFile + grec_GenJournalLine."Beneficiary advice line" + addBufferSpace(grec_GenJournalLine."Beneficiary advice line", 105);

                            // #4 Filler (1691)
                            g_txtFile := g_txtFile + addSpace(1691);

                            OutStr.WriteText(g_txtFile + CR + LF);

                            //--------------Payment advice ends---------------//

                            rowCount += 1;
                        until grec_GenJournalLine.Next() = 0;

                    totalamount += Abs(TempGenJnLine.Amount);
                until TempGenJnLine.Next() = 0;


            Clear(g_txtFile);
            //-----------------Batch trailer starts----------------//
            // 3 fields left
            // #1 Record type (1) - hardcoded
            g_txtFile := g_txtFile + '9';

            // #2 paym journal amount(lcy) (18) 16 + 2
            g_txtFile := g_txtFile + addBufferZero(convertDecimal(totalamount), 18) + convertDecimal(totalamount);

            // #3 number of lines (7) zero left padding 
            g_txtFile := g_txtFile + addBufferZero(Format(rowCount), 7) + Format(rowCount);

            // #4 Hash Total (16)
            g_txtFile := g_txtFile + addSpace(16);

            // #5 Filler (1757)
            g_txtFile := g_txtFile + addSpace(1757);

            OutStr.WriteText(g_txtFile + CR + LF);
            //----------------Batch Trailer ends----------------//

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
            MESSAGE('%1 - E-Payment (UOB) has been exported!', FileName);
        end;

        procedure setVendorInfo(rVendor: Record Vendor; var VendorInfo: array[3] of text[200];
            vPaymentMode: code[20])
        var
            myInt: Integer;
        begin
            clear(VendorInfo);
            if (vPaymentMode = 'ACH') or (vPaymentMode = 'BT') or (vPaymentMode = 'TT') or (vPaymentMode = 'LBC') then begin
                if strlen(rVendor.Name) > 35 then begin
                    VendorInfo[1] := copystr(rVendor.Name, 1, 35);
                    if strlen(rVendor.Name) > 70 then begin
                        VendorInfo[2] := copystr(rVendor.Name, 36, 35);
                        VendorInfo[3] := copystr(rVendor.Name, 71, strlen(rVendor.Name) - 70);
                    end else
                        VendorInfo[2] := copystr(rVendor.Name, 36, strlen(rVendor.Name) - 35);
                end else
                    VendorInfo[1] := rVendor.Name;
            end;
            if (vPaymentMode = 'RTGS') then begin
                if strlen(rVendor.Name) > 95 then
                    VendorInfo[1] := copystr(rVendor.Name, 1, 95)
                else
                    VendorInfo[1] := rVendor.Name;
            end;
            VendorInfo[1] := DoubleQuoteWrap(VendorInfo[1]);
            VendorInfo[2] := DoubleQuoteWrap(VendorInfo[2]);
            VendorInfo[3] := DoubleQuoteWrap(VendorInfo[3]);
        end;

        procedure DoubleQuoteWrap(inputstring: Text): Text
        var
            myInt: Integer;
        begin
            exit('"' + inputstring + '"');
        end;

        procedure convertChar(inputString: Text): Text
        var
            charNo: Integer;
            ascii: Char;
            int: Integer;
            txtStr: Text;
            sumStr: Text;
        begin
            for int := 1 to StrLen(inputString) do begin
                charNo := inputString[int];
                txtStr += Format(charNo * int) + ' ';
                //sumStr += txtStr;
            end;
            exit(txtStr);
        end;

        procedure calcHash(input: Text): Integer
        var
            i, x, sum : integer;
        begin
            Clear(i);
            Clear(x);
            Clear(sum);

            for i := 1 to StrLen(input) do begin
                Evaluate(x, convertChar(input.Substring(i, 1)));
                sum := sum + (i * x);
            end;
            exit(sum);
        end;


        //Add zero based on input amount
        procedure addZero(Length: Integer): Text
        var
            returnZero: Text;
            i: Integer;
        begin
            clear(i);
            clear(returnZero);

            for i := 1 to Length do begin
                returnZero := returnZero + '0';
            end;
            exit(returnZero);
        end;
        //Add zero for unused allocated space
        procedure addBufferZero(Input: Text; MaxLength: Integer): Text
        var
            returnBufferZero: Text;
            i, difference : Integer;
        begin
            clear(i);
            clear(difference);
            clear(returnBufferZero);

            difference := MaxLength - StrLen(Input);
            if (difference > 0) then begin
                for i := 1 to difference do begin
                    returnBufferZero := returnBufferZero + '0';
                end;
            end else
                returnBufferZero := '';

            exit(returnBufferZero);
        end;
        //Add space based on input amount
        procedure addSpace(Length: Integer): Text
        var
            returnSpace: Text;
            i: Integer;
        begin
            clear(i);
            clear(returnSpace);

            for i := 1 to Length do begin
                returnSpace := returnSpace + ' ';
            end;
            exit(returnSpace);
        end;


        //Add space for unused allocated space
        procedure addBufferSpace(Input: Text; MaxLength: Integer): Text
        var
            returnBufferSpace: Text;
            i, difference : Integer;
        begin
            clear(i);
            clear(difference);
            clear(returnBufferSpace);

            difference := MaxLength - StrLen(Input);
            if (difference > 0) then begin
                for i := 1 to difference do begin
                    returnBufferSpace := returnBufferSpace + ' ';
                end;
            end else
                returnBufferSpace := '';

            exit(returnBufferSpace);
        end;

        //Cut extra characters for text that exceed max character amount
        procedure cutExtraText(Input: Text; MaxLength: Integer): Text
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

        //Convert Decimal to Text while maintaining at least 2 decimal places and removing any comma and period
        procedure convertDecimal(Input: Decimal): Text
        var
            Result: Decimal;
            ReturnText: Text;
        begin
            if ((Input - Round(Input, 1, '<')) <> 0) then begin
                //exit('Has remainder');
                ReturnText := DelChr(Format(Input), '=', '.');
                ReturnText := DelChr(Format(ReturnText), '=', ',');
                if (StrLen(DelChr(Format(Input - Round(Input, 1, '<')), '=', '.')) = 2) then
                    ReturnText := ReturnText + '0';
                Message('%1', DelChr(Format(Input - Round(Input, 1, '<')), '=', '.'));
                exit(ReturnText);
            end;
            //exit('Don''t have remainder');
            ReturnText := DelChr(Format(Input), '=', '.');
            ReturnText := DelChr(Format(ReturnText), '=', ',');
            ReturnText := ReturnText + '00';
            exit(ReturnText);

        end;
        */
}
