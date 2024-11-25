reportextension 50006 PrintedPickList_TO extends "Transfer Order"
{
    //Printed Pick List
    dataset
    {
        add("Transfer Header")
        {
            column(CompanyInfoLogo; CI.Picture) { }
            column(CompanyInfoName; CI.Name) { }

            //Footer
            column(Transfer_from_Code; "Transfer-from Code") { }
            column(Transfer_to_Code; "Transfer-to Code") { }
        }
        add("Transfer Line")
        {
            column(Total_Qty; Total_Qty) { }
        }

        modify("Transfer Header")
        {
            trigger OnAfterAfterGetRecord()
            begin
                Total_Qty := 0;
            end;
        }

        modify("Transfer Line")
        {
            trigger OnAfterAfterGetRecord()
            begin
                Total_Qty += Quantity;
            end;

        }
    }

    rendering
    {
        layout("Famous Amos - Pick List")
        {
            Type = RDLC;
            //Type = Word;
            LayoutFile = './reportextlayout/ReportExt50006_5703_PrintedPickList.rdlc';
            //LayoutFile = './reportextlayout/ReportExt50004_5703_PrintedPickList.rdlc';
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
        Total_Qty: Decimal;
}
