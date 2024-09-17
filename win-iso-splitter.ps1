# Start logging the session to a file
$logFile = "$env:UserProfile\Desktop\winutil_log.txt"
Start-Transcript -Path $logFile -Append -Force

# Load WPF and Windows Forms assemblies
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# Nord Dark Mode Polar Night Colors
$backgroundColor = "#2E3440"  # Polar Night
$textColor = "#D8DEE9"        # Snow Storm
$buttonColor = "#4C566A"      # Polar Night Lighter
$textBoxBackgroundColor = "#4C566A"  # Darker background for text box
$textBoxTextColor = "#ECEFF4"  # Lighter text color inside the textbox
$completedColor = "#A3BE8C"   # Frost Green (completed step color)

# Function to create the GUI with the Nord theme
function Show-GUI {
    [void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')

    # Create Window
    $window = New-Object System.Windows.Window
    $window.Title = "Windows Image Splitter"
    $window.Width = 400
    $window.Height = 450
    $window.Background = (New-Object Windows.Media.SolidColorBrush ([System.Windows.Media.ColorConverter]::ConvertFromString($backgroundColor)))
    $window.Foreground = (New-Object Windows.Media.SolidColorBrush ([System.Windows.Media.ColorConverter]::ConvertFromString($textColor)))
    $window.WindowStartupLocation = "CenterScreen"

    # Create StackPanel for layout
    $panel = New-Object System.Windows.Controls.StackPanel
    $panel.Margin = "10"
    $window.Content = $panel

    # Label for the image file path
    $label = New-Object System.Windows.Controls.Label
    $label.Content = "Select Windows ISO or install.wim:"
    $label.FontSize = 14
    $label.Margin = "0,0,0,10"
    $label.Foreground = (New-Object Windows.Media.SolidColorBrush ([System.Windows.Media.ColorConverter]::ConvertFromString($textColor)))
    $panel.Children.Add($label)

    # Textbox to show selected file
    $textbox = New-Object System.Windows.Controls.TextBox
    $textbox.Width = 350
    $textbox.Height = 25
    $textbox.Background = (New-Object Windows.Media.SolidColorBrush ([System.Windows.Media.ColorConverter]::ConvertFromString($textBoxBackgroundColor)))  # Dark background
    $textbox.Foreground = (New-Object Windows.Media.SolidColorBrush ([System.Windows.Media.ColorConverter]::ConvertFromString($textBoxTextColor)))  # Light text
    $panel.Children.Add($textbox)

    # Button to browse file
    $buttonBrowse = New-Object System.Windows.Controls.Button
    $buttonBrowse.Content = "Browse"
    $buttonBrowse.Width = 100
    $buttonBrowse.Background = (New-Object Windows.Media.SolidColorBrush ([System.Windows.Media.ColorConverter]::ConvertFromString($buttonColor)))
    $buttonBrowse.Foreground = (New-Object Windows.Media.SolidColorBrush ([System.Windows.Media.ColorConverter]::ConvertFromString($textColor)))
    $buttonBrowse.Margin = "0,10,0,10"
    $panel.Children.Add($buttonBrowse)

    # To-do list for tasks
    $toDoList = New-Object System.Windows.Controls.ListBox
    $toDoList.Width = 350
    $toDoList.Height = 150
    $toDoList.Background = (New-Object Windows.Media.SolidColorBrush ([System.Windows.Media.ColorConverter]::ConvertFromString($backgroundColor)))
    $toDoList.Foreground = (New-Object Windows.Media.SolidColorBrush ([System.Windows.Media.ColorConverter]::ConvertFromString($textColor)))
    $panel.Children.Add($toDoList)

    # Add tasks to the to-do list
    $tasks = @("Extract ISO", "Find install.wim", "Split install.wim", "Recreate ISO with install.swm", "Clean up unnecessary files")
    foreach ($task in $tasks) {
        $listItem = New-Object System.Windows.Controls.ListBoxItem
        $listItem.Content = $task
        $listItem.Foreground = (New-Object Windows.Media.SolidColorBrush ([System.Windows.Media.ColorConverter]::ConvertFromString($textColor)))
        $toDoList.Items.Add($listItem)
    }

    # Button to start the process
    $buttonStart = New-Object System.Windows.Controls.Button
    $buttonStart.Content = "Start"
    $buttonStart.Width = 100
    $buttonStart.Background = (New-Object Windows.Media.SolidColorBrush ([System.Windows.Media.ColorConverter]::ConvertFromString($buttonColor)))
    $buttonStart.Foreground = (New-Object Windows.Media.SolidColorBrush ([System.Windows.Media.ColorConverter]::ConvertFromString($textColor)))
    $panel.Children.Add($buttonStart)

    # Button to auto-install the latest ADK
    $buttonInstallADK = New-Object System.Windows.Controls.Button
    $buttonInstallADK.Content = "Auto-Install the latest ADK"
    $buttonInstallADK.Width = 200
    $buttonInstallADK.Background = (New-Object Windows.Media.SolidColorBrush ([System.Windows.Media.ColorConverter]::ConvertFromString($buttonColor)))
    $buttonInstallADK.Foreground = (New-Object Windows.Media.SolidColorBrush ([System.Windows.Media.ColorConverter]::ConvertFromString($textColor)))
    $buttonInstallADK.Margin = "0,20,0,0"
    $panel.Children.Add($buttonInstallADK)

    # Button action for file picker
    $buttonBrowse.Add_Click({
        Add-Type -AssemblyName System.Windows.Forms  # Load Forms assembly before using the dialog
        $dialog = New-Object System.Windows.Forms.OpenFileDialog
        $dialog.Filter = "ISO files (*.iso)|*.iso|WIM files (*.wim)|*.wim"
        if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $textbox.Text = $dialog.FileName
        }
    })

    # Button action for starting the process
    $buttonStart.Add_Click({
        $filePath = $textbox.Text
        if (-not (Test-Path $filePath)) {
            [System.Windows.MessageBox]::Show("Please select a valid file.")
            return
        }

        # Step 1: Check necessary tools (DISM, oscdimg, etc.)
        if (-not (Get-Command dism -ErrorAction SilentlyContinue)) {
            [System.Windows.MessageBox]::Show("DISM tool not found. You can download it from Microsoft.")
            return
        }

        # Step 2: Perform actions based on file type (ISO or WIM)
        if ($filePath -like "*.iso") {
            Update-ToDo $toDoList 0
            ExtractAndProcessISO $filePath
        } elseif ($filePath -like "*.wim") {
            Update-ToDo $toDoList 2  # Directly go to splitting the WIM file
            SplitWIM $filePath
        }
    })

    # Button action for installing the latest ADK
    $buttonInstallADK.Add_Click({
        $confirmInstall = [System.Windows.MessageBox]::Show("This will download and install the latest Windows ADK. Continue?", "Confirm ADK Installation", [System.Windows.MessageBoxButton]::YesNo)
        if ($confirmInstall -eq [System.Windows.MessageBoxResult]::Yes) {
            Install-LatestADK
        }
    })

    $window.ShowDialog()
}

