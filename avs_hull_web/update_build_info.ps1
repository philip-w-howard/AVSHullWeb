# update_build_info.ps1
# Auto-generates lib/settings/build_info.dart with version and UTC build timestamp

$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$dartFile = "./lib/settings/build_info.dart"
@"
// This file is auto-generated. Do not edit manually.
const String kBuildTimestamp = '$timestamp';
"@ | Set-Content $dartFile -Encoding UTF8
Write-Host "Updated build_info.dart: version $version, timestamp $timestamp"
