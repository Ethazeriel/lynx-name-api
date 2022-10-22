    $lynxInfo = Get-ComputerInfo | ConvertTo-Json -Depth 5;
    $lynxURI = "http://172.16.12.103:17346/name"
    $prefix = "TEST-PC"
    $lynxNum = Invoke-RestMethod -Method Post -Uri $lynxURI -Body $lynxInfo -Headers @{'content-type' = 'application/json'};
    $newName = "$prefix$lynxNum"
Write-Output $newName;