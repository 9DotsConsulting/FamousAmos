
reportextension 50100 SalesInvoices extends "Standard Sales - Invoice"
{
    //For posted sales invoice
    dataset
    {
        add(Header)
        {
            //Field 1: logo
            column(CompanyInfoLogo; CI.Picture) { }

            //Field 2.1: Invoice (No)
            column(No_; "No.") { }

            //Field 2.2: Customer No
            column(Customer_No_; "Sell-to Customer No.") { }

            //Field 3: Tax Invoice (Harcoded)


            //Field 4: Company Name
            column(CompanyInfoName; CI.Name) { }

            //Field 5: Company Address
            column(CompanyInfoAddress; CI.Address) { }
            column(CompanyInfoAddress2; CI."Address 2") { }
            column(CompanyInfoCity; CI.City) { }
            column(CompanyInfoCountry; CI."Country/Region Code") { }
            column(CompanyInfoPostCode; CI."Post Code") { }

            //Field 6: Company Tel
            column(CompanyInfoPhoneNo; CI."Phone No.") { }

            //Field 7: Company Fax
            column(CompanyInfoFaxNo; CI."Fax No.") { }

            //Field 8.1: Company GST Reg No - Cannot find the one stated in FDD
            column(CompanyInfoGSTRegNo; CI."VAT Registration No.") { }

            //Field 8.2: Company Reg No
            column(CompanyInfoRegNo; CI."Registration No.") { }

            //Field 9: Bill-To (Custom)
            //Field 9.1: Bill-to Name
            column(Bill_to_Name; "Bill-to Name") { }
            //Field 9.2: Bill-to Address
            column(Bill_to_Address; "Bill-to Address") { }
            //Field 9.3: Bill-to Address 2
            column(Bill_to_Address_2; "Bill-to Address 2") { }
            //Field 9.4: Bill-to City
            column(Bill_to_City; "Bill-to City") { }
            //Field 9.5: Bill-to Post Code
            column(Bill_to_Post_Code; "Bill-to Post Code") { }
            //Field 9.6: Bill-to Phone No
            column(Bill_to_Contact_No_; "Bill-to Contact No.") { }


            //Field 10: Ship-To (Custom)

            //Field 10.1: Ship-To Name
            column(Ship_to_Name; "Ship-to Name") { }
            //Field 10.2: Ship-To Address
            column(Ship_to_Address; "Ship-to Address") { }
            //Field 10.3: Ship-To Address 2
            column(Ship_to_Address_2; "Ship-to Address 2") { }
            //Field 10.4: Ship-To City
            column(Ship_to_City; "Ship-to City") { }
            //Field 10.5: Ship-To Post Code
            column(Ship_to_Post_Code; "Ship-to Post Code") { }
            //Field 10.6: Ship-To Phone No
            //Need to make custom field
            column(Ship_to_Phone_No_; ShiptoPhoneNo) { }


            //Field 11: Date (Document Date)
            column(Date; "Document Date") { }

            //Field 12: Delivery Order No (Your Reference) - Temporary link for Phase 1
            //column(Delivery_Order_No; "Your Reference") { }
            //column(Delivery_Order_No; DO_NO_) { } //comment out by Clarissa

            column(Delivery_Order_No; Delivery_Order_No) { }

            //Field 13: Terms (Payment Terms code)
            column(Payment_Terms_Code; "Payment Terms Code") { }

            //Field 14: Purchase Order No (External Document No)
            column(Purchase_Order_No_; "External Document No.") { }

            //Field 15: Doesn't exist in FDD


            //Field 16: Order Date (Document Date)
            column(Order_Date; Order_Date) { }

            //Field 17: Sales Person Code: (Salesperson Code)
            column(Salesperson_Code; "Salesperson Code") { }

            //Field 18: Sales Order No (Leave blank for phase 1)
            //Phase 2
            column(Order_No_; "Order No.") { }

            //Field 26: Custom field
            column(Deliver_On; "Deliver On") { }
            column(Currency_Code; Curr_Code) { }
            column(Comment_Line; CommentLine) { }
            //column(Note; Note) { }
            column(Note; GetFixedNote()) { }
            //column(CompBankAcc; CI."Bank Account No.") { }
            column(ContactName; "Sell-to Contact") { }
            column(PhoneNo; "Sell-to Phone No.") { }
            column(Bill_to_Contact; "Bill-to Contact") { }
            column(Ship_to_Contact; "Ship-to Contact") { }
            column(DescriptionLine; DescriptionLine) { }

        }
        add(Line)
        {

            //--------------------Invoice Item part-------------------------//

            //Field 19: S/N (sequence number)
            column(RunningNo; "DOT Line No.") { }
            //Field 20: Product Code (No) - Phase 1 uses No based on G/L acc no
            //column(Line_No_; "No.") { }
            column(Line_No_; LineNo) { }

            //Field 21: Description (comment) - Refer to appendix section

            // column(DescriptionLine; DescriptionLine) { }

            //Field 22: Quantity - Renamed as 'Qty' (Need to sum up - refer to appendix)
            column(Quantity; Quantity) { }
            //column(Quantity; TLineQTY) { }

            //Field 23: Unit Price - Renamed as 'U/P'
            //column(Unit_Price_Excl_GST; "Unit Price") { }
            //column(Unit_Price_Excl_GST; TLineUP) { }

            //Field 24: DISC. (Discount Amount)
            column(Line_Discount_Amount; "Line Discount Amount") { }
            //column(Line_Discount_Amount; TLineDisc) { }

            //Field 25: Amount
            column(Line_Amount_Excl_GST; "Line Amount") { }
            //column(Line_Amount_Excl_GST; TLineAmount) { }
            column(Item_Group_No_; "Item Group No.") { }
            column(Unit_Price; "Unit Price") { }

            //Field 26: Custom field

            //--------------------Total up section part-------------------------//

            //Field 27: 

            //Field 27.1:  Amt Excl. GST

            //Field 27.2: Inv. Discount

            //Field 27.3: Total Excl. GST

            //Field 27.4: GST

            //Field 27.5: Total Incl. GST

            column(PrintLine; PrintLine) { }
        }
        addbefore(Totals)
        {
            dataitem(SetIndicator; "Sales Invoice Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemLinkReference = Header;
                DataItemTableView = sorting("Document No.", "Line No.");
                //DataItemTableView = sorting("Line No.");
                UseTemporary = true;

                column(Set_Indicator; "Set Indicator") { }
                // column(Unit_Price; "Unit Price") { }
                column(Qty; Quantity) { }
                //column(TotalPerSet;) { }
            }
        }
        modify(header)
        {
            trigger OnAfterAfterGetRecord()
            var
                SIL: Record "Sales Invoice Line";
                SH: Record "Sales Header";
                ShipmentNo: code[20];
            begin
                if ("Currency Code" = '') then
                    Curr_Code := 'SGD';

                ShiptoPhoneNo := GetShipToPhoneNo("Sell-to Customer No.");
                //DO_NO_ := GetDONoGL("No.", "Sell-to Customer No.", "Order No.");

                SIL.reset;
                SIL.SetRange("Document No.", Header."No.");
                if SIL.findfirst then begin
                    //repeat
                    ShipmentNo := SIL."Shipment No.";
                    if SIL.Type = "Sales Line Type"::"G/L Account" then DescriptionLine := SIL.Description;
                end;
                //until SIL.next = 0;
                if SIL.findlast then
                    Delivery_Order_No := ShipmentNo + '~' + SIL."Shipment No."
                else
                    Delivery_Order_No := ShipmentNo;

                SH.reset;
                SH.SetRange("No.", Header."Order No.");
                if SH.findfirst then
                    Order_Date := SH."Order Date";
            end;
        }


        modify(Line)
        {
            trigger OnAfterAfterGetRecord()
            var
                SIL, rSIL : Record "Sales Invoice Line";
                tmpSIL: Record "Sales Invoice Line" temporary;
                ok: Boolean;
                CRLF: Text[2];
            begin
                // remove as of not using below code
                // currentLine := Line;
                // if "Line No." < CountNo then
                //     RunningNo := 0;
                // if (RunningNo >= 1) then begin
                //     SIL.SetRange("Document No.", "Document No.");
                //     if SIL.FindFirst then ok := true;
                //     if (Type.AsInteger() <> 0) and (currentLine."Item Group No." <> SIL."Item Group No.") OR (currentLine."Unit Price" <> SIL."Unit Price") then begin
                //         RunningNo += 1;
                //         SIL := currentLine;
                //     end;
                //     //CountNo := "Line No." + RunningNo;
                // end else if (Type.AsInteger() <> 0) and (currentLine."Item Group No." <> SIL."Item Group No.") AND (currentLine."Unit Price" <> SIL."Unit Price") then begin
                //     RunningNo += 1;
                //     SIL := currentLine;
                // end;
                Clear(CommentLine);
                CRLF[1] := 13;
                CRLF[2] := 10;
                SCL.Reset;
                SCL.SetFilter("Document Type", 'Posted Invoice');
                SCL.SetRange("No.", "Document No.");
                SCL.SetRange("Document Line No.", "Line No.");
                SCL.SetAscending("Line No.", false);
                if SCL.FindSet then
                    repeat
                        CommentLine := SCL.Comment + CRLF + CommentLine;
                    until SCL.Next = 0;

                // SIL.FindFirst();
                // if SIL.Type = Type::"G/L Account" then DescriptionLine := SIL.Description;

                // SIL.Reset();
                // SIL.SetRange("Document No.", "Document No.");
                // if SIL.FindFirst() then begin
                //     //repeat
                //     rSIL.Reset;
                //     rSIL.SetRange("Document No.", SIL."Document No.");
                //     rSIL.SetRange("No.", SIL."No.");
                //     if rSIL.FindFirst then
                //         repeat
                //             tmpSIL.SetRange("Document No.", rSIL."Document No.");
                //             tmpSIL.SetRange("No.", rSIL."No.");
                //             tmpSIL.SetRange("Item Group No.", rSIL."Item Group No.");
                //             tmpSIL.SetRange("Unit Price", rSIL."Unit Price");
                //             if tmpSIL.FindFirst() then
                //                 Message('sama') else begin
                //                 RunningNo += 1;
                //                 tmpSIL := rSIL;
                //             end;
                //         until rSIL.Next() = 0;
                // end;

                //CommentLine := GetComment("Document No.", "Line No.");

                // ' ' for Comment Type
                // 'G/L Account' for G/L type
                /*
                if (Format(Type) = ' ') then begin
                    DescriptionLine := Description;
                end;

                NewGroupNo := "Item Group No.";
                if (NewGroupNo <> OldGroupNo) then begin

                    PrintLine := True;
                    OldGroupNo := NewGroupNo;
                    CommentLine := GetComment("Document No.", "Line No.");
                    RunningNo += 1;
                end
                else begin
                    CommentLine := '';
                    RunningNo := 0;
                end;

                if (Format(Type) = 'G/L Account') then begin
                    LineNo := "No.";
                end;
                */

                /*
                                if (Format(Type) = ' ') then begin
                                    CommentLine := Description;
                                end
                                else begin
                                    CommentLine := GetComment("Document No.", "Line No.", "Sell-to Customer No.");
                                    RunningNo += 1;
                                end;
                */
                /*
                                if (Format(Type) = ' ') then begin
                                    DescriptionLine := Description;
                                    PrintLine := True;
                                end;

                                NewGroupNo := "Item Group No.";
                                if (NewGroupNo <> OldGroupNo) then begin

                                    PrintLine := True;
                                    OldGroupNo := NewGroupNo;
                                    CommentLine := GetComment("Document No.", "Line No.", "Sell-to Customer No.");
                                    RunningNo += 1;
                                end
                                else begin
                                    CommentLine := '';
                                    //RunningNo := 0;
                                    PrintLine := False;
                                end;

                                if (Format(Type) = 'G/L Account') then begin
                                    LineNo := "No.";
                                end;
                */
                //TLineQty := GetTotalGroup(1, "Sell-to Customer No.", "Document No.", "Line No.", "Item Group No.");
                //TLineUP := GetTotalGroup(2, "Sell-to Customer No.", "Document No.", "Line No.", "Item Group No.");
                //TLineDisc := GetTotalGroup(3, "Sell-to Customer No.", "Document No.", "Line No.", "Item Group No.");
                //TLineAmount := GetTotalGroup(4, "Sell-to Customer No.", "Document No.", "Line No.", "Item Group No.");
                /*
                NewGroupNo := "Item Group No.";
                TLineQty := 0;
                TLineUP := 0;
                TLineDisc := 0;
                TLineAmount := 0;

                if (Type.AsInteger() = 0) then begin
                    CommentLine := Description;
                    PrintLine := True;
                end
                else
                    if (Type.AsInteger() = 1) and (NewGroupNo <> OldGroupNo) then begin
                        CommentLine := GetComment("Document No.", "Line No.", "Sell-to Customer No.");
                        TLineQty := GetTotalGroup(1, "Sell-to Customer No.", "Document No.", "Line No.", "Item Group No.");
                        TLineUP := GetTotalGroup(2, "Sell-to Customer No.", "Document No.", "Line No.", "Item Group No.");
                        TLineDisc := GetTotalGroup(3, "Sell-to Customer No.", "Document No.", "Line No.", "Item Group No.");
                        TLineAmount := GetTotalGroup(4, "Sell-to Customer No.", "Document No.", "Line No.", "Item Group No.");

                        if (CommentLine = '') then begin
                            CommentLine := Description;
                        end;

                        PrintLine := true;
                        OldGroupNo := NewGroupNo;
                        RunningNo += 1;
                        LineNo := "No.";
                    end
                    else
                        PrintLine := false;
                        */

                /*
                //Set the current line value
                NewNo := "No.";
                NewGroupNo := "Item Group No.";
                NewUP := "Unit Price";

                //Reset total for line value
                TLineQty := 0;
                TLineUP := 0;
                TLineDisc := 0;
                TLineAmount := 0;

                //Get the description for description only line
                Message(Format(NewNo));
                if (Type.AsInteger() = 0) then begin
                    CommentLine := Description;
                    PrintLine := True;
                end
                else
                    if (Type.AsInteger() = 1) then begin
                        Message('Passed type check');
                        if (NewNo <> OldNo) then
                            if (NewGroupNo <> OldGroupNo) and (NewUP <> OldUP) then begin

                                CommentLine := GetComment("Document No.", "Line No.", "Sell-to Customer No.");
                                TLineQty := GetTotalGroup(1, "Sell-to Customer No.", "Document No.", "Line No.", "No.", "Item Group No.", "Unit Price");
                                TLineUP := GetTotalGroup(2, "Sell-to Customer No.", "Document No.", "Line No.", "No.", "Item Group No.", "Unit Price");
                                TLineDisc := GetTotalGroup(3, "Sell-to Customer No.", "Document No.", "Line No.", "No.", "Item Group No.", "Unit Price");
                                TLineAmount := GetTotalGroup(4, "Sell-to Customer No.", "Document No.", "Line No.", "No.", "Item Group No.", "Unit Price");

                                PrintLine := true;
                                OldNo := NewNo;
                                OldGroupNo := NewGroupNo;
                                OldUP := NewUP;
                                RunningNo += 1;
                            end else
                                if (NewNo = OldNo) then
                                    if (NewGroupNo <> OldGroupNo) and (NewUP <> OldUP) then begin

                                        CommentLine := GetComment("Document No.", "Line No.", "Sell-to Customer No.");
                                        TLineQty := GetTotalGroup(1, "Sell-to Customer No.", "Document No.", "Line No.", "No.", "Item Group No.", "Unit Price");
                                        TLineUP := GetTotalGroup(2, "Sell-to Customer No.", "Document No.", "Line No.", "No.", "Item Group No.", "Unit Price");
                                        TLineDisc := GetTotalGroup(3, "Sell-to Customer No.", "Document No.", "Line No.", "No.", "Item Group No.", "Unit Price");
                                        TLineAmount := GetTotalGroup(4, "Sell-to Customer No.", "Document No.", "Line No.", "No.", "Item Group No.", "Unit Price");

                                        PrintLine := true;
                                        OldNo := NewNo;
                                        OldGroupNo := NewGroupNo;
                                        OldUP := NewUP;
                                        RunningNo += 1;
                                    end else
                                        PrintLine := false;
                    end;
                */

                /*
                //Set the current line value
                //NewNo := "No.";
                //GetGLNo("Document No.", "Line No.");
                GetDORange("Sell-to Customer No.", "Document No.", "Line No.");
                NewGroupNo := "Item Group No.";
                NewUP := "Unit Price";

                //Reset total for line value
                TLineQty := 0;
                TLineUP := 0;
                TLineDisc := 0;
                TLineAmount := 0;

                //Get the description for description only line
                //Message(Format(NewNo));
                if (Type.AsInteger() = 0) then begin
                    CommentLine := Description;
                    PrintLine := True;
                end
                else
                    if (Type.AsInteger() = 1) then begin

                        if (NewGroupNo <> OldGroupNo) then begin

                            CommentLine := GetComment("Document No.", "Line No.", "Sell-to Customer No.");
                            TLineQty := GetTotalGroup(1, "Sell-to Customer No.", "Document No.", "Line No.", "Item Group No.", "Unit Price");
                            TLineUP := GetTotalGroup(2, "Sell-to Customer No.", "Document No.", "Line No.", "Item Group No.", "Unit Price");
                            TLineDisc := GetTotalGroup(3, "Sell-to Customer No.", "Document No.", "Line No.", "Item Group No.", "Unit Price");
                            TLineAmount := GetTotalGroup(4, "Sell-to Customer No.", "Document No.", "Line No.", "Item Group No.", "Unit Price");

                            PrintLine := true;
                            OldNo := NewNo;
                            OldGroupNo := NewGroupNo;
                            OldUP := NewUP;
                            RunningNo += 1;
                        end else
                            if (NewGroupNo = OldGroupNo) and (NewUP <> OldUP) then begin

                                CommentLine := GetComment("Document No.", "Line No.", "Sell-to Customer No.");
                                TLineQty := GetTotalGroup(1, "Sell-to Customer No.", "Document No.", "Line No.", "Item Group No.", "Unit Price");
                                TLineUP := GetTotalGroup(2, "Sell-to Customer No.", "Document No.", "Line No.", "Item Group No.", "Unit Price");
                                TLineDisc := GetTotalGroup(3, "Sell-to Customer No.", "Document No.", "Line No.", "Item Group No.", "Unit Price");
                                TLineAmount := GetTotalGroup(4, "Sell-to Customer No.", "Document No.", "Line No.", "Item Group No.", "Unit Price");

                                PrintLine := true;
                                OldNo := NewNo;
                                OldGroupNo := NewGroupNo;
                                OldUP := NewUP;
                                RunningNo += 1;

                            end else
                                PrintLine := false;
                    end;
                    */

                //Test
                //FindGroupSet("Sell-to Customer No.", "No.", "Line No.", GetGLNo("Document No.", "Line No."));
                //FindGroupSet("Sell-to Customer No.", "Document No.", "Line No.", GetGLNo("Document No.", "Line No."));

                //Set the current line value
                //NewNo := "No.";
                NewNo := GetGLNo("Document No.", "Line No.");
                NewGroupNo := "Item Group No.";
                NewUP := "Unit Price";

                //Reset total for line value
                TLineQty := 0;
                TLineUP := 0;
                TLineDisc := 0;
                TLineAmount := 0;

                //Get the description for description only line
                //Message(Format(NewNo));
                // if (Type.AsInteger() = 0) then begin
                //     CommentLine := Description;
                //     PrintLine := True;
                // end
                // else
                //     if (Type.AsInteger() = 1) then begin
                //         if (NewNo <> OldNo) then
                //             if (NewGroupNo <> OldGroupNo) and (NewUP <> OldUP) then begin

                //                 CommentLine := GetComment("Document No.", "Line No.", "Sell-to Customer No.");
                //                 TLineQty := GetTotalGroup(1, "Sell-to Customer No.", "Document No.", "Line No.", NewNo, "Item Group No.", "Unit Price");
                //                 TLineUP := GetTotalGroup(2, "Sell-to Customer No.", "Document No.", "Line No.", NewNo, "Item Group No.", "Unit Price");
                //                 TLineDisc := GetTotalGroup(3, "Sell-to Customer No.", "Document No.", "Line No.", NewNo, "Item Group No.", "Unit Price");
                //                 TLineAmount := GetTotalGroup(4, "Sell-to Customer No.", "Document No.", "Line No.", NewNo, "Item Group No.", "Unit Price");

                //                 PrintLine := true;
                //                 OldNo := NewNo;
                //                 OldGroupNo := NewGroupNo;
                //                 OldUP := NewUP;
                //                 RunningNo += 1;
                //             end else
                //                 if (NewNo = OldNo) then
                //                     if (NewGroupNo <> OldGroupNo) and (NewUP <> OldUP) then begin

                //                         CommentLine := GetComment("Document No.", "Line No.", "Sell-to Customer No.");
                //                         TLineQty := GetTotalGroup(1, "Sell-to Customer No.", "Document No.", "Line No.", NewNo, "Item Group No.", "Unit Price");
                //                         TLineUP := GetTotalGroup(2, "Sell-to Customer No.", "Document No.", "Line No.", NewNo, "Item Group No.", "Unit Price");
                //                         TLineDisc := GetTotalGroup(3, "Sell-to Customer No.", "Document No.", "Line No.", NewNo, "Item Group No.", "Unit Price");
                //                         TLineAmount := GetTotalGroup(4, "Sell-to Customer No.", "Document No.", "Line No.", NewNo, "Item Group No.", "Unit Price");

                //                         PrintLine := true;
                //                         OldNo := NewNo;
                //                         OldGroupNo := NewGroupNo;
                //                         OldUP := NewUP;
                //                         RunningNo += 1;
                //                     end else
                //                         PrintLine := false;
                //         //end;
                //     end
                //     else if (Type.AsInteger() > 1) then
                PrintLine := true;
            end;

        }
    }

    rendering
    {
        layout("Famous Amos - Sales Invoices")
        {
            Type = RDLC;
            //Type = Word;
            LayoutFile = './reportextlayout/ReportExt50100_1306_SalesInvoices.rdlc';
            //LayoutFile = './reportextlayout/ReportExt50100_1306_SalesInvoices.docx';
        }
    }

    local procedure FindGroupSet(SellCustNo: Code[20]; DocNo: Code[20]; LineNo: Integer; GLNo: Text)
    var
        SIH: Record "Sales Invoice Header";
        SIL: Record "Sales Invoice Line";


        //For comparing and filtering line
        OldGroupNo, NewGroupNo : Code[20];
        OldNo, NewNo : Code[20];
        OldUP, NewUP : Decimal;

        testText: Text;
        CR, LF : Char;

        Counter: Integer;

    begin
        Counter := 0;
        CR := 13;
        LF := 10;
        //DocNo is from Header."No."
        SIL.SetFilter("Sell-to Customer No.", SellCustNo);
        SIL.SetFilter("Document No.", DocNo);
        //SIL.SetFilter("Line No.", Format(LineNo));
        SIL.SetFilter(Type, 'G/L Account');
        //SIL.SetFilter("No.", GLNo);
        SIL.SetRange("Line No.");
        if SIL.FindSet() then begin
            repeat
                //Message('Item Group No: %1, Unit Price: %2, Quantity: %3', SIL."Item Group No.", SIL."Unit Price", SIL.Quantity);
                if SIL."Item Group No." <> '' then
                    testText := testText + StrSubstNo('Sell-to Cust No: %1, Document No: %2, Item Group No: %3, Unit Price: %4, Quantity: %5', SIL."Sell-to Customer No.", SIL."Document No.", SIL."Item Group No.", SIL."Unit Price", SIL.Quantity) + CR + LF;
            until SIL.Next() = 0;
            //Message(testText);
        end;

        testText := '';

        SIL.Reset();
        SIL.SetFilter("Sell-to Customer No.", SellCustNo);
        SIL.SetFilter("Document No.", DocNo);
        //SIL.SetFilter("Line No.", Format(LineNo));
        SIL.SetFilter(Type, 'G/L Account');
        //SIL.SetFilter("No.", GLNo);
        SIL.SetRange("Line No.");
        if SIL.FindSet() then begin
            repeat
                if SIL."Item Group No." <> '' then begin
                    NewGroupNo := SIL."Item Group No.";
                    NewUP := SIL."Unit Price";
                    if (NewGroupNo <> OldGroupNo) and (NewUP <> OldUP) then begin
                        testText := testText + StrSubstNo('Item Group No: %1, Unit Price: %2, Quantity: %3', SIL."Item Group No.", SIL."Unit Price", SIL.Quantity) + CR + LF;
                        OldGroupNo := NewGroupNo;
                        OldUP := NewUP;
                    end;
                end;
            until SIL.Next() = 0;
            //Message(testText);
        end;

        testText := '';

        SIL.Reset();
        SIL.SetFilter("Sell-to Customer No.", SellCustNo);
        SIL.SetFilter("Document No.", DocNo);
        //SIL.SetFilter("Line No.", Format(LineNo));
        SIL.SetFilter(Type, 'G/L Account');
        //SIL.SetFilter("No.", GLNo);
        SIL.SetRange("Line No.");
        if SIL.FindSet() then begin
            repeat
                if SIL."Item Group No." <> '' then begin
                    NewGroupNo := SIL."Item Group No.";
                    NewUP := SIL."Unit Price";
                    if SIL.Type.AsInteger() = 1 then begin
                        if (NewGroupNo <> OldGroupNo) and (NewUP <> OldUP) then begin
                            //testText := testText + StrSubstNo('Item Group No: %1, Unit Price: %2, Quantity: %3', SIL."Item Group No.", SIL."Unit Price", SIL.Quantity) + CR + LF;
                            Counter += 1;
                            testText := testText + 'Set No.: ' + Format(Counter) + CR + LF;
                            testText := testText + 'Line Comment: ' + GetComment(SIL."Document No.", SIL."Line No.", SIL."Sell-to Customer No.") + CR + LF;
                            testText := testText + 'Total Line Quantity: ' + Format(GetTotalGroup(1, SIL."Sell-to Customer No.", SIL."Document No.", SIL."Line No.", NewGroupNo, NewUP)) + CR + LF;
                            testText := testText + 'Total Line Unit Price: ' + Format(GetTotalGroup(2, SIL."Sell-to Customer No.", SIL."Document No.", SIL."Line No.", NewGroupNo, NewUP)) + CR + LF;
                            testText := testText + 'Total Line Discount: ' + Format(GetTotalGroup(3, SIL."Sell-to Customer No.", SIL."Document No.", SIL."Line No.", NewGroupNo, NewUP)) + CR + LF;
                            testText := testText + 'Total Line Amount: ' + Format(GetTotalGroup(4, SIL."Sell-to Customer No.", SIL."Document No.", SIL."Line No.", NewGroupNo, NewUP)) + CR + LF;
                            // CommentLine := GetComment("Document No.", "Line No.", "Sell-to Customer No.");
                            // TLineQty := GetTotalGroup(1, "Sell-to Customer No.", "Document No.", "Line No.", NewNo, "Item Group No.", "Unit Price");
                            // TLineUP := GetTotalGroup(2, "Sell-to Customer No.", "Document No.", "Line No.", NewNo, "Item Group No.", "Unit Price");
                            // TLineDisc := GetTotalGroup(3, "Sell-to Customer No.", "Document No.", "Line No.", NewNo, "Item Group No.", "Unit Price");
                            // TLineAmount := GetTotalGroup(4, "Sell-to Customer No.", "Document No.", "Line No.", NewNo, "Item Group No.", "Unit Price");

                            OldGroupNo := NewGroupNo;
                            OldUP := NewUP;
                        end
                        else if (NewGroupNo <> OldGroupNo) and (NewUP = OldUP) then begin

                            Counter += 1;
                            testText := testText + 'Set No.: ' + Format(Counter) + CR + LF;
                            testText := testText + 'Line Comment: ' + GetComment(SIL."Document No.", SIL."Line No.", SIL."Sell-to Customer No.") + CR + LF;
                            testText := testText + 'Total Line Quantity: ' + Format(GetTotalGroup(1, SIL."Sell-to Customer No.", SIL."Document No.", SIL."Line No.", NewGroupNo, NewUP)) + CR + LF;
                            testText := testText + 'Total Line Unit Price: ' + Format(GetTotalGroup(2, SIL."Sell-to Customer No.", SIL."Document No.", SIL."Line No.", NewGroupNo, NewUP)) + CR + LF;
                            testText := testText + 'Total Line Discount: ' + Format(GetTotalGroup(3, SIL."Sell-to Customer No.", SIL."Document No.", SIL."Line No.", NewGroupNo, NewUP)) + CR + LF;
                            testText := testText + 'Total Line Amount: ' + Format(GetTotalGroup(4, SIL."Sell-to Customer No.", SIL."Document No.", SIL."Line No.", NewGroupNo, NewUP)) + CR + LF;

                            OldGroupNo := NewGroupNo;
                            OldUP := NewUP;
                        end
                        else if (NewGroupNo = OldGroupNo) and (NewUP <> OldUP) then begin

                            Counter += 1;
                            testText := testText + 'Set No.: ' + Format(Counter) + CR + LF;
                            testText := testText + 'Line Comment: ' + GetComment(SIL."Document No.", SIL."Line No.", SIL."Sell-to Customer No.") + CR + LF;
                            testText := testText + 'Total Line Quantity: ' + Format(GetTotalGroup(1, SIL."Sell-to Customer No.", SIL."Document No.", SIL."Line No.", NewGroupNo, NewUP)) + CR + LF;
                            testText := testText + 'Total Line Unit Price: ' + Format(GetTotalGroup(2, SIL."Sell-to Customer No.", SIL."Document No.", SIL."Line No.", NewGroupNo, NewUP)) + CR + LF;
                            testText := testText + 'Total Line Discount: ' + Format(GetTotalGroup(3, SIL."Sell-to Customer No.", SIL."Document No.", SIL."Line No.", NewGroupNo, NewUP)) + CR + LF;
                            testText := testText + 'Total Line Amount: ' + Format(GetTotalGroup(4, SIL."Sell-to Customer No.", SIL."Document No.", SIL."Line No.", NewGroupNo, NewUP)) + CR + LF;

                            OldGroupNo := NewGroupNo;
                            OldUP := NewUP;
                        end;
                    end;

                end;
            until SIL.Next() = 0;
            Message(testText);
        end;
    end;


    local procedure GetShipToPhoneNo(SellToCustNo: Code[20]): Text
    var
        ShipToAdd: Record "Ship-to Address";

    begin
        ShipToAdd.Reset();

        /*
        if (ShipToAdd.Get(SellToCustNo)) then begin
            exit(ShipToAdd."Phone No.");
        end;
        */
        ShipToAdd.SetFilter("Customer No.", SellToCustNo);
        if (ShipToAdd.FindSet()) then begin
            exit(ShipToAdd."Phone No.");
        end;


    end;

    /*
        local procedure GetBillToPhoneNo(SellToCustNo: Code[20]): Text
        var
            ShipToAdd: Record "Ship-to Address";

        begin
            ShipToAdd.Reset();
            //ShipToAdd.SetFilter("Customer No.", SellToCustNo);
            if (ShipToAdd.Get(SellToCustNo)) then begin
                exit(ShipToAdd."Phone No.");
            end;
        end;
    */

    //Get GLNO
    procedure GetGLNo(DocNo: Code[20]; LineNo: Integer): Text
    var
        SIL: Record "Sales Invoice Line";
    begin
        SIL.Reset();
        SIL.SetFilter("Document No.", DocNo);
        SIL.SetFilter("Line No.", Format(LineNo));
        SIL.SetFilter(Type, 'G/L Account');
        if (SIL.FindFirst()) then begin
            //Message(Format(SIL."No."));
            exit(Format(SIL."No."));
        end
        else
            exit('');
    end;

    /*
        local procedure GetDONo(No: Code[20]): Text
        var
            ValueEntry: Record "Value Entry";
            ItemLedgerEntry: Record "Item Ledger Entry";
            //DONumber: Text;

            HighestItem: Text;
            Lowest: Text;
            OutputText: Text;
        begin
            clear(ValueEntry);
            ValueEntry.SetRange("Item Ledger Entry Type", "Item Ledger Entry Type"::Sale);
            ValueEntry.SetRange("Document No.", No);
            if ValueEntry.FindFirst() then begin
                repeat
                    clear(ItemLedgerEntry);
                    ItemLedgerEntry.SetRange("Entry Type", "Item Ledger Entry Type"::Sale);
                    ItemLedgerEntry.SetRange("Document Type", "Item Ledger Document Type"::"Sales Shipment");
                    ItemLedgerEntry.SetRange("Entry No.", ValueEntry."Item Ledger Entry No.");
                    if (ItemLedgerEntry.FindFirst()) then begin

                        //if (DONumber = '') then
                            //DONumber := ItemLedgerEntry."Document No." else
                            //DONumber := DONumber + ',' + ItemLedgerEntry."Document No.";

                        if (Lowest = '') then
                            Lowest := ItemLedgerEntry."Document No.";
                        if (Lowest > ItemLedgerEntry."Document No.") then
                            Lowest := ItemLedgerEntry."Document No.";
                        if (HighestItem = '') then
                            HighestItem := ItemLedgerEntry."Document No.";
                        if (HighestItem < ItemLedgerEntry."Document No.") then
                            HighestItem := ItemLedgerEntry."Document No.";
                    end;
                until ValueEntry.Next = 0;
            end;
            //exit(DONumber);
            if (Lowest = HighestItem) then begin
                OutputText := Lowest
            end else
                OutputText := Lowest + ' ~ ' + HighestItem;
            exit(OutputText);
        end;
    */

    local procedure GetDONoGL(No: Code[20]; SellToCustNo: Code[20]; OrderNo: Code[20]): Text
    var
        //For Type = Item
        ValueEntry: Record "Value Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        //For Type = G/L Account
        SalesShipmentLine: Record "Sales Shipment Line";

        //DONumber: Text;

        //For Type = Item
        HighestItem: Text;
        LowestItem: Text;
        //For Type = G/L Account
        HighestGL: Text;
        LowestGL: Text;

        //For output
        HighestText: Text;
        LowestText: Text;
        OutputText: Text;
    begin
        //Find the range of document no for related sales shipment line for Item type
        clear(ValueEntry);
        LowestItem := '';
        HighestItem := '';
        ValueEntry.SetRange("Item Ledger Entry Type", "Item Ledger Entry Type"::Sale);
        ValueEntry.SetRange("Document No.", No);
        if ValueEntry.FindFirst() then begin
            repeat
                clear(ItemLedgerEntry);
                ItemLedgerEntry.SetRange("Entry Type", "Item Ledger Entry Type"::Sale);
                ItemLedgerEntry.SetRange("Document Type", "Item Ledger Document Type"::"Sales Shipment");
                ItemLedgerEntry.SetRange("Entry No.", ValueEntry."Item Ledger Entry No.");
                if (ItemLedgerEntry.FindFirst()) then begin
                    /*
                    if (DONumber = '') then
                        DONumber := ItemLedgerEntry."Document No." else
                        DONumber := DONumber + ',' + ItemLedgerEntry."Document No.";
                    */
                    if (LowestItem = '') then
                        LowestItem := ItemLedgerEntry."Document No.";
                    if (LowestItem > ItemLedgerEntry."Document No.") then
                        LowestItem := ItemLedgerEntry."Document No.";
                    if (HighestItem = '') then
                        HighestItem := ItemLedgerEntry."Document No.";
                    if (HighestItem < ItemLedgerEntry."Document No.") then
                        HighestItem := ItemLedgerEntry."Document No.";
                end;
            until ValueEntry.Next = 0;
        end;
        //Find the range of document no for related sales shipment line for G/L Account type
        clear(SalesShipmentLine);
        LowestGL := '';
        HighestGL := '';
        SalesShipmentLine.SetFilter("Sell-to Customer No.", SellToCustNo);
        SalesShipmentLine.SetFilter(Type, 'G/L Account');
        SalesShipmentLine.Setfilter("Order No.", OrderNo);
        if (SalesShipmentLine.FindSet()) then begin
            repeat
                if (LowestGL = '') then
                    LowestGL := SalesShipmentLine."Document No.";
                if (LowestGL > SalesShipmentLine."Document No.") then
                    LowestGL := SalesShipmentLine."Document No.";
                if (HighestGL = '') then
                    HighestGL := SalesShipmentLine."Document No.";
                if (HighestGL < SalesShipmentLine."Document No.") then
                    HighestGL := SalesShipmentLine."Document No.";
            until SalesShipmentLine.Next = 0;
        end;

        //Setting the document no range

        if (LowestItem = '') and (LowestGL <> '') then
            LowestText := LowestGL
        else
            if (LowestGL = '') and (LowestItem <> '') then
                LowestText := LowestItem
            else
                if (LowestItem < LowestGL) then
                    LowestText := LowestItem
                else
                    LowestText := LowestGL;

        if (HighestItem > HighestGL) then
            HighestText := HighestItem
        else
            HighestText := HighestGL;

        if (LowestText = HighestText) then
            OutputText := LowestText
        else
            OutputText := LowestText + '~' + HighestText;

        exit(OutputText);

        //exit(DONumber);
    end;

    local procedure GetComment(DocNo: Code[20]; LineNo: Integer; STCNo: Code[20]): Text
    var

        SIL: Record "Sales Invoice Line";
        DocType: Text;
        CL: Text;
        CR, LF : Char;

    begin
        SCL.Reset();
        SIL.Reset();
        CR := 13;
        LF := 10;
        CL := '';
        DocType := 'Posted Invoice';
        SCL.SetFilter("Document Type", DocType);
        SCL.SetFilter("No.", Format(DocNo));
        SCL.SetFilter("Document Line No.", Format(LineNo));
        SIL.SetFilter("Sell-to Customer No.", STCNo);
        SIL.SetFilter("Document No.", DocNo);
        SIL.SetFilter("Line No.", Format(LineNo));


        if (SCL.FindSet()) then begin
            repeat
                CL += SCL.Comment + CR + LF;
            until (SCL.Next = 0);
            exit(CL);
        end
        else begin
            CL := '';
            exit(CL);
        end;

    end;

    local procedure GetTotalGroup(Cond: Integer; SellCustNo: Code[20]; DocNo: Code[20]; LineNo: Integer; ItemGroupNo: Code[20]; UnitPrice: Decimal): Decimal
    var
        SIL: Record "Sales Invoice Line";
        TLineQty: Decimal;
        TLineUP: Decimal;
        TLineDisc: Decimal;
        TLineAmount: Decimal;
    begin
        SIL.Reset();
        SIL.SetFilter("Sell-to Customer No.", SellCustNo);
        SIL.SetFilter("Document No.", DocNo);
        SIL.SetFilter("Item Group No.", ItemGroupNo);
        SIL.SetFilter("Unit Price", Format(UnitPrice));
        SIL.SetRange("Line No.");
        if (SIL.FindSet()) and (Cond = 1) then begin
            repeat
                TLineQty += SIL.Quantity;
            until (SIL.Next = 0);
            exit(TLineQty);
        end;
        if (SIL.FindSet()) and (Cond = 2) then begin
            repeat
                //TLineUP += SIL."Unit Price";
                TLineUP := SIL."Unit Price";
            until (SIL.Next = 0);
            exit(TLineUP);
        end;
        if (SIL.FindSet()) and (Cond = 3) then begin
            repeat
                TLineDisc += SIL."Line Discount Amount";
            until (SIL.Next = 0);
            exit(TLineDisc);
        end;
        if (SIL.FindSet()) and (Cond = 4) then begin
            repeat
                TLineAmount += SIL.Amount;
            until (SIL.Next = 0);
            exit(TLineAmount);
        end;
    end;

    local procedure GetTotalGroup(Cond: Integer; SellToCustNo: Code[20]; DocNo: Code[20]; LineNo: Integer; GLNo: Code[20]; ItemGroupNo: Code[20]; UnitPrice: Decimal): Decimal
    var
        SIL: Record "Sales Invoice Line";
        TLineQty: Decimal;
        TLineUP: Decimal;
        TLineDisc: Decimal;
        TLineAmount: Decimal;
    begin
        SIL.Reset();
        SIL.SetFilter("Sell-to Customer No.", SellToCustNo);
        SIL.SetFilter("Document No.", DocNo);
        SIL.SetFilter(Type, 'G/L Account');
        SIL.SetFilter("No.", GLNo);
        SIL.SetFilter("Item Group No.", ItemGroupNo);
        SIL.SetFilter("Unit Price", Format(UnitPrice));
        SIL.SetRange("Line No.");
        if (SIL.FindSet()) and (Cond = 1) then begin
            repeat
                TLineQty += SIL.Quantity;
            until (SIL.Next = 0);
            exit(TLineQty);
        end;
        if (SIL.FindSet()) and (Cond = 2) then begin
            repeat
                //TLineUP += SIL."Unit Price";
                TLineUP := SIL."Unit Price";
            until (SIL.Next = 0);
            exit(TLineUP);
        end;
        if (SIL.FindSet()) and (Cond = 3) then begin
            repeat
                TLineDisc += SIL."Line Discount Amount";
            until (SIL.Next = 0);
            exit(TLineDisc);
        end;
        if (SIL.FindSet()) and (Cond = 4) then begin
            repeat
                TLineAmount += SIL.Amount;
            until (SIL.Next = 0);
            exit(TLineAmount);
        end;
    end;


    /*
        local procedure GetTotalGroup(Cond: Integer; SellCustNo: Code[20]; DocNo: Code[20]; LineNo: Integer; GLNo: Code[20]; ItemGroupNo: Code[20]; UnitPrice: Decimal): Decimal
        var
            SIL: Record "Sales Invoice Line";
            TLineQty: Decimal;
            TLineUP: Decimal;
            TLineDisc: Decimal;
            TLineAmount: Decimal;
        begin
            SIL.Reset();
            SIL.SetFilter("Sell-to Customer No.", SellCustNo);
            SIL.SetFilter("Document No.", DocNo);
            SIL.SetFilter("No.", GLNo);
            SIL.SetFilter("Item Group No.", ItemGroupNo);
            SIL.SetFilter("Unit Price", Format(UnitPrice));
            SIL.SetRange("Line No.");
            if (SIL.FindSet()) and (Cond = 1) then begin
                repeat
                    TLineQty += SIL.Quantity;
                until (SIL.Next = 0);
                exit(TLineQty);
            end;
            if (SIL.FindSet()) and (Cond = 2) then begin
                repeat
                    //TLineUP += SIL."Unit Price";
                    TLineUP := SIL."Unit Price";
                until (SIL.Next = 0);
                exit(TLineUP);
            end;
            if (SIL.FindSet()) and (Cond = 3) then begin
                repeat
                    TLineDisc += SIL."Line Discount Amount";
                until (SIL.Next = 0);
                exit(TLineDisc);
            end;
            if (SIL.FindSet()) and (Cond = 4) then begin
                repeat
                    TLineAmount += SIL.Amount;
                until (SIL.Next = 0);
                exit(TLineAmount);
            end;
        end;

        */
    /*
        local procedure GetTotalGroup(Cond: Integer; SellCustNo: Code[20]; DocNo: Code[20]; LineNo: Integer; ItemGroupNo: Code[20]): Decimal
        var
            SIL: Record "Sales Invoice Line";
            TLineQty: Decimal;
            TLineUP: Decimal;
            TLineDisc: Decimal;
            TLineAmount: Decimal;
        begin
            SIL.Reset();
            SIL.SetFilter("Sell-to Customer No.", SellCustNo);
            SIL.SetFilter("Document No.", DocNo);
            SIL.SetFilter("Item Group No.", ItemGroupNo);
            SIL.SetRange("Line No.");
            if (SIL.FindSet()) and (Cond = 1) then begin
                repeat
                    TLineQty += SIL.Quantity;
                until (SIL.Next = 0);
                exit(TLineQty);
            end;
            if (SIL.FindSet()) and (Cond = 2) then begin
                repeat
                    //TLineUP += SIL."Unit Price";
                    TLineUP := SIL."Unit Price";
                until (SIL.Next = 0);
                exit(TLineUP);
            end;
            if (SIL.FindSet()) and (Cond = 3) then begin
                repeat
                    TLineDisc += SIL."Line Discount Amount";
                until (SIL.Next = 0);
                exit(TLineDisc);
            end;
            if (SIL.FindSet()) and (Cond = 4) then begin
                repeat
                    TLineAmount += SIL.Amount;
                until (SIL.Next = 0);
                exit(TLineAmount);
            end;
        end;
    */
    local procedure GetFixedNote(): Text
    var
        returnText: Text[500];
        text1: Text[100];
        text2: Text[100];
        CR, LF : Char;
    begin
        CR := 13;
        LF := 10;
        text1 := 'PLEASE REMIT PAYMENT TO UOB BANK,' + CR + LF;
        text2 := ' OR CROSSED CHEQUE PAYABLE TO' + CR + LF;
        returnText := text1 + 'A/C # ' + CI."Bank Account No." + text2 + '"' + CI.Name + '"';
        exit(returnText);
    end;

    trigger OnPreReport()
    begin
        CI.Reset();
        CI.Get();
        CI.CalcFields(Picture);
    end;

    var
        CI: Record "Company Information";
        Customer: Record Customer;
        RunningNo: Integer;
        CountNo: Integer;
        currentLine: record "Sales Invoice Line";
        CommentLine: Text[500];
        Curr_Code: Code[10];
        //Set whether to print line or skip (may be redudant with skip())
        PrintLine: Boolean;
        DescriptionLine, Delivery_Order_No, ContactName, PhoneNo : Text[100];

        //For comparing and filtering line
        OldGroupNo, NewGroupNo : Code[20];
        OldNo, NewNo : Code[20];
        OldUP, NewUP : Decimal;
        Order_Date: Date;


        LineNo: Code[20];
        //Total of line based of item group no.
        TLineQty, TLineUP, TLineDisc, TLineAmount : Decimal;
        //Phone No
        ShiptoPhoneNo, BilltoPhoneNo : Text[30];
        DO_NO_: Text[100];
        SCL: Record "Sales Comment Line";

}
