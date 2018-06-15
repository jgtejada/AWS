#==============================================================================
#   CREACIÓN VPC
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

# Create the subnets and Cidrblock for the VPC
$cidrBlock = '10.0.0.0/16'
$privateSubnetCidr = '10.0.1.0/24'
$publicSubnetCidr = '10.0.2.0/24'

# Create the VPC
$VPC = New-EC2Vpc -CidrBlock $cidrBlock -Region 'eu-west-1'

# Tag the VPC
Add-EC2Tag -key Name -value 'VPC-Dev' -resourceId $VPC.VpcId -Region $region

# Choose the availability zone
$i = Get-Random -Minimum 0 -Maximum 3
$zone = Get-EC2AvailabilityZone -Region $region
$availabilityZone = $zone[$i].ZoneName

# Create the public subnet
$publicSubnet = New-EC2Subnet -VpcId $VPC.VPCId -CidrBlock $publicSubnetCidr -AvailabilityZone $availabilityZone -Region $region

# Tag the subnet
Add-EC2Tag -key Name -value 'Public-Dev-01' -resourceId $publicSubnet.SubnetId -Region $region

# Create the private subnet
$privateSubnet = New-EC2Subnet -VpcId $VPC.VPCId -CidrBlock $privateSubnetCidr -AvailabilityZone $availabilityZone -Region $region

# Tag the subnet
Add-EC2Tag -key Name -value 'Private-Dev-01' -resourceId $privateSubnet.SubnetId -Region $region

# Creating the internet gateway
$InternetGateway = New-EC2InternetGateway -Region $region
Add-EC2InternetGateway -InternetGatewayId $InternetGateway.InternetGatewayID -VpcId $VPC.vpcID -Region $region

# Tag the subnet
Add-EC2Tag -key Name -value 'IG-Dev' -resourceId $InternetGateway.InternetGatewayId -Region $region

# Create a route table and add the public subnet
$routeTable = New-EC2RouteTable -VpcId $VPC.VPCId -Region $region
New-EC2Route -RouteTableId $routeTable.routeTableID -DestinationCidrBlock '0.0.0.0/0' -GatewayId $InternetGateway.InternetGatewayID -Region $region
Register-EC2RouteTable -RouteTableId $routeTable.routeTableID -SubnetId $publicSubnet.subnetId -Region $region

