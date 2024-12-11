query 50001 "DOT Sales Line"
{
    Caption = 'DOT Sales Line';
    QueryType = Normal;
    OrderBy = ascending(Delivery_Address);

    elements
    {
        dataitem(Sales_Line; "Sales Line")
        {
            column(Document_No_; "Document No.")
            {

            }
            column(Delivery_Address; "Delivery Address") { }
            column(Quantity; Quantity) { }
            column(Qty__to_Ship; "Qty. to Ship") { }
        }
    }

    var
        myInt: Integer;

    trigger OnBeforeOpen()
    begin

    end;
}