provider "vultr" {
	api_key = "${var.vultr_api_key}"
}

resource "vultr_ssh_key" "k8s" {
	name = "master node ssh key"
	public_key = "${file("./keys/id_rsa.pub")}"
}

# This is the bootstrapped Salt master.
resource "vultr_server" "k8s" {
	name = "master"

	# amsterdam. Find regions with `vultr regions`
	region_id = 7

	# smallest vultr server. Get plans with `vultr plans`
	# For a production cluster, a bigger plan needs to be used.
	plan_id = 87 

	# The operating system you want to use. 167 is CentOS 7.
	# Get a list of OS's with `vultr os`
	os_id = 167

	# enable IPv6.
	ipv6 = true

	# enable private networking.
	private_networking = true

	# enable one or more ssh keys on the root account.
	ssh_key_ids = ["${vultr_ssh_key.k8s.id}"]

	# get the IP address of the server that got created 
	provisioner "local-exec" {
        command = "echo local-exec ${vultr_server.k8s.ipv4_address}"
    }

	# bootstrap salt master 
	provisioner "remote-exec" {
        inline = [
                  "curl -o bootstrap-salt.sh -L https://bootstrap.saltstack.com",
                  "sh bootstrap-salt.sh -M -N git develop",
		]
    }
}
