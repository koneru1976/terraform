resource "aws_instance" "my-ec2" {
  ami = "ami-0a313d6098716f372"
  instance_type = "t2.micro"
  tenancy = "default"
  subnet_id = "${aws_subnet.my-public-subnet.id}"
  key_name = "${aws_key_pair.mykeypair.key_name}"
  vpc_security_group_ids = ["${aws_security_group.allow-ssh.id}", "${aws_security_group.allow-http.id}"]

  provisioner "file" {
    source = "script.sh"
    destination = "/tmp/script.sh"

    connection {
      user = "ubuntu"
      private_key = "${file("mykey")}"
    }
  }

  provisioner "remote-exec" {
    inline = ["chmod +x /tmp/script.sh", "/tmp/script.sh"]

    connection {
      user = "ubuntu"
      private_key = "${file("mykey")}"
    }
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.my-ec2.public_ip} >> public_ips.txt"
  }

  tags {
    creted_by = "terraform"
  }
}

resource "aws_key_pair" "mykeypair" {
  public_key = "${file("mykey.pub")}"
}

resource "aws_security_group" "allow-ssh" {
  name = "allow-ssh"
  vpc_id = "${aws_vpc.my-vpc.id}"
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    name = "allow-ssh"
  }
}

resource "aws_security_group" "allow-http" {
  name = "allow-http"
  vpc_id = "${aws_vpc.my-vpc.id}"
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    name = "allow-ssh"
  }
}

output "ip" {
  value = "${aws_instance.my-ec2.public_dns}"
}