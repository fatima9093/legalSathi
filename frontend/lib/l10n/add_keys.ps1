# Add missing keys to Roman Urdu ARB file
$filePath = "c:\flutter projects\fyp_legal_sathi\legalSathi\frontend\lib\l10n\app_ro.arb"
$content = Get-Content $filePath -Raw

$newKeys = @"
,"calculateOvertimePayTitle": "Overtime Pay Calculator","checkIfYouArePaidCorrectlyForOvertime": "Check if you are being paid correctly for overtime","weeklyWorkingHoursLabel": "Weekly Working Hours *","weeklyWorkingHoursHint": "e.g., 48 hours","overtimeHoursPerMonthLabel": "Overtime Hours (per month) *","overtimeHoursPerMonthHint": "Total overtime hours worked","legalOvertimeRateTitle": "Legal Overtime Rate","legalOvertimeRateDescription": "Under Pakistani labour law, overtime must be paid at 2x your regular hourly rate. Standard work week is 48 hours.","calculateOvertimePayButton": "Calculate Overtime Pay","keepRecordsWarningText": "Keep records of all overtime hours worked for accurate claims","overtimeCalculationTitle": "Overtime Calculation","checkLeaveEligibilityTitle": "Check Leave Eligibility","findOutIfYouAreEntitledToPaidLeave": "Find out if you are entitled to paid leave","employmentTypeLabel": "Employment Type *","selectEmploymentTypeHint": "Select employment type","durationOfEmploymentMonthsLabel": "Duration of Employment (months) *","howLongHaveYouWorkedHint": "How long have you worked here?","leaveTypeLabel": "Leave Type *","selectLeaveTypeHint": "Select leave type","checkEligibilityButton": "Check Eligibility","paidLeaveIsALegalRightNote": "Paid leave is a legal right under the Factories Act and Shops & Establishments Act"
"@

$content = $content -replace '"\s*}$', $newKeys + '}' 
$content | Set-Content $filePath
Write-Host "Updated app_ro.arb successfully"
