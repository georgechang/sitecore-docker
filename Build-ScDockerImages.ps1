# build base images
Get-ChildItem .\base\ -Directory | Where-Object { Test-Path "$($_.FullName)\Dockerfile" } | ForEach-Object { Start-Process docker -ArgumentList "build", "--rm", "-t", "scbase:$($_.Name)", "-f", ".\base\$($_.Name)\Dockerfile", "." -NoNewWindow -Wait }

# build application images
Get-ChildItem .\application\ -Directory | Where-Object { Test-Path "$($_.FullName)\Dockerfile" } | ForEach-Object { Start-Process docker -ArgumentList "build", "--rm", "-t", "$($_.Name):latest", "-f", ".\application\$($_.Name)\Dockerfile", "."  -NoNewWindow -Wait }