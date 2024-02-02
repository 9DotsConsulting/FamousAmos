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

            //Field 11: Date (Document Date)
            column(Date; "Document Date") { }

            //Field 12: Delivery Order No (Your Reference) - Temporary link for Phase 1
            column(Delivery_Order_No; "Your Reference") { }

            //Field 13: Terms (Payment Terms code)
            column(Payment_Terms_Code; "Payment Terms Code") { }

            //Field 14: Purchase Order No (External Document No)
            column(Purchase_Order_No_; "External Document No.") { }

            //Field 15: Doesn't exist in FDD


            //Field 16: Order Date (Document Date)
            column(Order_Date; "Document Date") { }

            //Field 17: Sales Person Code: (Salesperson Code)
            column(Salesperson_Code; "Salesperson Code") { }

            //Field 18: Sales Order No (Leave blank for phase 1)


            //Field 26: Custom field
            column(Deliver_On; "Deliver On") { }
            column(Remarks_Info; Remarks) { }

        }
        add(Line)
        {

            //--------------------Invoice Item part-------------------------//

            //Field 19: S/N (sequence number)
            column(RunningNo; RunningNo) { }
            //Field 20: Product Code (No) - Phase 1 uses No based on G/L acc no
            column(Line_No_; "No.") { }

            //Field 21: Description (comment) - Refer to appendix section


            //Field 22: Quantity - Renamed as 'Qty' (Need to sum up - refer to appendix)
            column(Quantity; Quantity) { }

            //Field 23: Unit Price - Renamed as 'U/P'
            column(Unit_Price_Excl_GST; "Unit Price") { }

            //Field 24: DISC. (Discount Amount)
            column(Line_Discount_Amount; "Line Discount Amount") { }

            //Field 25: Amount 
            column(Line_Amount_Excl_GST; Amount) { }

            //Field 26: Custom field

            //--------------------Total up section part-------------------------//

            //Field 27: 

            //Field 27.1:  Amt Excl. GST

            //Field 27.2: Inv. Discount

            //Field 27.3: Total Excl. GST

            //Field 27.4: GST

            //Field 27.5: Total Incl. GST

        }
        modify(Line)
        {
            trigger OnAfterAfterGetRecord()
            begin
                currentLine := Line;
                if "Line No." < CountNo then
                    RunningNo := 0;
                if (Type.AsInteger() <> 0) and (currentLine.Quantity > 0) then begin
                    RunningNo += 1;
                    CountNo := "Line No." + RunningNo;
                end;
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

    trigger OnPreReport()
    begin
        CI.Reset();
        CI.Get();
        CI.CalcFields(Picture);
    end;

    var
        CI: Record "Company Information";
        RunningNo: Integer;
        CountNo: Integer;
        currentLine: record "Sales Invoice Line";
}
