# BasicWindowsMaintenance
This is my first PowerShell project which performs some basic system checks and maintenance tasks.

The aim of this script is to run very basic Windows OS tasks and system queries to identify potential issues and clear up redudant files in an effort to learn the PowerShell interpreter at a high level.

The following tasks are performed:
- Disk Storage Check which will warn when C drive is over 80% usage.
- RAM Check will query how many slots are in use and warn if there is less than 2GB of available memory.
- Perform a System File Check scan to repair courrupt system files.
- Launch Reliability Monitor to manually check for reoccuring application faults.
- Clear browser data will clear browser data such as Cookies, Cache and History from Edge, Chrome, Firfox and Brave.
- Perform a Windows Update by first installing the NuGet package manager to then install PSWindowsUpdate to perform the Windows Update.
