# Garnet HCL language


This proposes to build a simple programming language based on the HCL way of doing things. 

The idea is to basically, write ruby like syntax when doing terraform stuff. 

This hypothetical IaC language incorporates several Ruby-like features:

1. Block syntax using `do...end` instead of curly braces
2. Natural language-like resource definitions
3. Ruby-style string interpolation with `#{}`
4. Conditional statements using `if`
5. Iterative blocks using `each`
6. Method definitions within modules
7. Intuitive block nesting for complex configurations

The syntax is designed to be more approachable than traditional HCL while maintaining the declarative nature required for infrastructure provisioning. It allows for:

- More natural expression of infrastructure relationships
- Easy integration of programmatic logic
- Clear visual hierarchy of resources
- Familiar syntax for Ruby developers
- Maintainable and readable code structure

```bash
# Define a provider configuration block
provider "aws" do
  region "us-west-2"
  profile "default"
end

# Define a VPC resource
resource "aws_vpc" "main" do
  cidr_block "10.0.0.0/16"
  
  tags do
    Name "Main VPC"
    Environment "Production"
  end
end

# Define an EC2 instance
resource "aws_instance" "web_server" do
  ami "ami-0c55b159cbfafe1f0"
  instance_type "t2.micro"
  subnet_id vpc.main.subnet_ids[0]
  
  # Using Ruby-like conditional syntax
  ebs_optimized true if instance_type.starts_with?("t2")
  
  # Using Ruby-like block for user data
  user_data do |data|
    data.add_commands(
      "yum update -y",
      "yum install -y httpd",
      "systemctl start httpd",
      "systemctl enable httpd"
    )
  end
  
  # Dynamic block for security groups
  security_groups do |sg|
    sg.ingress do
      from_port 80
      to_port 80
      protocol "tcp"
      cidr_blocks ["0.0.0.0/0"]
    end
    
    sg.egress do
      from_port 0
      to_port 0
      protocol "-1"
      cidr_blocks ["0.0.0.0/0"]
    end
  end
  
  # Ruby-like iteration for volume attachments
  ["data1", "data2"].each do |volume_name|
    ebs_block_device do
      device_name "/dev/sd#{volume_name}"
      volume_size 100
      volume_type "gp3"
      delete_on_termination true
    end
  end
end

# Define an output block with Ruby-like string interpolation
output "instance_ip" do
  value "#{aws_instance.web_server.public_ip}"
  description "Public IP of the web server"
end

# Define a module with Ruby-like method definition
module "network" do
  source "./modules/network"
  
  def calculate_subnet_cidr(vpc_cidr, index)
    # Ruby-like method for CIDR calculation
    base_cidr = vpc_cidr.split("/")[0]
    "#{base_cidr}/#{20 + index}"
  end
  
  vpc_cidr aws_vpc.main.cidr_block
  subnet_count 3
end
```

## Compatibility with Terraform and HCL

Let’s identify key Terraform features and how this syntax would need to be expanded to fully cover typical use cases.

The example covers some fundamental patterns, but here are critical Terraform features that would need additional syntax:

1. State Management & Data Sources:

```ruby
ruby
Copy
# Data source syntax
data "aws_availability_zones" "available" do
  state "available"
end

# Remote state reference
data "terraform_remote_state" "network" do
  backend "s3"
  config do
    bucket "my-terraform-state"
    key "network/terraform.tfstate"
    region "us-west-2"
  end
end

```

1. Variables and Type Constraints:

```ruby
ruby
Copy
variable "environment" do
  type "string"
  default "development"
  validation do
    condition "contains(['dev', 'staging', 'prod'], var.environment)"
    error_message "Environment must be dev, staging, or prod"
  end
end

```

1. Provider Configuration with Aliases:

```ruby
ruby
Copy
provider "aws" do
  alias "east"
  region "us-east-1"
end

provider "aws" do
  alias "west"
  region "us-west-2"
end

```

1. Dynamic Blocks and Count/For_each:

```ruby
ruby
Copy
resource "aws_security_group" "example" do
# Count example
  count 3

# For_each example
  for_each {
    "small" => "t2.micro",
    "medium" => "t2.small",
    "large" => "t2.medium"
  }

# Dynamic block with complex iteration
  dynamic "ingress" do |ports|
    [80, 443, 8080].map do |port|
      content do
        from_port port
        to_port port
        protocol "tcp"
      end
    end
  end
end

```

1. Dependencies and Lifecycle Rules:

```ruby
ruby
Copy
resource "aws_instance" "example" do
  depends_on [aws_vpc.main, aws_subnet.primary]

  lifecycle do
    create_before_destroy true
    prevent_destroy true
    ignore_changes ["tags"]
  end
end

```

1. Workspaces and Backend Configuration:

```ruby
ruby
Copy
terraform do
  backend "s3" do
    bucket "my-terraform-state"
    key "workspaces/terraform.tfstate"
    region "us-west-2"
    workspace_key_prefix "environment"
  end
end

```

1. Provisioners:

```ruby
ruby
Copy
resource "aws_instance" "web" do
# ... other configuration ...

  provisioner "local-exec" do
    command "echo ${self.private_ip} >> private_ips.txt"
  end

  provisioner "remote-exec" do
    inline [
      "sudo apt-get update",
      "sudo apt-get install -y nginx"
    ]
  end
end

```

Some advanced Terraform features that would need special consideration:

1. Meta-arguments (count, for_each, provider, depends_on, lifecycle)
2. Complex type constraints (maps, sets, lists with specific types)
3. Built-in functions (coalesce, cidrsubnet, etc.)
4. Module versioning and source specifications
5. Provider-specific nested block structures
6. State management commands and workspace handling
7. Drift detection and import functionality

To fully replace Terraform, the language would also need to:

- Support all provider plugins
- Handle state locking
- Manage workspace environments
- Support import/export of existing resources
- Handle resource targeting
- Support plan/apply workflow
- Manage sensitive values
- Handle provider authentication

## Compiler design (Technically a transpiler)

This basically takes the `.gt` file extension and converts it to valid HCL code, then executes the code using go_hcl. 

![Screenshot 2024-11-28 at 13.00.30.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/3829a761-a88a-428d-9bec-d6133155dae4/6949ffb9-0643-4d8b-9e98-60211a0188a6/Screenshot_2024-11-28_at_13.00.30.png)
