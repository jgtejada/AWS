#==============================================================================
#   CREACIÓN INSTANCIA EC2
#==============================================================================
#
function Add-EC2Tag 
{

Param (
      [string][Parameter(Mandatory=$True)]$key,
      [string][Parameter(Mandatory=$True)]$value,
      [string][Parameter(Mandatory=$True)]$resourceId,
      [string][Parameter(Mandatory=$True)]$Region
      )

    $Tag = New-Object amazon.EC2.Model.Tag
    $Tag.Key = $Key
    $Tag.Value = $value

    New-EC2Tag -ResourceId $resourceId -Tag $Tag -Region $Region | Out-Null
}

### Global Variables ###
$region = 'eu-west-1'
$myPSKeyPair= Get-EC2KeyPair -KeyName myPSKeyPair -Region $region


# Allocate an Elastic IP Address
$Ec2Address = New-EC2Address -Domain vpc -Region $region

# Tag the Elastic IP Address
Add-EC2Tag -key Name -value 'EC2-ElasticIP' -resourceId $Ec2Address.AllocationId -Region $region

# Create the SecurityGroup
$securityGroup = New-EC2SecurityGroup -GroupName SG-DEV -GroupDescription 'EC2 SecurityGroup DEV' -VpcId $VPC.VpcId -Region $region

# Tag the SecurityGroup
Add-EC2Tag -key Name -value 'SG-DEV' -resourceId $securityGroup -Region $region

# Give Permissions to SecurityGroup
Grant-EC2SecurityGroupIngress -GroupId $securityGroup -Region $region -IpPermissions @{ IpProtocol = "tcp"; FromPort = 3389; ToPort = 3389; IpRanges = @("0.0.0.0/0")}
Grant-EC2SecurityGroupIngress -GroupId $securityGroup -Region $region -IpPermissions @{ IpProtocol = "tcp"; FromPort = 22; ToPort = 22; IpRanges = @("0.0.0.0/0")}

# Check Permissions from SecurityGroup
Get-EC2SecurityGroup -GroupId $securityGroup -Region $region | Select -ExpandProperty IpPermission

# Find AMI
Get-EC2ImageByName -Name amzn2-ami* -Region $region  | Sort-Object CreationDate | Select-Object imageid,Name

# Get AMI to deploy
$image = Get-EC2Image ami-921423eb -Region $region

# Create Instance EC2
$instanceEC2= New-EC2Instance -ImageId $image.ImageId -MinCount 1 -MaxCount 1 -KeyName myPSKeyPair -SecurityGroupId $securityGroup -InstanceType t2.micro -SubnetId $publicSubnet.SubnetId -Region $region

# Get the Instance EC2 created
$instance = Get-EC2Instance -Filter @{Name = "reservation-id"; Values = $instanceEC2.ReservationId } -Region $region

#Tag the EC2 instance
Add-EC2Tag -key Name -value 'EC2-DEV' -resourceId $instance.RunningInstance.instanceid -Region $region

#Assign Elastic IP Address to the EC2 when the instance is running
$DesiredState = “Running”
while ($true) {
    $State = (Get-EC2Instance -Region $region -InstanceId $instance.RunningInstance.instanceid).Instances.State.Name.Value
    if ($State -eq $DesiredState) {break;}

    “$(Get-Date) Current State = $State, Waiting for Desired State= $DesiredState”
    Start-Sleep -Seconds 5
}
Register-EC2Address -AllocationId $Ec2Address.AllocationId -InstanceId $instance.RunningInstance.instanceid -Region $region

# Get my PublicIP
Get-EC2Address -Region $region | select instanceID,PublicIP

# Decrypt the EC2 for Windows Machines
#Get-EC2PasswordData -InstanceId $instance.RunningInstance.instanceid -PemFile "C:\Users\antonio.pico\OneDrive - SoftwareONE\Tajamar\myPSKeyPair.pem" -Decrypt -Region $region
