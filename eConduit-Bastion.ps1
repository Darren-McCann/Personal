#### Setting environment variables ####
$Env:AWS_DEFAULT_REGION="us-east-2"
#### Setting Paramaters for connection ####
#Keys#
[String]$PublicKeyFile = "C:\Users\darren.mccann.adm/.ssh/id_rsa.pub"
[String]$PrivateKeyFile = "C:\Users\darren.mccann.adm/.ssh/id_rsa"

#Instance details#
[String]$Region = "us-east-2"
[String]$BastionIP = "172.18.191.226"
[String]$instanceID = "i-0ca6d91c160dc1500"
[String]$availabilityZone = "us-east-2b"
[String]$Endpoint = "mssql.internal.econduit.cloud"
[String]$LocalPort = "3389"
[String]$RDPPort = "3389"

aws ec2-instance-connect send-ssh-public-key --region $Region --instance-id $instanceID --availability-zone $availabilityZone --instance-os-user ec2-user --ssh-public-key file://$PublicKeyFile
ssh -L 127.0.0.1:"$LocalPort":"$Endpoint":$RDPPort -i "$PrivateKeyFile" ec2-user@"$BastionIP" -N -v