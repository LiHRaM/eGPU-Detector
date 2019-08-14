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

<# Subscribe to the 'graphicsCardChanged' event and attach an action.
   The action checks the status of your internal and external cards, 
   disabling and enabling the internal one as appropriate.
#>
$action = {
    $extern = Get-PnpDevice -InstanceId $args[0]
    $intern = Get-PnpDevice -InstanceId $args[1]

    # if the eGPU is present, we disable the internal one.
    if ($extern.Present) {
        if ($intern.Status -like "OK") {
            $intern | Disable-PnpDevice -Confirm:$false
        }
        if ($extern.Status -notlike "OK") {
            $extern | Disable-PnpDevice -Confirm:$false
            $extern | Enable-PnpDevice -Confirm:$false
        }
    }
    else {
        if ($intern.Status -notlike "OK" -and $intern.Problem -like "CM_PROB_DISABLED") {
            $intern | Enable-PnpDevice -Confirm:$false
        }
    }
}

Register-CimIndicationEvent -Action $action -ClassName Win32_DeviceChangeEvent -SourceIdentifier graphicsCardChanged