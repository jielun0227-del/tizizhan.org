# IndexNow URL Submission Script
$hostName = "tizizhan.org"
$key = "2e1c04c14cf74e3a9bccebb2d22326fd"
$keyLocation = "https://$hostName/$key.txt"
$sitemapPath = Join-Path $PSScriptRoot "sitemap.xml"

if (-not (Test-Path $sitemapPath)) {
    Write-Error "sitemap.xml not found at $sitemapPath"
    exit 1
}

# Read URLs from sitemap.xml
[xml]$sitemapXml = Get-Content -Path $sitemapPath -Encoding UTF8
$urls = @($sitemapXml.urlset.url.loc)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  IndexNow Submitter - tizizhan.org" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Host:           $hostName"
Write-Host "Key:            $key"
Write-Host "KeyLocation:    $keyLocation"
Write-Host "Total URLs:     $($urls.Count)"
Write-Host ""

$payload = @{
    host        = $hostName
    key         = $key
    keyLocation = $keyLocation
    urlList     = $urls
}

$jsonBody = $payload | ConvertTo-Json -Depth 5 -Compress
$utf8Bytes = [System.Text.Encoding]::UTF8.GetBytes($jsonBody)

$endpoints = @(
    "https://api.indexnow.org/indexnow",
    "https://www.bing.com/indexnow"
)

foreach ($endpoint in $endpoints) {
    Write-Host "Submitting to $endpoint ..." -ForegroundColor Yellow
    try {
        $req = [System.Net.HttpWebRequest]::Create($endpoint)
        $req.Method = "POST"
        $req.ContentType = "application/json; charset=utf-8"
        $req.ContentLength = $utf8Bytes.Length
        $req.Timeout = 15000

        $stream = $req.GetRequestStream()
        $stream.Write($utf8Bytes, 0, $utf8Bytes.Length)
        $stream.Close()

        $resp = [System.Net.HttpWebResponse]$req.GetResponse()
        $code = [int]$resp.StatusCode
        $desc = $resp.StatusDescription
        $resp.Close()

        Write-Host "  [SUCCESS] HTTP Status: $code ($desc)" -ForegroundColor Green
    } catch [System.Net.WebException] {
        $webEx = $_.Exception
        if ($webEx.Response) {
            $resp = [System.Net.HttpWebResponse]$webEx.Response
            $code = [int]$resp.StatusCode
            $desc = $resp.StatusDescription
            $respStream = $resp.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($respStream)
            $body = $reader.ReadToEnd()
            $reader.Close()
            $resp.Close()

            if ($code -eq 200 -or $code -eq 202) {
                Write-Host "  [SUCCESS] HTTP Status: $code ($desc)" -ForegroundColor Green
            } else {
                Write-Host "  [RESPONSE] HTTP Status: $code ($desc) - $body" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  [ERROR] $($webEx.Message)" -ForegroundColor Red
        }
    } catch {
        Write-Host "  [ERROR] $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`nSubmission completed." -ForegroundColor Cyan
