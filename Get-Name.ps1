$info = Get-ComputerInfo | ConvertTo-Json -Depth 5;
$uri = "http://172.16.12.103:17346/name"
$name = Invoke-RestMethod -Method Post -Uri $uri -Body $info -Headers @{'content-type' = 'application/json'};
Write-Output $name;