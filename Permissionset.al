permissionset 50001 GeneratedPermission
{
    Assignable = true;
    Permissions = tabledata "Multiple Delivery Address" = RIMD,
        tabledata "Posting Indicator" = RIMD,
        tabledata "Proxy Type" = RIMD,
        tabledata "Purpose Code" = RIMD,
        tabledata "Service Code" = RIMD,
        tabledata "Settlement Mode" = RIMD,
        table "Multiple Delivery Address" = X,
        table "Posting Indicator" = X,
        table "Proxy Type" = X,
        table "Purpose Code" = X,
        table "Service Code" = X,
        table "Settlement Mode" = X,
        report "DOT AmountToWords" = X,
        codeunit BankExportGIROFAST = X,
        codeunit "DOT Subscribers" = X,
        page "Multiple Delivery Address" = X,
        page "Multiple Delivery Address List" = X,
        page "Posting Indicator" = X,
        page "Proxy Type" = X,
        page "Purpose Code" = X,
        page "Service Code" = X,
        page "Settlement Mode" = X;
}