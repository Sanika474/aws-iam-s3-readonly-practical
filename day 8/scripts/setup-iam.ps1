param(
    [Parameter(Mandatory=$true)][string]$BucketName,
    [string]$GroupName = "S3-ReadOnly-Group",
    [string]$PolicyName = "CustomS3ReadOnlyPolicy"
)

$ErrorActionPreference = "Stop"
$identity = aws sts get-caller-identity | ConvertFrom-Json
Write-Host "Using AWS account: $($identity.Account)"
Write-Host "Using caller: $($identity.Arn)"
$confirm = Read-Host "Continue with this AWS account? Type YES"
if ($confirm -ne "YES") { throw "Cancelled by user." }

$policyPath = Join-Path (Get-Location) "policy.json"
if (-not (Test-Path $policyPath)) { throw "Run this script from the repository root, where policy.json exists." }

$policy = Get-Content $policyPath -Raw
$policy = $policy.Replace("YOUR_BUCKET_NAME", $BucketName)
$tempPolicyPath = Join-Path $env:TEMP "CustomS3ReadOnlyPolicy.json"
Set-Content -Path $tempPolicyPath -Value $policy -Encoding utf8

$groupList = aws iam list-groups --query "Groups[?GroupName=='$GroupName'].GroupName" --output text
if (-not $groupList -or $groupList -eq "None") {
    aws iam create-group --group-name $GroupName | Out-Null
    Write-Host "Created group: $GroupName"
} else {
    Write-Host "Group already exists: $GroupName"
}

$existingPolicyArn = aws iam list-policies --scope Local --query "Policies[?PolicyName=='$PolicyName'].Arn | [0]" --output text
if (-not $existingPolicyArn -or $existingPolicyArn -eq "None") {
    $existingPolicyArn = aws iam create-policy --policy-name $PolicyName --policy-document "file://$tempPolicyPath" --query "Policy.Arn" --output text
    Write-Host "Created policy: $existingPolicyArn"
} else {
    Write-Host "Policy already exists: $existingPolicyArn"
    Write-Warning "If the existing policy has old content, update its default version manually before testing."
}

aws iam attach-group-policy --group-name $GroupName --policy-arn $existingPolicyArn
Write-Host "Attached policy to group: $GroupName"
Write-Host "Next: add the test IAM user to this group in the AWS Console."
