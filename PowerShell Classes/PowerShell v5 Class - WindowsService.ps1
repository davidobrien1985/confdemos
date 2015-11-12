class WindowsService {
  [ValidatePattern('[0-9a-zA-Z]{1,30}')]
  [string] $Name

  [ValidateSet('Auto', 'Manual')]
  [string] $StartupType

  ### Object constructor
  WindowsService([string] $Name) {
    ### Validate Windows Service name, else throw exception
    if ($Name -notmatch '[0-9a-zA-Z]{1,30}') {
      throw 'Invalid Service Name';
    }
    ### Obtain the CIM / WMI version of the Windows Service
    $Service = Get-CimInstance -ClassName Win32_Service -Filter "Name = '$Name'";

    $this.StartupType = $Service.StartType;
  }
}

### Instantiate the class
[WindowsService]::new('winmgmt');
