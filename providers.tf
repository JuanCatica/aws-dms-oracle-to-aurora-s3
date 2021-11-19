# Latency between us-east-1 & us-west-2 is 68ms aprox. See https://www.cloudping.co/grid
# Latency between Colombia and us-east-1 is 87ms aprox (27% greater). See https://www.cloudping.info/

# US East (N. Virginia) - us-east-1
provider "aws" {
  alias  = "target"
  region = var.target_region
}

# US West (Oregon) - us-west-2
provider "aws" {
  alias  = "source"
  region = var.source_region
}
