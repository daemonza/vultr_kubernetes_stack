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

	# Get plans with `vultr plans`
	# For a production cluster, a bigger plan needs to be used.
	plan_id = 201 

	# The operating system you want to use. 167 is CentOS 7.
	# Get a list of OS's with `vultr os`
	os_id = 167

	# enable IPv6.
	ipv6 = true

	# enable private networking.
	private_networking = true

	# enable one or more ssh keys on the root account.
	ssh_key_ids = ["${vultr_ssh_key.k8s.id}"]

	# map the IP to "salt" so that the minion can find the salt master 
	provisioner "remote-exec" {
        inline = [ 
		   "echo '${vultr_server.k8s.ipv4_address} salt' >> /etc/hosts"
		 ]
         }

	# change hostname to master. This will set the minion id as master.
	# Seeing as this minion controls the master, I like to call it master.
	provisioner "remote-exec" {
        inline = [ 
		   "hostname master"
		 ]
         }

	# bootstrap salt 
	provisioner "remote-exec" {
        inline = [
                  "curl -o bootstrap-salt.sh -L https://bootstrap.saltstack.com",
                  "sh bootstrap-salt.sh -M -P git develop",
		]
         }

	# setup salt keys
        provisioner "remote-exec" {
        inline = [ 
		   "mkdir -p /etc/salt/pki/master/minions",
                   "salt-key --gen-keys=minion --gen-keys-dir=/etc/salt/pki/minion",
                   "mkdir -p /etc/salt/pki/minion",
                   "cp /etc/salt/pki/minion/minion.pub /etc/salt/pki/master/minions/master",
		 ]
         }

	# restart the salt 
	provisioner "remote-exec" {
        inline = [
                  "systemctl restart salt-minion.service",
                  "systemctl restart salt-master.service",
		]
         }

}
