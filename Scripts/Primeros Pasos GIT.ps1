Import-Module "C:\Program Files (x86)\AWS Tools\PowerShell\AWSPowerShell\AWSPowerShell.psd1"

#==============================================================================
#   CONFIGURACIÓN
#==============================================================================
#

#C:\WINDOWS\system32>aws configure
#AWS Access Key ID [****************7909]: xxxxxxxxxxxxxxxx
#AWS Secret Access Key [****************BB7Q]: xxxxxxxxxxxxxxxxxxxxxxxxx
#Default region name [eu-west-1]:
#Default output format [text]:

Set-AWSCredential -AccessKey xxxxxxxxxxxxxxxx -SecretKey xxxxxxxxxxxxxxxxxxxxxxxx -StoreAs default

Get-EC2Instance

Initialize-AWSDefaultConfiguration -ProfileName default -Region eu-west-1


#==============================================================================
#   KEYPAIR
#==============================================================================
#

#Crear KeyPair
$myPSKeyPair = New-EC2KeyPair -KeyName myPSKeyPair

#Vemos KeyPair
$myPSKeyPair | Format-List KeyName, KeyFingerprint, KeyMaterial

#Salvamos KeyPair
$myPSKeyPair.KeyMaterial | Out-File -Encoding ascii myPSKeyPair.pem

