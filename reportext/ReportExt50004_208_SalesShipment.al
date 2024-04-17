reportextension 50004 "DOT Sales Shipment" extends "Sales - Shipment"
{
    dataset
    {
        add("Sales Shipment Header")
        {
            column(CompanyLogo; CI.Picture) { }
            column(City; CI.City) { }
            column(PostCode; CI."Post Code") { }
            column(Phone_No; CI."Phone No.") { }
            column(CoRegNo; CI."Registration No.") { }
            column(VAT_Registration_No_; CI."VAT Registration No.") { }
            column(Deliver_On; "Deliver On") { }
            column(Salesperson_Code; "Salesperson Code") { }
        }
        add(CopyLoop)
        {
            column(Shipto1; CustAddrShipTo[1]) { }
            column(Shipto2; CustAddrShipTo[2]) { }
            column(Shipto3; CustAddrShipTo[3]) { }
            column(Shipto4; CustAddrShipTo[4]) { }
            column(Shipto5; CustAddrShipTo[5]) { }
            column(Shipto6; CustAddrShipTo[6]) { }
        }
        modify(CopyLoop)
        {
            trigger OnAfterAfterGetRecord()
            begin
                FormatAddrFields("Sales Shipment Header");
            end;
        }
        add("Sales Shipment Line")
        {
            column(RunningNo; RunningNo) { }
            column(Comments; Comments) { }
        }
        modify("Sales Shipment Line")
        {
            trigger OnAfterAfterGetRecord()
            begin
                CrLf[1] := 13;
                CrLf[2] := 10;
                Line := "Sales Shipment Line";
                if "Line No." < CountNo then
                    RunningNo := 0;
                if (Type.AsInteger() <> 0) and (Line."Line No." > 0) then begin
                    RunningNo += 1;
                    //CountNo := "Line No." + RunningNo;
                end;
                CommentLine.reset;
                CommentLine.SetRange("No.", "Sales Shipment Line"."Document No.");
                CommentLine.SetRange("Document Line No.", "Sales Shipment Line"."Line No.");
                CommentLine.SetFilter("Document Type", 'Shipment');
                if CommentLine.findlast then
                    repeat
                        Comments := CommentLine.Comment + CrLf + Comments;
                    until CommentLine.next = 0;

            end;
        }
    }

    requestpage
    {
        // Add changes to the requestpage here
    }

    rendering
    {
        layout("Famous Amos - Sales Shipment")
        {
            Type = RDLC;
            LayoutFile = './reportextlayout/ReportExt50004_208_SalesShipment.rdlc';
        }
    }

    trigger OnPreReport()
    begin
        CI.Get;
        CI.CalcFields(Picture);
    end;

    local procedure FormatAddrFields(SalesShipmentHeader: Record "Sales Shipment Header")
    begin
        // FormatAddress.GetCompanyAddr(SalesShipmentHeader."Responsibility Center", RespCenter, CompanyInfo, CompanyAddr);
        // FormatAddress.SalesShptShipTo(ShipToAddr, SalesShipmentHeader);
        FormatAddress.SalesShptBillTo(CustAddrShipTo, ShipToAddrTest, SalesShipmentHeader);
    end;

    var
        CI: Record "Company Information";
        FormatAddress: Codeunit "Format Address";
        CustAddrShipTo, ShipToAddrTest : array[8] of text[100];
        RunningNo, CountNo : Integer;
        Line: record "Sales Shipment Line";
        Comments: text;
        CommentLine: record "Sales Comment Line";
        CrLf: text[2];
}