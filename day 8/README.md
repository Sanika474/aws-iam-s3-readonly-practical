# AWS IAM Custom S3 Read-Only Practical

## Aim
Create an IAM group, apply a custom least-privilege S3 read-only policy, add an IAM user to the group, and verify read access with AWS CLI.

## Repository contents
- `policy.json` — custom policy that permits listing bucket names, listing one configured bucket, and reading objects in that bucket.
- `scripts/setup-iam.ps1` — PowerShell script to substitute the bucket name, create the IAM group and policy, and attach the policy.
- `scripts/verify-access.ps1` — AWS CLI checks for identity and S3 read access.
- `screenshots/` — place only redacted practical screenshots here.

## Prerequisites
1. AWS CLI v2 installed and available in PowerShell.
2. An AWS account and permission to create IAM policies/groups and attach policies.
3. An existing S3 bucket with at least one test object.
4. Configure an administrator/operator profile securely with `aws configure` or an AWS IAM Identity Center profile. Do not put credentials in this repository.

## 1. Configure the bucket name
Open `policy.json` and replace both occurrences of `YOUR_BUCKET_NAME` with the exact bucket name, without `s3://`.

## 2. Create the group and policy
Run PowerShell from the repository directory:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\setup-iam.ps1 -BucketName "your-real-bucket-name" -GroupName "S3-ReadOnly-Group" -PolicyName "CustomS3ReadOnlyPolicy"
```

The setup script uses the currently configured AWS CLI identity. Review the account shown by `aws sts get-caller-identity` before running it. It creates the group if needed, creates the customer-managed policy if needed, and attaches it to the group.

## 3. Create the IAM user
In AWS Console, open **IAM → Users → Create user**. Choose a username, then add the user to `S3-ReadOnly-Group`. For CLI testing, create an access key for the test user only if your course requires IAM user keys. Store it securely and never commit it.

## 4. Verify with the test user's CLI profile
Configure a separate local profile for the test user (do not paste keys into commands or files):

```powershell
aws configure --profile s3-readonly-test
```

Then run:

```powershell
.\scripts\verify-access.ps1 -BucketName "your-real-bucket-name" -Profile "s3-readonly-test"
```

Expected: identity check succeeds, `aws s3 ls` for the selected bucket succeeds, and downloading an existing object succeeds. Upload/delete operations should not be permitted by this policy. IAM policies can take a short time to propagate.

## Permissions included
- `s3:ListAllMyBuckets` on `*` because this action does not support bucket-level resource scoping.
- `s3:ListBucket` on only the chosen bucket.
- `s3:GetObject` on objects inside only the chosen bucket.

No S3 write or delete actions are granted. The policy does not grant access to other buckets' objects.

## Security
- Never commit access keys, secret keys, passwords, session tokens, `.aws/credentials`, or unredacted screenshots.
- If a real key was exposed, deactivate/delete it in IAM and replace it.
- Use a separate test-user profile for verification.
- The policy file is a template until `YOUR_BUCKET_NAME` is replaced with your actual bucket name.
