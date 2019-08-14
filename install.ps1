<# LICENSE 
MIT License

Copyright (c) 2019 Hilmar Gústafsson

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>

<#  Registers a task in Task Scheduler which runs autoDetectGraphicsCard.ps1 on startup.
    Automatically detects the graphics cards and lets the user select them interactively.
#>

function SelectDeviceId ([Object[]] $devices) {
    if ($devices.Count -eq 1) {
        Write-Output $devices[0]
    }
    else {
        for ($i = 0; $i -lt $devices.Count; $i++) {
            $device = $devices[$i]
            Write-Host "Option ${i}:"
            Write-Host "    Name: $($device.Name)"
            Write-Host "  Status: $($device.Status)"
            Write-Host ""
        }
        $option = Read-Host "Please select option (number)"

        # Here we assume that the output is a number within the bounds, this is easy to check. TODO
        Write-Output $devices[$option]
    }
}

$options = Get-PnpDevice -Class Display

Clear-Host
Write-Host "Choose external graphics card"
$external = SelectDeviceId($options)

Clear-Host
Write-Host "Choose external graphics card"
$internal = SelectDeviceId($options | Where-Object -FilterScript { $_.InstanceId -ne $external.InstanceId })

Clear-Host
Write-Host "Setting up task..."

<#  Triggers
    The event handler only needs to be run once, i.e. at startup.
#>
$T = New-ScheduledTaskTrigger -AtStartup

<#  Action
    Run the script which registers an event and an action, given two ids.
    The first one is the external (preferred) GPU, and the second is the internal one.
#>
$A = New-ScheduledTaskAction  -Id "Register eGpuEventListener" -Execute "PowerShell.exe" -Argument "-File $(Get-Location)/registerEventListener.ps1 $($internal.InstanceId) $($external.InstanceId)"

<#  Principal
    LogonType S4U specifies that we do this whether the user is logged in or not, and we do not use a password.
#>

$P = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType S4U -RunLevel Highest

<#  Check for pre-existing task
    We will error if the task already exists, and therefore remove any previous task instances with the same name.
#>
$existingTask = Get-ScheduledTask | Where-Object -FilterScript { $_.TaskName -like "eGpuEventListener" }
if ($existingTask) {
    $existingTask | Unregister-ScheduledTask -Confirm:$false
}
Register-ScheduledTask "eGpuEventListener" -Trigger $T -Action $A -Principal $P