# Function to update the to-do list and strike through completed tasks
function Update-ToDo {
    param (
        [System.Windows.Controls.ListBox]$listBox,
        [int]$index
    )
    $item = $listBox.Items[$index]
    $item.Content = "[X] $($item.Content)"
    $item.Foreground = (New-Object Windows.Media.SolidColorBrush ([System.Windows.Media.ColorConverter]::ConvertFromString($completedColor)))
}

# Function to split the install.wim and recreate ISO
function ExtractAndProcessISO {
    param ($isoFilePath)

    # Step 1: Extract ISO
    Write-Host "Extracting the ISO..."
    $outputFolder = "$env:UserProfile\Desktop\ExtractedISO"
    New-Item -ItemType Directory -Path $outputFolder -Force | Out-Null
    $mountFolder = "$outputFolder\mount"
    $mountResult = Mount-DiskImage -ImagePath $isoFilePath -PassThru | Get-Volume
    $driveLetter = $mountResult.DriveLetter

    # Copy the contents of the mounted ISO to the output folder
    robocopy "$driveLetter`:\" "$outputFolder" /E /R:2 /W:5
    Dismount-DiskImage -ImagePath $isoFilePath
    Update-ToDo $toDoList 0

    # Step 2: Find install.wim and split it
    $installWim = "$outputFolder\sources\install.wim"
    if (-not (Test-Path $installWim)) {
        Write-Host "install.wim not found. Exiting."
        return
    }
    Write-Host "Splitting the install.wim..."
    $swmOutput = "$outputFolder\sources\install.swm"
    try {
        # Run the DISM command and capture the output
        $dismOutput = dism /Split-Image /ImageFile:$installWim /SWMFile:$swmOutput /FileSize:4000 2>&1
        Write-Host $dismOutput

        # Check if the SWM files were created
        if (-not (Test-Path "$outputFolder\sources\install.swm")) {
            Write-Host "Error: No install.swm files were created. Aborting deletion of install.wim."
            return
        }

        Write-Host "Successfully split the install.wim file."
        Update-ToDo $toDoList 1
        Update-ToDo $toDoList 2
    } catch {
        Write-Host "Error splitting the install.wim file: $_"
        return
    }

    # Step 3: Delete original install.wim after confirming SWM creation
    Remove-Item -Force $installWim
    Write-Host "Deleted install.wim."

    # Step 4: Recreate the ISO with install.swm
    $inputFileName = [System.IO.Path]::GetFileNameWithoutExtension($isoFilePath)
    $newIso = "$env:UserProfile\Desktop\ModifiedISO\$inputFileName`_FAT32.iso"
    $oscdimgPath = FindOscdimg
    Start-Process -FilePath $oscdimgPath -ArgumentList "-m -o -u2 -udfver102 $outputFolder $newIso" -Wait
    Update-ToDo $toDoList 3

    # Step 5: Clean up unnecessary files
    Write-Host "Cleaning up unnecessary files..."
    Remove-Item -Recurse -Force $outputFolder
    Update-ToDo $toDoList 4

    [System.Windows.MessageBox]::Show("Process complete. Your new ISO is at $newIso.")
}

