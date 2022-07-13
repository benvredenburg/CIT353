# Create a parameter for $filepath that links to a file.
param([string]$filepath = 'C:\Make-Users_Script\users.xml')

# Check to make sure a file was entered for $filepath. End script and ask the user to do so if they did not.
if($filepath -eq ''){
    Write-Host "You have not provided a file path for this script. Please add a file path and try again."
    exit
}

# Create a parameter for the xml file in $filepath
$xml=[xml] (Get-Content $filepath)

#Create a parameter for the users within the xml file in $filepath
$users=$xml.root.user

# Iterate through each user in the xml file, checking to see if the OU they should be in exists, and creating the OU if they it doesn't
foreach($user in $users){

# Check if the OU exists and add the OU if it doesn't v1
    if(Get-ADOrganizationalUnit -ne $user.ou) {
        New-ADOrganizationalUnit -Name $user.ou
    }

#add user to the OU
    New-ADUser -Name $user.account -GivenName $user.firstname -Surname $user.lastname -Description $user.description -AccountPassword $user.password -Manager $user.manager -Path $user.ou -Enabled $true -ChangePasswordAtLogon $true
    
# Message to user informing them of the account creation and default password for new user
    write-host "adding user $($user.account) with the password of $($user.password)"

#set password

# Iterate through each user in the xml file, checking to see which group they should be a member of, and place them into that group.
    foreach ($group in $user.memberOf.group){
        Add-ADGroupMember -Identity $user.memberOf -Members $user.Name
        write-host "adding user $($user.account) to $group group" 

    }
}