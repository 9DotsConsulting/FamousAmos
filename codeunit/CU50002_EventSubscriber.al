codeunit 50002 "DOT Subscribers"
{
    Permissions = tabledata "Sales Shipment Header" = rmid,
                    tabledata "Sales Shipment Line" = rmid,
                    tabledata "Sales Line" = rmid;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post (Yes/No)", OnBeforeRunSalesPost, '', false, false)]
    local procedure "Sales-Post (Yes/No)_OnBeforeRunSalesPost"(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean; var SuppressCommit: Boolean)
    var
        NoOfShip, CreateShip : Integer;
        SalesLine, SalesLine02 : record "Sales Line";
        SHAddress: text;
        DlvAddress: array[5] of Text;
        DlvAddr: text;
        DuplicatesFilter: text[100];
        Description: text[100];
    begin
        SO := SalesHeader."No.";
        SHAddress := SalesHeader."Sell-to Customer Name";
        DuplicatesFilter := '';
        Description := '';
        ok := false;
        if SalesHeader."Document Type" = "Sales Document Type"::Order then begin
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            if SalesLine.Count < 1 then begin
                exit;
            end;
            SO := SalesHeader."No.";
            ok := SO.Contains('SO-CORP');
            if ok then begin //SalesHeader."No. Series" = 'SO-CORP' then begin
                // Need to add additional handling such as posting Ship + Invoice and Invoice
                IsHandled := true; //else (CORP) use multiple posting
                                   // Loop 3 times, but you will need to find and calculate how many different Shipping Address
                SalesLine.SetRange("Document No.", SalesHeader."No.");
                // //SalesLine.SetRange("Delivery Address", SalesHeader."Ship-to Address");

                SalesLine.SetCurrentKey("Delivery Address");
                SalesLine.Ascending(true);
                if SalesLine.findset then
                    repeat
                        if Description <> SalesLine."Delivery Address" then begin
                            SalesLine.SetFilter("Delivery Address", '<>%1', SHAddress);
                            SalesLine02.reset;
                            SalesLine02.SetRange("Delivery Address", SalesLine."Delivery Address");
                            if SalesLine02.count > 1 then begin
                                Description := SalesLine."Delivery Address";
                                if DuplicatesFilter = '' then
                                    DuplicatesFilter := SalesLine."Delivery Address"
                                else
                                    DlvAddr := SalesLine."Delivery Address";
                            end;
                            NoOfShip += 1;
                        end;
                    until SalesLine.next = 0;
                //if (DuplicatesFilter <> '') AND (DlvAddr <> '') then NoOfShip := SalesLine.count;
                repeat
                    SalesPost.Run(SalesHeader);
                    NoOfShip -= 1;
                until NoOfShip = 0;
            end else
                exit;
        end else
            exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforePostLines, '', false, false)]
    local procedure "Sales-Post_OnBeforePostLines"(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var TempWhseShptHeader: Record "Warehouse Shipment Header" temporary)
    var
        TempSalesLine, NextSalesLine, lrSalesLine : Record "Sales Line";
        SalesShptLine: Record "Sales Shipment Line";
        SalesShptHeader: record "Sales Shipment Header";
        NoOfShip: Integer;
        FilterDlvAddr: Text;
        DlvAddr: text;
        DictOfGroup: Dictionary of [Integer, Text];
        SLQuery: query "DOT Sales Line";
        duplicate: Boolean;
    begin
        ok := false;
        if SalesHeader."Document Type" = "Sales Document Type"::Order then begin
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            if SalesLine.Count < 1 then begin
                exit;
            end;
            SO := SalesHeader."No.";
            ok := SO.Contains('SO-CORP');
            if ok then begin //SalesHeader."No. Series" = 'SO-CORP' then begin
                // TempSalesLine is to copy from SalesLine record
                TempSalesLine.SetRange("Document Type", SalesLine."Document Type");
                TempSalesLine.SetRange("Document No.", SalesLine."Document No.");
                // We do not want SalesLine that is without Qty. to Ship
                TempSalesLine.SetFilter("Qty. to Ship", '<>%1', 0);
                TempSalesLine.FindFirst();

                // We create NextSalesLine is to compare TempSalesLine and NextSalesline if they are the same delivery address
                TempSalesLine.Next();
                NextSalesLine := TempSalesLine;
                // Set TempSalesLine back to first record
                // TempSalesLine.FindFirst(); //this is not working correctly if 1st and 2nd line same delivery address
                // TempSalesLine.findlast(); //this is not working correctly if 1st and last line same delivery address - prev use

                // if get more than 1 delivery address then
                SLQuery.SetFilter(Document_No_, TempSalesLine."Document No.");
                //SLQuery.SetFilter(Delivery_Address, SalesLine."Delivery Address");
                SLQuery.Open();
                while SLQuery.Read() do begin
                    if (DlvAddr <> '') and (DlvAddr = SLQuery.Delivery_Address) then begin
                        duplicate := true
                    end else begin
                        NoOfShip += 1;
                        DlvAddr := SLQuery.Delivery_Address;
                    end;
                end;
                if NoOfShip > 1 then begin
                    // loop to compare
                    repeat
                        TempSalesLine.Next();
                        // If TempSalesLine and NextSalesLine has different data, then filter SalesLine
                        if TempSalesLine."Delivery Address" <> NextSalesLine."Delivery Address" then begin
                            // When you filter SalesLine, the standard Post event will post this filtered result
                            SalesLine.SetRange("Delivery Address", TempSalesLine."Delivery Address");
                            SalesLine.SetFilter("Qty. to Ship", '<>%1', 0);
                            SalesLine.FindSet();
                        end
                    until TempSalesLine.Next = 0;
                end;
            end else
                exit;
        end else if SalesHeader."Document Type" = "Sales Document Type"::Invoice then begin
            SI := SalesHeader."No.";
            ok := SI.Contains('S-INV');
            if ok then begin//SalesHeader."Posting No. Series" = 'S-INV' then begin
                exit;
            end else begin
                lrSalesLine.SetRange("Document No.", SalesLine."Document No.");
                lrSalesLine.SetRange("Shipment No.", SalesLine."Shipment No.");
                //lrSalesLine.SetFilter("Shipment No.", '<>%1', '');
                //lrSalesLine.SetFilter("Qty. to Invoice", '>%1', 0);
                if lrSalesLine.FindSet() then //begin
                    repeat
                        if lrSalesLine."Qty. to Invoice" > 0 then begin
                            SalesLine.SetRange("Document No.", lrSalesLine."Document No.");
                            SalesLine.SetFilter("Shipment No.", '<>%1', '');
                            SalesLine.SetFilter("Qty. to Invoice", '>%1', 0);
                            if SalesLine.FindSet() then begin
                                repeat
                                    SalesShptHeader.SetRange("No.", SalesLine."Shipment No.");
                                    SalesShptHeader.findset;
                                    SalesShptHeader."Ship-to Code" := '';
                                    SalesShptHeader.modify;
                                until SalesLine.next = 0;
                            end;
                        end else if (lrSalesLine."Qty. to Invoice" < 0) OR (lrSalesLine."Shipment No." = '') then exit;
                    until lrSalesLine.Next() = 0;
            end;
        end;

        //notes : // If TempSalesLine and NextSalesLine has different data, then filter SalesLine
        //if TempSalesLine."Shortcut Dimension 1 Code" <> NextSalesLine."Shortcut Dimension 1 Code" then begin
        // SalesShptLine.SetRange("Order No.", SalesLine."Document No.");
        // SalesShptLine.SetRange("No.", SalesLine."No.");
        // if SalesShptLine.FindSet() then begin
        //     SalesLine.SetRange("Delivery Address", TempSalesLine."Delivery Address");
        //     SalesLine.FindSet();
        // end;
        // if TempSalesLine."Delivery Address" <> NextSalesLine."Delivery Address" then begin
        //     //SalesShptHeader.SetRange("Ship-to Name", SalesLine."Delivery Address");
        //     // When you filter SalesLine, the standard Post event will post this filtered result
        //     //SalesLine.SetRange("Shortcut Dimension 1 Code", TempSalesLine."Shortcut Dimension 1 Code");
        //     SalesShptHeader.SetRange("Order No.", TempSalesLine."Document No.");
        //     if SalesShptHeader.findfirst then begin
        //         // SalesShptHeader."Delivery Address" := SalesLine."Delivery Address";
        //         // SalesShptHeader.modify;
        //         SalesLine.SetRange("Delivery Address", SalesShptHeader."Ship-to Name");
        //         SalesLine.FindSet();
        //     end;
        //     //end;
        //     //     if TempSalesLine."Delivery Address" = NextSalesLine."Delivery Address" then begin
        //     //         SalesLine.SetRange("Delivery Address", TempSalesLine."Delivery Address");
        //     //         SalesLine.FindSet();
        //end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterPostSalesLines, '', false, false)]
    local procedure "Sales-Post_OnAfterPostSalesLines"(var SalesHeader: Record "Sales Header"; var SalesShipmentHeader: Record "Sales Shipment Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var ReturnReceiptHeader: Record "Return Receipt Header"; WhseShip: Boolean; WhseReceive: Boolean; var SalesLinesProcessed: Boolean; CommitIsSuppressed: Boolean; EverythingInvoiced: Boolean; var TempSalesLineGlobal: Record "Sales Line" temporary)
    var
        MultiAddress: record "Multiple Delivery Address";
        SalesShptLine: record "Sales Shipment Line";
    begin
        ok := false;
        if SalesHeader."Document Type" = "Sales Document Type"::Order then begin
            SalesShptLine.SetRange("Document No.", SalesShipmentHeader."No.");
            if SalesShptLine.Count < 1 then begin
                exit;
            end;

            SO := SalesHeader."No.";
            ok := SO.Contains('SO-CORP');
            if ok then begin //SalesHeader."No. Series" = 'SO-CORP' then begin
                TempSalesLineGlobal.SetFilter("Qty. to Ship", '<>%1', 0);
                TempSalesLineGlobal.FindFirst();
                MultiAddress.SetRange(Name, TempSalesLineGlobal."Delivery Address");
                MultiAddress.FindFirst();
                SalesShipmentHeader."Ship-to Name" := TempSalesLineGlobal."Delivery address";
                SalesShipmentHeader."Ship-to Code" := MultiAddress.Code;
                SalesShipmentHeader."Ship-to Address" := MultiAddress.Address;
                SalesShipmentHeader."Ship-to City" := MultiAddress.City;
                SalesShipmentHeader."Ship-to Contact" := MultiAddress.Contact;
                SalesShipmentHeader."Ship-to Post Code" := MultiAddress."Post Code";
                SalesShipmentHeader."Ship-to Country/Region Code" := MultiAddress."Country/Region Code";
                SalesShipmentHeader."Ship-to Address 2" := '';
                SalesShipmentHeader.Modify();

                SalesShptLine.SetRange("Document No.", SalesShipmentHeader."No.");
                SalesShptLine.SetFilter(Quantity, '=%1', 0);
                if SalesShptLine.findset then
                    repeat
                        SalesShptLine.Delete(true);
                    until SalesShptLine.next = 0;
            end else
                exit;
            // end else if SalesHeader."Document Type" = "Sales Document Type"::Invoice then begin
            //     TempSalesLineGlobal.SetFilter("Qty. to Invoice", '<>1', 0);
            //     TempSalesLineGlobal.FindFirst();
            //     MultiAddress.SetRange(Name, TempSalesLineGlobal."Delivery Address");
            //     MultiAddress.FindFirst();
            //     //SalesShipmentHeader."Ship-to Name" := TempSalesLineGlobal."Delivery address";
            //     SalesShipmentHeader."Ship-to Code" := MultiAddress.Code;
            //     //SalesShipmentHeader."Ship-to Address" := MultiAddress.Address;
            //     SalesShipmentHeader.Modify();

            //     SalesShptLine.SetRange("Document No.", SalesShipmentHeader."No.");
            //     SalesShptLine.SetFilter(Quantity, '=%1', 0);
            //     if SalesShptLine.findset then
            //         repeat
            //             SalesShptLine.Delete(true);
            //         until SalesShptLine.next = 0;
        end else
            exit;
    end;

    [EventSubscriber(ObjectType::CodeUnit, Codeunit::"Sales-Get Shipment", OnAfterInsertLine, '', false, false)]
    local procedure GetShipment_OnAfterInsertLine(var SalesShptLine: Record "Sales Shipment Line"; var SalesLine: Record "Sales Line"; SalesShptLine2: Record "Sales Shipment Line"; TransferLine: Boolean; var SalesHeader: Record "Sales Header")
    var
        Commentline, CommentLine2 : record "Sales Comment Line";
        SalesLine2: Record "Sales Line";
    begin
        SalesShipmentHeader.SetRange("No.", SalesShptLine2."Document No.");
        if SalesShipmentHeader.findfirst then begin
            //repeat
            SalesLine."Shipment-Order No." := SalesShipmentHeader."Order No.";
            SalesLine.Modify();
        end;
        CommentLine.reset;
        SalesLine2.reset;
        //sales order get sales invoice
        SalesLine2.SetRange("Document No.", SalesLine."Shipment-Order No.");
        SalesLine2.SetRange("Item Group No.", SalesLine."Item Group No.");
        SalesLine2.SetFilter("Document Type", 'Order');
        if salesline2.findset then begin
            CommentLine.SetRange("No.", SalesLine2."Document No.");
            Commentline.SetRange("Document Type", SalesLine2."Document Type");
            Commentline.SetRange("Document Line No.", SalesLine2."Line No.");
            if CommentLine.findfirst then
                //CommentLine.CopyLineCommentsFromSalesLines(SalesLine2."Document Type", SalesLine."Document Type", SalesLine2."Shipment-Order No.", SalesLine."Document No.", SalesLine2);
                CommentLine2.CopyLineComments(Commentline."Document Type", SalesLine."Document Type", Commentline."No.", SalesLine."Document No.", Commentline."Document Line No.", SalesLine."Line No.");
        end;
    end;

    var
        SalesPost: Codeunit "Sales-Post";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SO, SI : text;
        ok: Boolean;
}