# Create a parameter for $filepath that links to a file.
param([Parameter(Mandatory=$true)][string]$filepath = '')

# Create a parameter for the xml file in $filepath
$xml=[xml] (Get-Content $filepath)

#Create a parameter for the users within the xml file in $filepath
$users=$xml.root.user

# Iterate through each user in the xml file.
foreach($user in $users) {

# Check if the OU exists and add the OU if it doesn't
    $domain = Get-ADDomain
    $userOU = $user.ou
    $OUCheck = [adsi]::Exists("LDAP://OU=$userOU, $domain")
    
    if($OUCheck -ne $user.ou) {
        New-ADOrganizationalUnit -Name $user.ou -ProtectedFromAccidentalDeletion $false
        Write-Host $user.ou "has been created"
      }else {
        Write-Host $user.ou "Already exists within this domain."
      }
}

foreach($user in $users) {
    foreach($group in $user.memberOf) {
        New-ADGroup -Name $user.memberOf.group -GroupScope Global
        Write-Host $user.memberOf.group 'has been created'
    }
}

# Find and create the manager user and add them to the proper OU
    
foreach($user in $users) {
    $domain = Get-ADDomain
    $userOU = $user.ou
    if($user.manager -ne ''){
        continue        
    }else {
        New-ADUser -Name $user.account -GivenName $user.firstname -Surname $user.lastname -Description $user.description -AccountPassword ($secpass=ConvertTo-SecureString -AsPlainText 'Password1' -Force) -Enabled $true -ChangePasswordAtLogon $true -Path "OU=$userOU, $domain"
        Add-ADGroupMember -Identity $user.memberOf.group -Members $user.account
        write-host "adding user $($user.account) with the password of $($user.password)"
    }
}

# Iterate through the rest of the users, skipping the manager. Create and add users to proper OUs

foreach($user in $users) {
    $domain = Get-ADDomain
    $userOU = $user.ou
    if($user.manager -ne '') {
        New-ADUser -Name $user.account -GivenName $user.firstname -Surname $user.lastname -Description $user.description -AccountPassword ($secpass=ConvertTo-SecureString -AsPlainText 'Password1' -Force) -Enabled $true -ChangePasswordAtLogon $true -Manager $user.manager -Path "OU=$userOU, $domain"
        Add-ADGroupMember -Identity $user.memberOf.group -Members $user.account
        write-host "adding user $($user.account) with the password of $($user.password)"
    }else {
        continue
    }
}


        
    
    