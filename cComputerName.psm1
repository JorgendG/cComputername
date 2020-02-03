enum Ensure
{
  Present
  Absent
}

[DscResource()]  class cComputerName ##  MyFolder is the name of the resource
{
    [DscProperty(Mandatory,Key)]
    [Ensure]$Ensure

    ## What to do if it's  not in the right state. This returns nothing, indicated by [void].

    [void] Set() 
    {
        if ($this.Ensure -eq  [Ensure]::Present)
        {
            $regvalue = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters" -Name "VirtualMachineName" -ErrorAction SilentlyContinue
            $newname = ($regvalue.VirtualMachineName -split ':')[0]

            Rename-Computer -NewName $newname -Restart
        }
        elseif ($this.Ensure  -eq [Ensure]::Absent)
        {
            # eh, doe iets
        }
    }

  ## Test to ensure  it's in the right state. This returns a Boolean value, indicated by [bool].

  [bool] Test() 
    {
        #HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters
        $regvalue = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters" -Name "VirtualMachineName" -ErrorAction SilentlyContinue
        $newname = ($regvalue.VirtualMachineName -split ':')[0]
        $rootfolderset = $newname -eq $env:COMPUTERNAME
        if ($this.Ensure -eq  [Ensure]::Present)
        {
            return $rootfolderset
        }
        else
        {
            return -not  $rootfolderset
        }
    }

  ## Get the state.  This returns an instance of the class itself, indicated by [MyFolder]

    [cComputerName] Get() 
    {
        #
        $regvalue = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters" -Name "VirtualMachineName" -ErrorAction SilentlyContinue
        $newname = ($regvalue.VirtualMachineName -split ':')[0]
        if( $newname -eq $env:COMPUTERNAME )
        {
            $this.Ensure = [Ensure]::Present
        }
        else 
        {
            $this.Ensure = [Ensure]::Absent
        }
        return $this
    }
}