# Function to split a provided WIM file
function SplitWIM {
    param ($wimFilePath)

    $outputFolder = "$env:UserProfile\Desktop\ModifiedISO"
    New-Item -ItemType Directory -Path $outputFolder -Force | Out-Null
    $inputFileName = [System.IO.Path]::GetFileNameWithoutExtension($wimFilePath)
    Dism /Split-Image /ImageFile:$wimFilePath /SWMFile:"$outputFolder\$inputFileName.swm" /FileSize:4000

    [System.Windows.MessageBox]::Show("Process complete. The split WIM files are in $outputFolder.")
    Update-ToDo $toDoList 2
}

# Function to find oscdimg.exe based on system architecture
function FindOscdimg {
    Write-Host "Searching for oscdimg.exe..."
    $oscdimgPaths = @(
        "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\x86\Oscdimg\oscdimg.exe",
        "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\x64\Oscdimg\oscdimg.exe",
        "C:\Program Files\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"
    )

    foreach ($path in $oscdimgPaths) {
        if (Test-Path $path) {
            Write-Host "Found oscdimg.exe at: $path"
            return $path
        }
    }

    Write-Host "oscdimg.exe not found. Please install the Windows ADK."
    [System.Windows.MessageBox]::Show("oscdimg.exe not found in the standard paths. Please install the Windows ADK.")
    return $null
}

# Function to auto-install the latest Windows ADK
function Install-LatestADK {
    Write-Host "Starting the download of the latest Windows ADK..."
    
    # URL of the official Microsoft ADK page
    $adkUrl = "https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install"
    $webContent = Invoke-WebRequest -Uri $adkUrl

    # Extract the download URLs using regular expressions
    $adkPattern = 'https:\/\/go\.microsoft\.com\/fwlink\/\?linkid=\d+'
    $matches = [regex]::Matches($webContent.Content, $adkPattern)

    if ($matches.Count -lt 2) {
        Write-Host "Could not find ADK download links. Check the page manually."
        return
    }

    # Extract the ADK installer URLs
    $adkDownloadUrl = $matches[0].Value
    $peAddonDownloadUrl = $matches[1].Value

    # Output folder for the installers
    $outputFolder = "$env:UserProfile\Downloads\ADK"
    if (-not (Test-Path $outputFolder)) {
        New-Item -ItemType Directory -Path $outputFolder | Out-Null
    }

    # Define file names for the installers
    $adkInstallerPath = Join-Path $outputFolder "adksetup.exe"
    $peAddonInstallerPath = Join-Path $outputFolder "adkwinpesetup.exe"

    # Download ADK
    Write-Host "Downloading Windows ADK installer..."
    Invoke-WebRequest -Uri $adkDownloadUrl -OutFile $adkInstallerPath

    # Download PE Add-on
    Write-Host "Downloading Windows PE Add-on installer..."
    Invoke-WebRequest -Uri $peAddonDownloadUrl -OutFile $peAddonInstallerPath

    # Install ADK silently
    Write-Host "Installing Windows ADK..."
    Start-Process -FilePath $adkInstallerPath -ArgumentList "/quiet /norestart" -Wait

    # Install PE Add-on silently
    Write-Host "Installing Windows PE Add-on..."
    Start-Process -FilePath $peAddonInstallerPath -ArgumentList "/quiet /norestart" -Wait

    [System.Windows.MessageBox]::Show("Windows ADK and PE Add-on installation completed successfully.")
}

# Start the GUI
Show-GUI

# Stop logging at the end of the script
Stop-Transcript
