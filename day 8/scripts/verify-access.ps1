param(
    [Parameter(Mandatory=$true)][string]$BucketName,
    [string]$Profile = "s3-readonly-test"
)
$ErrorActionPreference = "Stop"
Write-Host "Checking identity..."
aws sts get-caller-identity --profile $Profile
if ($LASTEXITCODE -ne 0) { throw "Identity check failed. Check the profile configuration." }

Write-Host "`nListing objects in s3://$BucketName/ ..."
aws s3 ls "s3://$BucketName/" --profile $Profile
if ($LASTEXITCODE -ne 0) { throw "S3 list failed. Check group membership, bucket name, and policy propagation." }

Write-Host "`nRead access check complete. To verify object read access, download a known test object:"
Write-Host "aws s3 cp s3://$BucketName/your-test-file.txt . --profile $Profile"
Write-Host "Replace your-test-file.txt with an existing object key. Do not test against confidential data."
