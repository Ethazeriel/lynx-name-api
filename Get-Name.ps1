    $lynxInfo = Get-ComputerInfo | ConvertTo-Json -Depth 5;
    $lynxURI = "http://TEST-ADMIN01.corp.test.com:17346/name"
    $newName = Invoke-RestMethod -Method Post -Uri $lynxURI -Body $lynxInfo -Headers @{'content-type' = 'application/json'};
Write-Output $newName;