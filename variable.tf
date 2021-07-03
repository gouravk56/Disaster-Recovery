variable "ami_id"{
 default = {
 "MOBILE-01" = "ami-0e196f66f380afd17"
 "API-01"   = "ami-02f60d29c29872ebc" 
 } 
type = map
}
variable "env"{
default= "Gourav"
}
variable "vpc_zone_identifiers" {
default = {
 "MOBILE-01" = "subnet-e55e1283"
 "API-01"    = "subnet-97c68db6"
}
type = map 
}

variable "target_group" {
type = list(object({
 name = string
 port = number
 protocol = string
 target_type = string
}))
 default= [
  {
   name= "MOBILE-TG"
   port= 32155
   protocol= "HTTP"
   target_type = "instance"
  },
  {
   name = "API-TG"
   port = 32154
   protocol = "HTTP"
   target_type = "instance"
  }
 ]
}

variable "vpc_id" {
 default = "vpc-8841d8f5"
}
