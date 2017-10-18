$VerbosePreference = 'Continue'

workflow Stop-VagrantBoxes
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [array]
        $boxes
    )

    foreach -parallel ($item in $boxes)
    {
        CMD /C "vagrant halt -f $item"
        Write-Verbose "Box $item stopped"
    }
}


workflow Destroy-VagrantBoxes
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [array]
        $boxes
    )

    foreach -parallel ($item in $boxes)
    {
        CMD /C "vagrant destroy -f $item"
        Write-Verbose "Box $item destroyed"
    }
}




$vagrant_state = $(vagrant global-status)
$vagrant_state_arr = $vagrant_state -split "`n"

[array]$running_boxes = @()
[array]$stopped_boxes = @()
[array]$all_boxes = @()
foreach ($item in $vagrant_state_arr)
{
    if ( ($item -match 'kitchen-vagrant') -and ($item -match 'running') )
    {
        $running_boxes += $item.substring(0,8)
    }

    if ( ($item -match 'kitchen-vagrant') -and ($item -match 'poweroff') )
    {
        $stopped_boxes += $item.substring(0,8)
    }

    if ( $item -match 'virtualbox' )
    {
            $all_boxes += $item.substring(0,8)
    }
}


if ($running_boxes.count -gt 0)
{
    Stop-VagrantBoxes -boxes $running_boxes
}
else
{
    Write-Verbose 'No kitchen boxes running'
}

Destroy-VagrantBoxes -boxes $all_boxes

pause
