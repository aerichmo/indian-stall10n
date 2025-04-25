variable "region"   { default = "us-central1" }
variable "cron"     { default = "0 15 * * *" }  # 10 a.m. CT
variable "api_user" { type = string }
variable "api_pass" { type = string }
